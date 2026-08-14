import os
import torch
import torch.nn as nn
from torchvision import models
from pathlib import Path

# NOTE: This script demonstrates how to export PyTorch -> ONNX -> TFLite.
# Since TensorFlow cannot be installed in this Python 3.14 environment,
# this script stops after exporting the ONNX model.

def export_to_onnx():
    model_path = "Z:/major/ml/disease_detection/output/best_model.pt"
    onnx_path = "Z:/major/ml/disease_detection/output/best_model.onnx"
    class_names_path = "Z:/major/ml/disease_detection/output/class_names.txt"
    
    if not os.path.exists(model_path):
        print(f"Error: Model not found at {model_path}")
        return
        
    with open(class_names_path, "r") as f:
        class_names = [line.strip() for line in f.readlines()]
    num_classes = len(class_names)
    
    device = torch.device("cpu")
    model = models.mobilenet_v3_small()
    model.classifier[3] = nn.Linear(model.classifier[3].in_features, num_classes)
    model.load_state_dict(torch.load(model_path, map_location=device))
    model.eval()
    
    # Dummy input matching the expected input of the model
    dummy_input = torch.randn(1, 3, 224, 224)
    
    print(f"Exporting PyTorch model to ONNX...")
    torch.onnx.export(model, dummy_input, onnx_path, 
                      export_params=True, 
                      opset_version=12, 
                      do_constant_folding=True, 
                      input_names=['input'], 
                      output_names=['output'], 
                      dynamic_axes={'input': {0: 'batch_size'}, 'output': {0: 'batch_size'}})
                      
    print(f"Successfully exported ONNX model to {onnx_path}")
    
    print("\n--- TFLITE EXPORT BLOCKED ---")
    print("Exporting ONNX to TFLite (INT8) requires TensorFlow (tf.lite.TFLiteConverter).")
    print("TensorFlow is currently incompatible with Python 3.14.6.")
    print("Please run an external converter (e.g., ONNX2TFLite or a Google Colab notebook) to generate 'crop_disease_classifier_int8.tflite'.")

if __name__ == "__main__":
    export_to_onnx()
