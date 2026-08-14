# KrushikaDhara Disease Detection ML Pipeline

This directory contains instructions and requirements for training, evaluating, and exporting the YOLOv8 INT8 TFLite model used in the KrushikaDhara mobile application.

## 1. Prerequisites

You will need Python 3.9+ and the Ultralytics library for training YOLOv8.

```bash
pip install ultralytics tensorflow onnx onnx-tf tflite-support
```

## 2. Dataset Preparation

Your dataset should follow standard YOLO format. Structure your data as follows:

```
dataset/
├── images/
│   ├── train/
│   ├── val/
│   └── test/
└── labels/
    ├── train/
    ├── val/
    └── test/
```

Create a `data.yaml` configuration file:

```yaml
path: ./dataset
train: images/train
val: images/val
test: images/test

nc: 38
names: 
  0: 'Apple_Scab'
  1: 'Apple_Black_rot'
  # ... (fill out all 38 classes matching disease_data.dart)
```

## 3. Training the Model

Train the YOLOv8 model with the following command (assuming a `yolov8n.pt` base model):

```bash
yolo task=detect mode=train model=yolov8n.pt data=data.yaml epochs=100 imgsz=640 batch=16
```

### Note on Augmentation
The Ultralytics engine handles augmentation automatically (mosaic, mixup, hsv, etc.). Ensure that these augmentations make sense for your agricultural data (e.g. do not apply extreme sheer or flip operations that might render a leaf unrecognizable).

## 4. Evaluation

After training, evaluate the best model:

```bash
yolo task=detect mode=val model=runs/detect/train/weights/best.pt data=data.yaml
```

Check the generated PR curves, Confusion Matrix, and F1 confidence metrics located in `runs/detect/val/`.

## 5. Exporting to TFLite (INT8)

KrushikaDhara requires a TensorFlow Lite (TFLite) model optimized with INT8 quantization for fast, offline, on-device inference.

Export the model:

```bash
yolo export model=runs/detect/train/weights/best.pt format=tflite int8=True data=data.yaml imgsz=640
```

This will produce a file named `best_saved_model/best_int8.tflite`.

## 6. Deployment to Flutter

Once you have your `best_int8.tflite`:

1. Rename the file to `yolov8_int8.tflite`.
2. Place it into the Flutter app's assets folder: `mobile_app_flutter/assets/models/yolov8_int8.tflite`.
3. Update `mobile_app_flutter/assets/models/disease_labels.txt` to strictly match the 38 classes defined in your `data.yaml` exactly in order.
4. Run the Flutter app. The on-device inference engine will pick it up automatically!

## 7. Troubleshooting

- **Output shape mismatch**: The Flutter app expects a YOLOv8 output tensor of shape `[1, (4 + num_classes), 8400]`. Ensure you export using YOLOv8, NOT an older architecture.
- **Input size mismatch**: The default YOLOv8 input is `640x640`. If you export at `416x416`, you must update the input dimensions in `TFLiteService.dart`.
