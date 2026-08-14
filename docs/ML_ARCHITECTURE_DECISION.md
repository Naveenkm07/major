# KrushikaDhara ML Architecture Decision

## 1. Current Application Architecture
The KrushikaDhara Flutter application currently implements a YOLO Object Detection architecture. 
- The camera feed captures images which are preprocessed with RGB conversion and letterboxing. 
- The `TFLiteService` decodes a multi-dimensional bounding-box tensor (`[1, 8400, C]` or `[1, C, 8400]`), extracts bounding box coordinates, applies confidence filtering, and executes Intersection over Union (IoU) Non-Maximum Suppression (NMS).
- The UI (in `disease_detection_screen.dart`) then draws a physical green bounding box over the diseased part of the leaf. 
- The bounding box visualization is deeply integrated as a core UI feature of the detection screen, but it is purely an implementation choice made by the developer, not a hard agricultural necessity for treatment prediction.

## 2. Actual Dataset
- **Image count:** 1,219
- **Class count:** 26
- **Annotation type:** Folders only (Classification). ZERO bounding boxes.
- **Duplicates:** 83 exact file duplicates.
- **Class names:** `Corn___Common_Rust`, `Wheat_Aphid`, `Potato___Late_Blight`, etc. (See `classification_dataset_profile.md` for full list).

## 3. Dataset Compatibility
- **YOLO detection:** **INCOMPATIBLE**. Object detection mathematically requires spatial annotations (x, y, w, h). They do not exist here.
- **Classification:** **COMPATIBLE**. The dataset is already perfectly structured for image classification tasks (1 label per image, indicated by folder name).

## 4. Option A — YOLOv8 Detection
- **Advantages:** Provides spatial context (shows exactly *where* the disease is on the leaf), which increases user trust. Can detect multiple diseases on a single leaf.
- **Disadvantages:** Much heavier model, requires complex NMS post-processing, much harder to annotate.
- **Dataset requirements:** Requires drawing bounding boxes on thousands of images manually.
- **Project compatibility:** Fully supported by the current codebase, but completely unsupported by the current dataset.

## 5. Option B — CNN/Image Classification
- **Advantages:** Solves the core business problem (identifying the disease to prescribe treatment). Faster inference, smaller model size, works perfectly with the existing dataset.
- **Disadvantages:** Loses the visual "bounding box" overlay in the UI. Assumes one primary disease per image.
- **Dataset requirements:** Simply requires images placed in labeled folders (which we already have).
- **Project compatibility:** Requires refactoring `tflite_service.dart` to decode a 1D probability array `[1, num_classes]` instead of a bounding box matrix. Requires removing the bounding box painter from the UI.

## 6. Candidate Models
- **Custom CNN:** 
  - *Pros:* Tiny footprint (< 1MB), fast. 
  - *Cons:* Usually lacks the depth to generalize well across 26 complex plant diseases.
- **MobileNetV3:** 
  - *Pros:* Highly optimized for mobile CPUs, fast, excellent balance of size and accuracy, native INT8 support.
  - *Cons:* Slightly less accurate on fine-grained textures than EfficientNet.
- **EfficientNet-Lite:** 
  - *Pros:* Very high accuracy, specifically designed to eliminate operators that don't quantize well to INT8 on mobile.
  - *Cons:* Slower inference speed than MobileNet.

## 7. 26 vs 38 Classes
The documentation originally referenced 38 diseases, but the provided Kaggle dataset physically only contains 26. The 38-class requirement appears to be a planned future scope or a theoretical research target that was documented prior to acquiring the physical dataset. The current dataset is categorically insufficient for the stated 38-class requirement.

## 8. Recommended Architecture
**Option B — Image Classification (MobileNetV3 or EfficientNet-Lite0)**

## 9. Why This Architecture
We must optimize for making the KrushikaDhara project scientifically correct and honest based on the data actually available. The dataset has zero bounding boxes. Training an object detector is impossible without fabricating annotations, which is strictly forbidden. Image classification natively fits the dataset provided, is faster on mobile edge devices, and still achieves the primary project goal: identifying the disease to recommend the correct agricultural treatment.

## 10. Required Changes
- `mobile_app_flutter/lib/services/tflite_service.dart`: Must be completely rewritten to drop NMS/IoU/letterbox logic and instead process a flat probability vector `[1, NUM_CLASSES]`.
- `mobile_app_flutter/lib/screens/crop_disease/disease_detection_screen.dart`: Must remove `BoundingBoxPainter` and bounding box overlay logic.
- `mobile_app_flutter/lib/data/disease_data.dart`: Must be updated to include treatment entries for the 12 missing dataset classes.
- `mobile_app_flutter/assets/models/disease_labels.txt`: Must be rewritten to reflect the 26 dataset classes alphabetically.
- `ml/disease_detection/`: The YOLO training scripts must be replaced with PyTorch/TensorFlow classification scripts.

## 11. Dataset Requirements
To proceed with Classification, the dataset requires:
1. Pruning of the 83 duplicate images to prevent data leakage.
2. An evidence-based train/validation/test split.
3. Agricultural domain expertise to supply the missing treatment data for classes like `Rice_LeafBlast` and `Wheat_Septoria`.

## 12. Research Experiment Plan
To guarantee the highest accuracy, we will execute the following pipeline:
**Baseline Custom CNN** -> **MobileNetV3-Small** -> **EfficientNet-Lite0** -> **Compare**

*Metrics to track:*
- Accuracy (Top-1)
- Precision, Recall, F1-Score (macro average across 26 classes)
- Confusion Matrix (to find inter-class confusion, e.g., between different Wheat rusts)
- Model Size (MB, post-INT8 quantization)
- Inference Latency (ms on Android CPU)
