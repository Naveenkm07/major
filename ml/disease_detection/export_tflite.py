import sys
import argparse
from pathlib import Path
try:
    from ultralytics import YOLO
except ImportError:
    print("ERROR: ultralytics package is required. Run 'pip install ultralytics'")
    sys.exit(1)

def export_model(model_path, data_yaml, imgsz):
    model_file = Path(model_path)
    yaml_file = Path(data_yaml)
    
    if not model_file.exists():
        print(f"ERROR: Model file not found at {model_path}")
        sys.exit(1)
        
    if not yaml_file.exists():
        print(f"ERROR: Dataset YAML not found at {data_yaml}")
        sys.exit(1)

    print("=" * 60)
    print("📦 KRUSHIKADHARA - TFLITE INT8 EXPORT 📦")
    print("=" * 60)
    print(f"Model:           {model_path}")
    print(f"Dataset YAML:    {data_yaml}")
    print(f"Image Size:      {imgsz}")
    print(f"Format:          tflite")
    print(f"Quantization:    INT8 (with real representative dataset)")
    print("=" * 60)

    try:
        model = YOLO(str(model_file.absolute()))
    except Exception as e:
        print(f"ERROR: Failed to load model {model_path}. Is it a valid PyTorch model?")
        print(e)
        sys.exit(1)

    # ultralytics export natively supports int8 quantization if a representative dataset (data=...) is provided.
    print("Starting export... This may take several minutes.")
    try:
        exported_path = model.export(
            format="tflite",
            int8=True,
            data=str(yaml_file.absolute()), # Critical for real representative dataset
            imgsz=imgsz
        )
        print("\n✅ Export Complete!")
        print(f"Saved exported model to: {exported_path}")
        
        # Typically YOLO saves it as <model_name>_saved_model/<model_name>_int8.tflite
        # We can rename it for convenience if needed, but we leave it to the user.
        print("\nIMPORTANT: Verify the output filename and rename it to 'yolov8_int8.tflite'")
        print("Move it to 'mobile_app_flutter/assets/models/' for app consumption.")
    except Exception as e:
        print("\n❌ Export Failed!")
        print(e)
        sys.exit(1)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Export YOLOv8 to INT8 TFLite for KrushikaDhara")
    parser.add_argument("--model", type=str, required=True, help="Path to best.pt or similar weights file")
    parser.add_argument("--data", type=str, required=True, help="Path to data.yaml (required for INT8 calibration)")
    parser.add_argument("--imgsz", type=int, default=640, help="Image size (pixels)")
    
    args = parser.parse_args()
    export_model(args.model, args.data, args.imgsz)
