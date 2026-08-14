# KrushikaDhara ML Training Readiness Report

## 1. Authoritative Class Count
**UNRESOLVED**
Project documentation claims 38 classes, but the codebase implements 8 generic classes.

## 2. Class List
**UNRESOLVED**
Cannot be proven without the actual dataset's `data.yaml` or a definitive mapping to PlantVillage classes.

## 3. Dataset Status
**MISSING**
No images, labels, or YAML configurations are present in the repository.

## 4. Dataset Structure Required
**READY**
A strict standard YOLOv8 PyTorch structure is required, validated by `ml/disease_detection/validate_dataset.py`. See `DATASET_CONTRACT.md`.

## 5. Training Pipeline Status
**READY (Awaiting Data)**
`train_yolov8.py` is fully implemented and relies on the `ultralytics` package to train the Nano model based on the dataset YAML.

## 6. Evaluation Pipeline Status
**READY (Awaiting Model/Data)**
`evaluate_model.py` is implemented to calculate genuine mAP, F1, Precision, and Recall using the trained PyTorch checkpoint.

## 7. TFLite Export Pipeline Status
**READY (Awaiting Model/Data)**
`export_tflite.py` handles the crucial INT8 quantization utilizing the genuine dataset for proper activation calibration.

## 8. Current Model Status
**MISSING**
There is no trained `.pt` or `.tflite` model that actually performs object detection.

## 9. Current Dummy Model Status
**TESTING/DEVELOPMENT ONLY**
`generate_tflite.py` is present strictly to generate a `tf.zeros` output so the Flutter application can compile and load the TFLite interpreter during UI/UX development.

## 10. Flutter Compatibility Status
**READY (With Dynamic Support)**
The Flutter TFLite service (`tflite_service.dart`) handles RGB conversion, letterboxing, dynamic tensor inspection (`[1, C, N]` or `[1, N, C]`), INT8 dequantization, and IoU NMS mathematically.
`verify_flutter_model.py` provides cross-boundary compatibility checking to ensure the final exported model meets the app's expectations.

## 11. Exact Remaining Blockers
- **Blocker 1**: A real, physical dataset containing images and YOLO `.txt` labels must be provided and validated.
- **Blocker 2**: The dataset's `data.yaml` must be utilized to definitively lock in the class count and labels array.
- **Blocker 3**: The training pipeline must be run on a GPU to produce the real `best.pt`.
- **Blocker 4**: The real model must be quantized to INT8 and placed into the Flutter assets directory, replacing the mock model.
- **Blocker 5**: `disease_labels.txt` and `disease_data.dart` must be updated to align perfectly with the dataset's `data.yaml` `names` array.

## Conclusion
> **REAL DISEASE PREDICTION: NOT PROVEN**
> The tooling and inference pipelines are built, completely mapped, and ready for deployment. However, the system fundamentally lacks the intelligent dataset and trained model required to detect diseases. Training and inference MUST NOT be claimed as complete until actual physical data is provided and validated.
