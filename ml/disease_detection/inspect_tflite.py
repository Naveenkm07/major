import sys
import argparse
from pathlib import Path
try:
    import numpy as np
    import tensorflow as tf
except ImportError:
    print("ERROR: tensorflow and numpy are required. Run 'pip install tensorflow numpy'")
    sys.exit(1)

def inspect_tflite(model_path):
    model_file = Path(model_path)
    if not model_file.exists():
        print(f"ERROR: Model file not found at {model_path}")
        sys.exit(1)

    print("=" * 60)
    print("🔬 KRUSHIKADHARA - TFLITE INSPECTOR 🔬")
    print("=" * 60)
    print(f"Model: {model_path}")

    try:
        interpreter = tf.lite.Interpreter(model_path=str(model_file))
        interpreter.allocate_tensors()
    except Exception as e:
        print(f"ERROR: Failed to load TFLite model: {e}")
        sys.exit(1)

    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()

    if len(input_details) == 0:
        print("ERROR: No inputs found in model.")
        sys.exit(1)
    if len(output_details) == 0:
        print("ERROR: No outputs found in model.")
        sys.exit(1)

    inp = input_details[0]
    out = output_details[0]

    # Input Details
    in_shape = inp['shape']
    in_dtype = inp['dtype']
    in_quant = inp['quantization']
    in_scale, in_zp = in_quant if in_quant != (0.0, 0) else ("N/A", "N/A")

    print("\n--- INPUT TENSOR ---")
    print(f"Shape:       {in_shape}")
    print(f"Data Type:   {in_dtype.__name__}")
    print(f"Scale:       {in_scale}")
    print(f"Zero Point:  {in_zp}")

    # Output Details
    out_shape = out['shape']
    out_dtype = out['dtype']
    out_quant = out['quantization']
    out_scale, out_zp = out_quant if out_quant != (0.0, 0) else ("N/A", "N/A")

    print("\n--- OUTPUT TENSOR ---")
    print(f"Shape:       {out_shape}")
    print(f"Data Type:   {out_dtype.__name__}")
    print(f"Scale:       {out_scale}")
    print(f"Zero Point:  {out_zp}")

    # Deductions
    print("\n--- DEDUCTIONS ---")
    
    # Resolution deduction from input
    # Expected YOLO input: [1, H, W, 3] or [1, 3, H, W]
    if len(in_shape) == 4:
        if in_shape[3] == 3:
            print(f"Input Resolution: {in_shape[1]}x{in_shape[2]} (RGB/NHWC)")
        elif in_shape[1] == 3:
            print(f"Input Resolution: {in_shape[2]}x{in_shape[3]} (RGB/NCHW)")
        else:
            print(f"Input Resolution: UNKNOWN ({in_shape})")
    else:
        print(f"Input Resolution: UNKNOWN ({in_shape})")

    # Layout & Classes deduction from output
    # Expected YOLOv8 output: [1, 4 + classes, anchors] or [1, anchors, 4 + classes]
    if len(out_shape) == 3:
        dim1, dim2 = out_shape[1], out_shape[2]
        if dim1 < dim2:
            layout = "[1, Elements, Anchors] (Channels First)"
            elements = dim1
            anchors = dim2
        else:
            layout = "[1, Anchors, Elements] (Anchors First)"
            anchors = dim1
            elements = dim2
            
        class_count = elements - 4
        print(f"Tensor Layout: {layout}")
        print(f"Class Count:   {class_count} (Elements: {elements} - 4 bbox values)")
        print(f"Anchor Count:  {anchors}")
    else:
        print(f"Tensor Layout: UNKNOWN ({out_shape})")
        print(f"Class Count:   UNKNOWN")
        print(f"Anchor Count:  UNKNOWN")

    print("=" * 60)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Inspect TFLite Model Metadata")
    parser.add_argument("--model", type=str, required=True, help="Path to .tflite model")
    
    args = parser.parse_args()
    inspect_tflite(args.model)
