import tensorflow as tf
import os
import sys

print("=========================================================================")
print("WARNING: DEVELOPMENT / TEST ONLY")
print("This script generates a MOCK (tf.zeros) TFLite model.")
print("It DOES NOT perform genuine disease detection and is ONLY for testing")
print("the Flutter inference pipeline compilation and loading mechanisms.")
print("DO NOT USE THE GENERATED MODEL IN PRODUCTION.")
print("=========================================================================\n")

class DummyYolo(tf.Module):
    @tf.function(input_signature=[tf.TensorSpec(shape=[1, 640, 640, 3], dtype=tf.float32)])
    def __call__(self, x):
        return tf.zeros([1, 12, 8400], dtype=tf.float32)

model = DummyYolo()

converter = tf.lite.TFLiteConverter.from_concrete_functions(
    [model.__call__.get_concrete_function()]
)

converter.optimizations = [tf.lite.Optimize.DEFAULT]
def representative_dataset():
    for _ in range(10):
        yield [tf.random.uniform([1, 640, 640, 3], dtype=tf.float32)]

converter.representative_dataset = representative_dataset
converter.target_spec.supported_ops = [tf.lite.OpsSet.TFLITE_BUILTINS_INT8]
converter.inference_input_type = tf.int8
converter.inference_output_type = tf.int8

tflite_model = converter.convert()

os.makedirs('assets/models', exist_ok=True)
with open('assets/models/yolov8_int8.tflite', 'wb') as f:
    f.write(tflite_model)

print("Created dummy YOLOv8 INT8 TFLite model at assets/models/yolov8_int8.tflite")
