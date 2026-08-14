import os
import sys
import yaml
from pathlib import Path

try:
    from PIL import Image, UnidentifiedImageError
except ImportError:
    print("ERROR: Pillow is required. Run 'pip install Pillow'")
    sys.exit(1)

def validate_dataset(dataset_path):
    print(f"Validating dataset at: {dataset_path}")
    dataset_dir = Path(dataset_path)
    
    # 1. Check Directories Exist
    if not dataset_dir.exists():
        print("ERROR: Dataset directory does not exist.")
        sys.exit(1)

    yaml_path = dataset_dir / "data.yaml"
    if not yaml_path.exists():
        print(f"ERROR: data.yaml not found at {yaml_path}")
        sys.exit(1)

    # Load data.yaml
    with open(yaml_path, 'r') as f:
        try:
            data = yaml.safe_load(f)
        except Exception as e:
            print(f"ERROR: Invalid YAML format in data.yaml: {e}")
            sys.exit(1)

    # 10. No missing classes / Verify YAML schema
    if 'nc' not in data or 'names' not in data:
        print("ERROR: data.yaml must contain 'nc' (number of classes) and 'names' (list of class names).")
        sys.exit(1)

    nc = data['nc']
    names = data['names']

    if not isinstance(nc, int) or nc <= 0:
        print(f"ERROR: 'nc' must be a positive integer, got: {nc}")
        sys.exit(1)

    if not isinstance(names, list) or len(names) != nc:
        print(f"ERROR: 'names' must be a list of length {nc}.")
        sys.exit(1)

    # 9. No duplicate class names
    if len(set(names)) != len(names):
        print("ERROR: Duplicate class names found in data.yaml.")
        sys.exit(1)
        
    print(f"SUCCESS: Found {nc} classes.")

    splits = ['train', 'val', 'test']
    total_images = 0
    total_labels = 0

    class_counts = {i: 0 for i in range(nc)}

    for split in splits:
        if split not in data:
            if split in ['train', 'val']:
                print(f"ERROR: data.yaml is missing required split: '{split}'")
                sys.exit(1)
            continue
            
        split_path = dataset_dir / data[split]
        if not split_path.exists():
            print(f"ERROR: Path for split '{split}' does not exist: {split_path}")
            sys.exit(1)
            
        # Assuming YOLO structure: dataset/images/train and dataset/labels/train
        # data[split] usually points to images dir
        images_dir = split_path
        labels_dir = images_dir.parent.parent / 'labels' / images_dir.name
        
        if not labels_dir.exists():
            # Alternative layout where data[split] is 'dataset/train/images'
            labels_dir = images_dir.parent / 'labels'
            if not labels_dir.exists():
                print(f"ERROR: Cannot find corresponding labels directory for {images_dir}")
                sys.exit(1)
                
        print(f"\nValidating split '{split}':")
        print(f"  Images: {images_dir}")
        print(f"  Labels: {labels_dir}")

        image_files = [f for f in images_dir.glob('*.*') if f.suffix.lower() in ['.jpg', '.jpeg', '.png']]
        
        if not image_files and split in ['train', 'val']:
            print(f"ERROR: No images found in {images_dir}")
            sys.exit(1)

        split_images = len(image_files)
        total_images += split_images
        print(f"  Found {split_images} images.")

        for img_file in image_files:
            # 2. Images can be opened / 15. Corrupt images
            try:
                with Image.open(img_file) as img:
                    img.verify()
            except UnidentifiedImageError:
                print(f"ERROR: Corrupt image file: {img_file}")
                sys.exit(1)

            # 3. Labels exist
            label_file = labels_dir / f"{img_file.stem}.txt"
            if not label_file.exists():
                print(f"ERROR: Missing label file for image: {img_file.name}")
                sys.exit(1)
                
            total_labels += 1
            
            # 4. Every image has the correct annotation / 5. YOLO bounding box format is valid
            with open(label_file, 'r') as f:
                lines = f.readlines()
                
            for line_idx, line in enumerate(lines):
                parts = line.strip().split()
                if not parts:
                    continue # Empty lines are allowed, denotes no objects
                    
                if len(parts) != 5:
                    print(f"ERROR: Invalid YOLO format in {label_file.name} line {line_idx+1}. Expected 5 values, got {len(parts)}.")
                    sys.exit(1)
                    
                try:
                    class_id = int(parts[0])
                    x_c, y_c, w, h = map(float, parts[1:])
                except ValueError:
                    print(f"ERROR: Non-numeric values in {label_file.name} line {line_idx+1}.")
                    sys.exit(1)
                    
                # 7. Class IDs are valid / 8. Class IDs match data.yaml
                if class_id < 0 or class_id >= nc:
                    print(f"ERROR: Invalid class ID {class_id} in {label_file.name}. Valid range: 0 to {nc-1}.")
                    sys.exit(1)
                    
                # 6. Coordinates are within valid ranges
                if not (0.0 <= x_c <= 1.0 and 0.0 <= y_c <= 1.0 and 0.0 <= w <= 1.0 and 0.0 <= h <= 1.0):
                    print(f"ERROR: Bounding box coordinates out of range [0, 1] in {label_file.name} line {line_idx+1}.")
                    sys.exit(1)
                    
                class_counts[class_id] += 1

    print("\nDataset Validation Summary:")
    print(f"Total Images: {total_images}")
    print(f"Total Labels: {total_labels}")
    
    # 13. Images per class / 14. Bounding boxes per class
    print("\nBounding Boxes Per Class:")
    missing_classes = []
    for c_id, count in class_counts.items():
        print(f"  {names[c_id]} (ID: {c_id}): {count}")
        if count == 0:
            missing_classes.append(names[c_id])
            
    if missing_classes:
        print(f"\nERROR: The following classes have ZERO annotations: {missing_classes}")
        print("A balanced dataset requires at least some annotations for every class.")
        sys.exit(1)
        
    print("\nSUCCESS: Dataset is perfectly valid and ready for training!")

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python validate_dataset.py <path_to_dataset>")
        sys.exit(1)
    
    validate_dataset(sys.argv[1])
