import sys
import argparse
from pathlib import Path
try:
    from ultralytics import YOLO
except ImportError:
    print("ERROR: ultralytics package is required. Run 'pip install ultralytics'")
    sys.exit(1)

def train_model(data_yaml, epochs, batch_size, imgsz, device, workers, project_dir):
    yaml_path = Path(data_yaml)
    if not yaml_path.exists():
        print(f"ERROR: Dataset YAML not found at {data_yaml}")
        sys.exit(1)
        
    print("=" * 60)
    print("🚀 KRUSHIKADHARA - YOLOv8 DISEASE DETECTION TRAINING 🚀")
    print("=" * 60)
    print(f"Dataset YAML: {data_yaml}")
    print(f"Epochs:       {epochs}")
    print(f"Batch Size:   {batch_size}")
    print(f"Image Size:   {imgsz}")
    print(f"Device:       {device}")
    print(f"Workers:      {workers}")
    print(f"Output Dir:   {project_dir}")
    print("=" * 60)

    # Use pretrained YOLOv8 nano as starting checkpoint
    # Nano is best for mobile deployment
    model = YOLO("yolov8n.pt") 

    # Train the model
    # The ultralytics library automatically saves best.pt, last.pt, PR curve, confusion matrix, etc.
    results = model.train(
        data=str(yaml_path.absolute()),
        epochs=epochs,
        batch=batch_size,
        imgsz=imgsz,
        device=device,
        workers=workers,
        project=project_dir,
        name="krushikadhara_run",
        exist_ok=True, # Overwrite previous run of the same name for simplicity
        patience=50,   # Early stopping
    )
    
    print("\n✅ Training Complete!")
    print(f"Artifacts (best.pt, confusion_matrix, etc.) saved to: {Path(project_dir) / 'krushikadhara_run'}")
    
    # Print basic metrics summary
    if hasattr(results, 'results_dict'):
        print("\n📊 Final Metrics:")
        metrics = results.results_dict
        if 'metrics/mAP50(B)' in metrics:
            print(f"  mAP@50:    {metrics['metrics/mAP50(B)']:.4f}")
        if 'metrics/mAP50-95(B)' in metrics:
            print(f"  mAP@50-95: {metrics['metrics/mAP50-95(B)']:.4f}")
        if 'metrics/precision(B)' in metrics:
            print(f"  Precision: {metrics['metrics/precision(B)']:.4f}")
        if 'metrics/recall(B)' in metrics:
            print(f"  Recall:    {metrics['metrics/recall(B)']:.4f}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Train YOLOv8 for KrushikaDhara Disease Detection")
    parser.add_argument("--data", type=str, required=True, help="Path to data.yaml")
    parser.add_argument("--epochs", type=int, default=100, help="Number of training epochs")
    parser.add_argument("--batch", type=int, default=16, help="Batch size")
    parser.add_argument("--imgsz", type=int, default=640, help="Image size (pixels)")
    parser.add_argument("--device", type=str, default="", help="Device to run on (e.g., 'cpu', '0', '0,1')")
    parser.add_argument("--workers", type=int, default=8, help="Number of dataloader workers")
    parser.add_argument("--project", type=str, default="runs/train", help="Save directory for results")
    
    args = parser.parse_args()
    train_model(args.data, args.epochs, args.batch, args.imgsz, args.device, args.workers, args.project)
