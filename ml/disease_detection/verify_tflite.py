import os
import sys
import glob
import json
import numpy as np
from PIL import Image

# Dummy imports, will fail if not installed properly. 
# This script will be run after model is exported and environment is ready.
try:
    import torch
    from torchvision import transforms
    import onnxruntime as ort
    import tensorflow as tf
except ImportError:
    pass # Might fail on local environment due to TF issues, it's fine.

TFLITE_MODEL_PATH = "mobile_app_flutter/assets/models/crop_disease_classifier_int8.tflite"
ONNX_MODEL_PATH = "ml/disease_detection/output/best_model.onnx"
PYTORCH_MODEL_PATH = "ml/disease_detection/output/best_model.pt"
TEST_DATA_DIR = "dataset_split/test"
LABELS_PATH = "mobile_app_flutter/assets/models/disease_labels.txt"
OUTPUT_REPORT_PATH = "ml/disease_detection/output/tflite_validation_report.json"

def get_labels():
    with open(LABELS_PATH, "r") as f:
        labels = [l.strip() for l in f.readlines() if l.strip()]
    return labels

def preprocess_image(image_path, format="nchw", dtype=np.float32):
    img = Image.open(image_path).convert("RGB")
    img = img.resize((224, 224))
    img_array = np.array(img, dtype=np.float32) / 255.0
    mean = np.array([0.485, 0.456, 0.406], dtype=np.float32)
    std = np.array([0.229, 0.224, 0.225], dtype=np.float32)
    img_array = (img_array - mean) / std
    
    if format == "nchw":
        img_array = np.transpose(img_array, (2, 0, 1))
    
    img_array = np.expand_dims(img_array, axis=0).astype(dtype)
    return img_array

def softmax(x):
    e_x = np.exp(x - np.max(x))
    return e_x / e_x.sum(axis=1, keepdims=True)

def verify_tflite_metadata(interpreter):
    input_details = interpreter.get_input_details()[0]
    output_details = interpreter.get_output_details()[0]
    
    errors = []
    
    if input_details["shape"].tolist() not in [[1, 3, 224, 224], [1, 224, 224, 3]]:
        errors.append(f"Invalid input shape: {input_details['shape']}")
        
    if output_details["shape"].tolist() != [1, 25]:
        errors.append(f"Invalid output shape: {output_details['shape']}")
        
    if input_details["dtype"] != np.int8:
        errors.append(f"Invalid input dtype: {input_details['dtype']}")
        
    if output_details["dtype"] != np.int8:
        errors.append(f"Invalid output dtype: {output_details['dtype']}")
        
    if len(errors) > 0:
        print("TFLite Model Verification FAILED:")
        for e in errors:
            print(f"- {e}")
        return False
        
    print("TFLite Metadata Verification PASSED.")
    return True

def run_validation():
    print("Running Full TFLite Validation & Comparison...")
    
    if not os.path.exists(TFLITE_MODEL_PATH):
        print(f"ERROR: TFLite model not found at {TFLITE_MODEL_PATH}")
        sys.exit(1)
        
    labels = get_labels()
    if len(labels) != 25:
        print(f"ERROR: Label count != 25. Found {len(labels)}")
        sys.exit(1)
        
    # Load Models
    print("Loading PyTorch model...")
    pt_model = torch.jit.load(PYTORCH_MODEL_PATH)
    pt_model.eval()
    
    print("Loading ONNX model...")
    ort_session = ort.InferenceSession(ONNX_MODEL_PATH)
    
    print("Loading TFLite model...")
    tflite_interpreter = tf.lite.Interpreter(model_path=TFLITE_MODEL_PATH)
    tflite_interpreter.allocate_tensors()
    
    if not verify_tflite_metadata(tflite_interpreter):
        sys.exit(1)
        
    input_details = tflite_interpreter.get_input_details()[0]
    output_details = tflite_interpreter.get_output_details()[0]
    
    in_scale, in_zero = input_details["quantization"]
    out_scale, out_zero = output_details["quantization"]
    
    tflite_input_format = "nhwc" if input_details["shape"].tolist() == [1, 224, 224, 3] else "nchw"
    
    test_images = glob.glob(f"{TEST_DATA_DIR}/*/*.*")
    np.random.shuffle(test_images)
    test_images = test_images[:100] # Test on 100 images for speed in comparison
    
    results = []
    
    for img_path in test_images:
        true_class = os.path.basename(os.path.dirname(img_path))
        
        # PyTorch / ONNX Input
        pt_in = preprocess_image(img_path, format="nchw", dtype=np.float32)
        
        # TFLite Input
        tf_in_float = preprocess_image(img_path, format=tflite_input_format, dtype=np.float32)
        tf_in_quant = np.clip(np.round(tf_in_float / in_scale + in_zero), -128, 127).astype(np.int8)
        
        # 1. PyTorch
        with torch.no_grad():
            pt_out = pt_model(torch.from_numpy(pt_in)).numpy()
        pt_prob = softmax(pt_out)[0]
        pt_pred = int(np.argmax(pt_prob))
        pt_conf = float(pt_prob[pt_pred])
        
        # 2. ONNX
        ort_inputs = {ort_session.get_inputs()[0].name: pt_in}
        ort_out = ort_session.run(None, ort_inputs)[0]
        ort_prob = softmax(ort_out)[0]
        ort_pred = int(np.argmax(ort_prob))
        ort_conf = float(ort_prob[ort_pred])
        
        # 3. TFLite
        tflite_interpreter.set_tensor(input_details['index'], tf_in_quant)
        tflite_interpreter.invoke()
        tf_out_quant = tflite_interpreter.get_tensor(output_details['index'])[0]
        tf_out_float = (tf_out_quant.astype(np.float32) - out_zero) * out_scale
        tf_prob = softmax(np.expand_dims(tf_out_float, axis=0))[0]
        tf_pred = int(np.argmax(tf_prob))
        tf_conf = float(tf_prob[tf_pred])
        
        res = {
            "image": img_path,
            "true_class": true_class,
            "pytorch": {"class": labels[pt_pred], "confidence": pt_conf},
            "onnx": {"class": labels[ort_pred], "confidence": ort_conf},
            "tflite": {"class": labels[tf_pred], "confidence": tf_conf},
            "discrepancy": pt_pred != ort_pred or pt_pred != tf_pred
        }
        results.append(res)
        
        print(f"[{img_path}] True: {true_class} | PT: {labels[pt_pred]} ({pt_conf:.2f}) | ONNX: {labels[ort_pred]} ({ort_conf:.2f}) | TFLite: {labels[tf_pred]} ({tf_conf:.2f})")
        
    
    # Calculate Discrepancies
    pt_vs_onnx = sum(1 for r in results if r["pytorch"]["class"] == r["onnx"]["class"]) / len(results)
    pt_vs_tf = sum(1 for r in results if r["pytorch"]["class"] == r["tflite"]["class"]) / len(results)
    
    print("\n=== CONVERSION AGREEMENT ===")
    print(f"PyTorch vs ONNX Agreement: {pt_vs_onnx*100:.2f}%")
    print(f"PyTorch vs TFLite Agreement: {pt_vs_tf*100:.2f}%")
    
    with open(OUTPUT_REPORT_PATH, "w") as f:
        json.dump({"results": results, "agreement": {"pt_vs_onnx": pt_vs_onnx, "pt_vs_tflite": pt_vs_tf}}, f, indent=4)
        
    print(f"Report saved to {OUTPUT_REPORT_PATH}")

if __name__ == "__main__":
    run_validation()
