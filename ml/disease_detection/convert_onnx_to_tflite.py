import onnx
from onnx_tf.backend import prepare
import tensorflow as tf
import os

onnx_path = "output/best_model.onnx"
tf_model_path = "output/saved_model"
tflite_path = "output/crop_disease_classifier_int8.tflite"

def convert():
    if not os.path.exists(onnx_path):
        print("ONNX model not found.")
        return
        
    print("Loading ONNX model...")
    onnx_model = onnx.load(onnx_path)
    
    print("Converting ONNX to TensorFlow SavedModel...")
    tf_rep = prepare(onnx_model)
    tf_rep.export_graph(tf_model_path)
    print(f"SavedModel saved to {tf_model_path}")
    
    print("Converting SavedModel to TFLite (with INT8 quantization)...")
    converter = tf.lite.TFLiteConverter.from_saved_model(tf_model_path)
    
    import numpy as np
    def representative_dataset():
        for _ in range(100):
            yield [np.random.rand(1, 3, 224, 224).astype(np.float32)]

    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    converter.representative_dataset = representative_dataset
    converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
    converter.inference_input_type = tf.int8
    converter.inference_output_type = tf.int8
    
    tflite_model = converter.convert()
    
    with open(tflite_path, 'wb') as f:
        f.write(tflite_model)
    print(f"TFLite model saved to {tflite_path}")

if __name__ == "__main__":
    convert()
