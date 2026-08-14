import os
import time
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
from torchvision import datasets, transforms, models
from pathlib import Path
import json
from PIL import ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True

def get_data_loaders(data_dir, batch_size=16, img_size=224):
    train_dir = os.path.join(data_dir, 'train')
    val_dir = os.path.join(data_dir, 'val')
    
    # Matching inference preprocessing: RGB, Resize, CenterCrop, Normalize
    train_transforms = transforms.Compose([
        transforms.Resize(img_size + 32),
        transforms.RandomResizedCrop(img_size, scale=(0.8, 1.0)),
        transforms.RandomHorizontalFlip(),
        transforms.ColorJitter(brightness=0.1, contrast=0.1),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    val_transforms = transforms.Compose([
        transforms.Resize(img_size + 32),
        transforms.CenterCrop(img_size),
        transforms.ToTensor(),
        transforms.Normalize([0.485, 0.456, 0.406], [0.229, 0.224, 0.225])
    ])
    
    train_dataset = datasets.ImageFolder(train_dir, train_transforms)
    val_dataset = datasets.ImageFolder(val_dir, val_transforms)
    
    train_loader = DataLoader(train_dataset, batch_size=batch_size, shuffle=True, num_workers=0)
    val_loader = DataLoader(val_dataset, batch_size=batch_size, shuffle=False, num_workers=0)
    
    return train_loader, val_loader, train_dataset.classes

def main():
    data_dir = "Z:/major/dataset_split"
    output_dir = "Z:/major/ml/disease_detection/output"
    os.makedirs(output_dir, exist_ok=True)
    
    epochs = 5  # Keeping it low for feasible runtime in environment
    batch_size = 16
    img_size = 224
    
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print(f"Using device: {device}")
    
    print("Loading data...")
    train_loader, val_loader, class_names = get_data_loaders(data_dir, batch_size, img_size)
    num_classes = len(class_names)
    print(f"Found {num_classes} classes.")
    
    # Save class names alphabetically
    with open(os.path.join(output_dir, "class_names.txt"), "w") as f:
        f.write("\n".join(class_names))
        
    print("Initializing MobileNetV3-Small...")
    # Load MobileNetV3-Small
    model = models.mobilenet_v3_small(weights=models.MobileNet_V3_Small_Weights.DEFAULT)
    # Modify classifier for 26 classes
    model.classifier[3] = nn.Linear(model.classifier[3].in_features, num_classes)
    model = model.to(device)
    
    criterion = nn.CrossEntropyLoss()
    optimizer = optim.Adam(model.parameters(), lr=0.001)
    
    best_val_acc = 0.0
    history = {'train_loss': [], 'val_acc': []}
    
    print("Starting training...")
    for epoch in range(epochs):
        model.train()
        running_loss = 0.0
        start_time = time.time()
        
        for inputs, labels in train_loader:
            inputs, labels = inputs.to(device), labels.to(device)
            
            optimizer.zero_grad()
            outputs = model(inputs)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()
            
            running_loss += loss.item() * inputs.size(0)
            
        epoch_loss = running_loss / len(train_loader.dataset)
        history['train_loss'].append(epoch_loss)
        
        # Validation
        model.eval()
        correct = 0
        total = 0
        with torch.no_grad():
            for inputs, labels in val_loader:
                inputs, labels = inputs.to(device), labels.to(device)
                outputs = model(inputs)
                _, predicted = torch.max(outputs.data, 1)
                total += labels.size(0)
                correct += (predicted == labels).sum().item()
                
        val_acc = correct / total
        history['val_acc'].append(val_acc)
        
        elapsed = time.time() - start_time
        print(f"Epoch {epoch+1}/{epochs} | Loss: {epoch_loss:.4f} | Val Acc: {val_acc:.4f} | Time: {elapsed:.1f}s")
        
        if val_acc > best_val_acc:
            best_val_acc = val_acc
            torch.save(model.state_dict(), os.path.join(output_dir, "best_model.pt"))
            
    torch.save(model.state_dict(), os.path.join(output_dir, "final_model.pt"))
    with open(os.path.join(output_dir, "training_history.json"), "w") as f:
        json.dump(history, f)
        
    print("Training completed. Best Val Acc:", best_val_acc)
    
if __name__ == "__main__":
    main()
