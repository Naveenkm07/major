import os
import torch
import torch.nn as nn
from torch.utils.data import DataLoader
from torchvision import datasets, transforms, models
from pathlib import Path
from sklearn.metrics import classification_report, f1_score, accuracy_score
import json
from PIL import ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True

def main():
    data_dir = "Z:/major/dataset_split/test"
    model_path = "Z:/major/ml/disease_detection/output/best_model.pt"
    class_names_path = "Z:/major/ml/disease_detection/output/class_names.txt"
    report_output_path = "Z:/major/docs/MODEL_EVALUATION_REPORT.md"
    
    if not os.path.exists(model_path):
        print(f"Error: Model not found at {model_path}")
        return
        
    with open(class_names_path, "r") as f:
        class_names = [line.strip() for line in f.readlines()]
    num_classes = len(class_names)
    
    img_size = 224
    test_transforms = transforms.Compose([
        transforms.Resize(img_size + 32),
        transforms.CenterCrop(img_size),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    test_dataset = datasets.ImageFolder(data_dir, test_transforms)
    test_loader = DataLoader(test_dataset, batch_size=16, shuffle=False)
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Evaluating on {device}")
    
    model = models.mobilenet_v3_small()
    model.classifier[3] = nn.Linear(model.classifier[3].in_features, num_classes)
    model.load_state_dict(torch.load(model_path, map_location=device))
    model = model.to(device)
    model.eval()
    
    y_true = []
    y_pred = []
    
    print("Running inference on test set...")
    with torch.no_grad():
        for inputs, labels in test_loader:
            inputs = inputs.to(device)
            outputs = model(inputs)
            _, predicted = torch.max(outputs, 1)
            y_true.extend(labels.numpy())
            y_pred.extend(predicted.cpu().numpy())
            
    # Calculate metrics
    acc = accuracy_score(y_true, y_pred)
    macro_f1 = f1_score(y_true, y_pred, average='macro')
    weighted_f1 = f1_score(y_true, y_pred, average='weighted')
    report_dict = classification_report(y_true, y_pred, target_names=class_names, output_dict=True)
    report_str = classification_report(y_true, y_pred, target_names=class_names)
    
    print(f"Accuracy: {acc:.4f}")
    print(f"Macro F1: {macro_f1:.4f}")
    print(f"Weighted F1: {weighted_f1:.4f}")
    print("\nDetailed Report:\n", report_str)
    
    # Save markdown report
    md_content = f"""# KrushikaDhara Classification Model Evaluation

## Overall Metrics
- **Accuracy:** {acc:.4f}
- **Macro F1:** {macro_f1:.4f}
- **Weighted F1:** {weighted_f1:.4f}

## Classification Report
```
{report_str}
```
"""
    os.makedirs(os.path.dirname(report_output_path), exist_ok=True)
    with open(report_output_path, "w") as f:
        f.write(md_content)
        
    print(f"Saved evaluation report to {report_output_path}")

if __name__ == "__main__":
    main()
