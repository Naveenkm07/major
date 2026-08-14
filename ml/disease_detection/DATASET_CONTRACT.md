# KrushikaDhara Dataset Contract

## 1. Dataset Format
The required format is **YOLOv8 PyTorch** (standard Ultralytics YOLO).
Object bounding boxes are stored as `.txt` files containing annotations in the format:
`class_id x_center y_center width height`
Where `x_center`, `y_center`, `width`, and `height` are normalized to the range `[0, 1]`.

## 2. Required Directory Structure
```
dataset/
├── images/
│   ├── train/
│   ├── val/
│   └── test/  (optional)
├── labels/
│   ├── train/
│   ├── val/
│   └── test/  (optional)
└── data.yaml
```

## 3. Image Requirements
- **Format**: `.jpg`, `.jpeg`, or `.png`.
- **Integrity**: Images must not be corrupted and must be openable by standard image libraries (Pillow, OpenCV).
- **Size**: Preferably standard sizes to easily resize into `640x640` with letterboxing.

## 4. `data.yaml` Specification
The `data.yaml` file MUST sit at the root of the dataset directory and contain:
1. `train`: Path to the `images/train` folder.
2. `val`: Path to the `images/val` folder.
3. `test`: Path to the `images/test` folder (optional).
4. `nc`: The absolute number of classes (e.g., `38`).
5. `names`: A list of the exact class names.

**Example `data.yaml`:**
```yaml
train: ../train/images
val: ../val/images
test: ../test/images

nc: 38
names: ['Apple_Scab', 'Apple_Black_rot', ...]
```

## 5. Class Indexing & Ordering
- **CRITICAL**: The class ordering in the `names` array of `data.yaml` defines the output tensor structure.
- The `class_id` in the label `.txt` files MUST be an integer starting from `0` to `nc-1`.
- The flutter `disease_labels.txt` MUST EXACTLY MATCH the array defined in `data.yaml`.
- The keys in `disease_data.dart` MUST match or map deterministically to these names.

## 6. Dataset Splits & Requirements
- **Minimum Requirement**: A split of at least `train` and `val`.
- **Balance**: Ensure representative images per class. A heavily skewed dataset will perform poorly. Empty classes are strictly prohibited.
- **Pairs**: Every image in `images/` MUST have a correspondingly named `.txt` file in `labels/` (an empty text file denotes an image with no objects/diseases).

## 7. Violation
Any dataset that does not strictly adhere to this format will be rejected by the validation script.
