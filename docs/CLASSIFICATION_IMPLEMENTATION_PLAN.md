# Classification Implementation Plan

This plan details the technical steps required to pivot the KrushikaDhara project from an unsupported YOLO Object Detection architecture to a scientifically sound Image Classification architecture based on the provided dataset.

## Phase 1: Data Preparation
1. **Deduplication**: Remove the 83 exact duplicate images identified by MD5 hashing from `Z:\major\images` to prevent data leakage.
2. **Train/Val/Test Split**: Write a Python script (`split_dataset.py`) to systematically split the remaining 1,136 images into 70% Train, 20% Validation, and 10% Test sets, maintaining class stratification.

## Phase 2: Model Training & Evaluation
1. **Script Creation**: Create PyTorch/TensorFlow classification scripts (`train_classifier.py`, `evaluate_classifier.py`).
2. **Model Selection**: Execute training on MobileNetV3 and EfficientNet-Lite0.
3. **Evaluation**: Generate classification metrics (Accuracy, F1-Score, Confusion Matrix).
4. **Quantization**: Export the best performing model using Post-Training Quantization (PTQ) to an INT8 `disease_classifier_int8.tflite` model, using the training set as calibration data.

## Phase 3: Flutter ML Layer Refactor
1. **Modify `tflite_service.dart`**:
   - Delete `LetterboxInfo`, `TensorLayout`, `applyNMS`, and `calculateIoU`.
   - Change input preprocessing to simple RGB resizing (e.g., 224x224) and center cropping, removing letterboxing.
   - Change output decoding from a bounding box array to a 1D probability array `[1, 26]`.
   - Apply `Softmax` (if not baked into the model) and find the `argmax` for the predicted class.
2. **Update Labels**: Overwrite `assets/models/disease_labels.txt` with the 26 alphabetically sorted dataset class names.

## Phase 4: UI Refactor
1. **Modify `disease_detection_screen.dart`**:
   - Delete `BoundingBoxPainter`.
   - Remove the `CustomPaint` overlay from the camera view.
   - Update the bottom sheet to display the classified disease and confidence without bounding box context.

## Phase 5: Disease Database Expansion
1. **Update `disease_data.dart`**:
   - The current database only supports 8 mapped classes. 
   - 12 dataset classes have NO treatment mapping (e.g., `Rice_LeafBlast`, `Wheat_CommonRootRot`).
   - Placeholder treatments must be temporarily added until an agricultural expert can supply the authentic localized treatments for Karnataka farmers.

## Execution
This plan is currently **NOT STARTED**. It requires explicit user authorization to delete the YOLO detection code and execute the architectural refactoring.
