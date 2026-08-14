import sys
import argparse
from pathlib import Path
try:
    import tensorflow as tf
except ImportError:
    print("ERROR: tensorflow is required. Run 'pip install tensorflow'")
    sys.exit(1)

def verify_compatibility(model_path, labels_path):
    model_file = Path(model_path)
    labels_file = Path(labels_path)
    
    if not model_file.exists():
        print(f"ERROR: Model file not found at {model_path}")
        sys.exit(1)
        
    if not labels_file.exists():
        print(f"ERROR: Labels file not found at {labels_path}")
        sys.exit(1)

    print("=" * 60)
    print("✅ KRUSHIKADHARA - FLUTTER COMPATIBILITY CHECK ✅")
    print("=" * 60)
    
    try:
        interpreter = tf.lite.Interpreter(model_path=str(model_file))
        interpreter.allocate_tensors()
    except Exception as e:
        print(f"INCOMPATIBLE: Failed to load TFLite model: {e}")
        sys.exit(1)

    inp = interpreter.get_input_details()[0]
    out = interpreter.get_output_details()[0]
    
    with open(labels_file, 'r') as f:
        labels = [line.strip() for line in f if line.strip()]
        
    label_count = len(labels)
    
    errors = []
    
    # 1. Input Shape
    in_shape = inp['shape']
    if len(in_shape) != 4 or in_shape[1] != 640 or in_shape[2] != 640 or in_shape[3] != 3:
        errors.append(f"Input shape must be [1, 640, 640, 3], got {in_shape}.")
        
    # 2. Input Datatype
    if inp['dtype'] != tf.int8:
        errors.append(f"Input datatype must be int8, got {inp['dtype'].__name__}.")
        
    # 3. Input Quantization
    in_scale, in_zp = inp['quantization']
    if in_scale == 0.0:
        errors.append("Input is missing valid INT8 quantization scale.")
        
    # 4. Output Shape & Layout
    out_shape = out['shape']
    if len(out_shape) != 3:
        errors.append(f"Output shape must be rank 3, got {out_shape}.")
    else:
        dim1, dim2 = out_shape[1], out_shape[2]
        if dim1 < dim2:
            class_count = dim1 - 4
        else:
            class_count = dim2 - 4
            
        # 5. Class Count Match
        if class_count != label_count:
            errors.append(f"Model defines {class_count} classes, but {labels_file.name} provides {label_count} labels.")
            
    # 6. Output Datatype
    if out['dtype'] not in [tf.int8, tf.float32]:
        errors.append(f"Output datatype unsupported ({out['dtype'].__name__}). Expected int8 or float32.")

    # 7. Output Quantization
    if out['dtype'] == tf.int8:
        out_scale, out_zp = out['quantization']
        if out_scale == 0.0:
            errors.append("Output is missing valid INT8 quantization scale.")

    if errors:
        print("\n❌ INCOMPATIBLE")
        print("\nExact Reasons:")
        for err in errors:
            print(f"- {err}")
        sys.exit(1)
    else:
        print("\n✅ COMPATIBLE")
        print("\nThis model matches the Flutter app's expected constraints:")
        print("- Valid Input Shape & Data Type")
        print("- Valid INT8 Quantization Metadata")
        print("- Valid YOLOv8 Output Tensor Layout")
        print("- Valid Class Label Count Alignment")
        print("\nThe Flutter pipeline natively handles Aspect-Ratio Letterboxing mapping, so no manual image preprocessing changes are required.")
        sys.exit(0)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Verify TFLite Model Compatibility with Flutter App")
    parser.add_argument("--model", type=str, required=True, help="Path to .tflite model")
    parser.add_argument("--labels", type=str, required=True, help="Path to disease_labels.txt")
    
    args = parser.parse_args()
    verify_compatibility(args.model, args.labels)
