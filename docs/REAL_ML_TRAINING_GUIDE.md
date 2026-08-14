# Real ML Training & Deployment Guide

This guide details the complete end-to-end pipeline for converting a raw dataset of plant disease images into a robust, edge-quantized INT8 `.tflite` model deployed locally within the KrushikaDhara Flutter application.

## Pipeline Overview

`DATASET` ➔ `VALIDATION` ➔ `YOLOv8 TRAINING` ➔ `VALIDATION` ➔ `BEST.PT` ➔ `INT8 TFLITE EXPORT` ➔ `TFLITE INSPECTION` ➔ `FLUTTER COMPATIBILITY CHECK` ➔ `PHYSICAL DEVICE TEST`

---

## 1. DATASET
Before you begin, ensure you have a valid YOLO-formatted dataset containing `images/` and `labels/` directories, alongside a `data.yaml` specifying the classes. 

See `ml/disease_detection/DATASET_CONTRACT.md` for exact formatting rules.

---

## 2. VALIDATION
Do not train blindly. Run the strict dataset validation script to ensure bounding boxes are normalized correctly and classes are balanced.

```bash
cd ml/disease_detection
python validate_dataset.py /path/to/your/dataset
```
**Expected Outcome:** `SUCCESS: Dataset is perfectly valid and ready for training!`

---

## 3. YOLOv8 TRAINING & VALIDATION
We use the Ultralytics YOLOv8 nano (`yolov8n.pt`) checkpoint as our base, because its small size and fast CPU execution makes it ideal for mobile Flutter apps.

Run the training script (supports CPU, GPU, or Multi-GPU):
```bash
# Example training on GPU 0 with batch 16 for 100 epochs
python train_yolov8.py \
    --data /path/to/your/dataset/data.yaml \
    --epochs 100 \
    --batch 16 \
    --imgsz 640 \
    --device 0
```
**Expected Outcome:** The script will output a PyTorch checkpoint named `best.pt` in `runs/train/krushikadhara_run/weights/best.pt`.

### Evaluate The Model (mAP, F1)
You can evaluate your `best.pt` checkpoint on the `test` or `val` split explicitly:
```bash
python evaluate_model.py \
    --model runs/train/krushikadhara_run/weights/best.pt \
    --data /path/to/your/dataset/data.yaml \
    --split test
```

---

## 4. INT8 TFLITE EXPORT
Mobile CPUs are extremely fast when executing 8-bit quantized integer math, but drastically slower with 32-bit floats. We must convert `best.pt` to `yolov8_int8.tflite`. 

**CRITICAL:** INT8 quantization requires the `data.yaml` to provide a "representative dataset" so the converter can calculate real activation scales.
```bash
python export_tflite.py \
    --model runs/train/krushikadhara_run/weights/best.pt \
    --data /path/to/your/dataset/data.yaml \
    --imgsz 640
```
**Expected Outcome:** A file named something like `best_saved_model/best_int8.tflite`. Rename this to `yolov8_int8.tflite`.

---

## 5. TFLITE INSPECTION
Before dropping the model into Flutter, verify what the exporter actually created. The input and output tensor shapes determine if the Flutter app will crash.

```bash
python inspect_tflite.py --model path/to/yolov8_int8.tflite
```
**Expected Outcome:** You should see `Input: [1, 640, 640, 3] INT8` and `Output: Rank 3 INT8`.

---

## 6. FLUTTER COMPATIBILITY CHECK
Run the official cross-compatibility check against the exact Flutter labels file to guarantee the pipeline is mathematically sound.

```bash
# Ensure the labels file has been updated to match your data.yaml before running
python verify_flutter_model.py \
    --model path/to/yolov8_int8.tflite \
    --labels ../../mobile_app_flutter/assets/models/disease_labels.txt
```
**Expected Outcome:** `✅ COMPATIBLE`

---

## 7. PHYSICAL DEVICE TEST
1. Move your verified `yolov8_int8.tflite` to `mobile_app_flutter/assets/models/yolov8_int8.tflite`.
2. Update `disease_labels.txt` with your exact `data.yaml` class names.
3. Update `lib/data/disease_data.dart` to contain matching localized treatments for your classes.
4. Run the app on a physical Android or iOS device (not an emulator, as emulators lack accurate camera APIs and TFLite hardware acceleration).

```bash
cd mobile_app_flutter
flutter run --release
```
Point the camera at a diseased leaf. A bounding box and treatment sheet should immediately appear offline!
