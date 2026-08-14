import sys
import argparse
from pathlib import Path
try:
    from ultralytics import YOLO
except ImportError:
    print("ERROR: ultralytics package is required. Run 'pip install ultralytics'")
    sys.exit(1)

def evaluate_model(model_path, data_yaml, imgsz, split, project_dir):
    model_file = Path(model_path)
    yaml_file = Path(data_yaml)
    
    if not model_file.exists():
        print(f"ERROR: Model file not found at {model_path}")
        sys.exit(1)
        
    if not yaml_file.exists():
        print(f"ERROR: Dataset YAML not found at {data_yaml}")
        sys.exit(1)

    print("=" * 60)
    print("🔍 KRUSHIKADHARA - YOLOv8 EVALUATION 🔍")
    print("=" * 60)
    print(f"Model:        {model_path}")
    print(f"Dataset YAML: {data_yaml}")
    print(f"Split:        {split}")
    print(f"Image Size:   {imgsz}")
    print(f"Output Dir:   {project_dir}")
    print("=" * 60)

    try:
        model = YOLO(str(model_file.absolute()))
    except Exception as e:
        print(f"ERROR: Failed to load model {model_path}. Is it a valid PyTorch model?")
        print(e)
        sys.exit(1)

    # ultralytics automatically calculates and saves confusion matrix, PR curves, etc.
    metrics = model.val(
        data=str(yaml_file.absolute()),
        split=split,
        imgsz=imgsz,
        project=project_dir,
        name="krushikadhara_eval",
        exist_ok=True
    )
    
    print("\n✅ Evaluation Complete!")
    print(f"Artifacts (confusion_matrix, PR_curve, etc.) saved to: {Path(project_dir) / 'krushikadhara_eval'}")
    
    print("\n📊 Evaluation Metrics:")
    if hasattr(metrics, 'results_dict'):
        results = metrics.results_dict
        map50 = results.get('metrics/mAP50(B)', 0.0)
        map50_95 = results.get('metrics/mAP50-95(B)', 0.0)
        precision = results.get('metrics/precision(B)', 0.0)
        recall = results.get('metrics/recall(B)', 0.0)
        
        # Calculate F1 Score
        if precision + recall > 0:
            f1 = 2 * (precision * recall) / (precision + recall)
        else:
            f1 = 0.0

        print(f"  Precision:   {precision:.4f}")
        print(f"  Recall:      {recall:.4f}")
        print(f"  F1 Score:    {f1:.4f}")
        print(f"  mAP@50:      {map50:.4f}")
        print(f"  mAP@50-95:   {map50_95:.4f}")
    else:
        print("ERROR: Could not extract metrics from evaluation results.")
        
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Evaluate YOLOv8 for KrushikaDhara Disease Detection")
    parser.add_argument("--model", type=str, required=True, help="Path to best.pt or similar weights file")
    parser.add_argument("--data", type=str, required=True, help="Path to data.yaml")
    parser.add_argument("--imgsz", type=int, default=640, help="Image size (pixels)")
    parser.add_argument("--split", type=str, default="val", help="Dataset split to evaluate on (val, test)")
    parser.add_argument("--project", type=str, default="runs/val", help="Save directory for results")
    
    args = parser.parse_args()
    evaluate_model(args.model, args.data, args.imgsz, args.split, args.project)
