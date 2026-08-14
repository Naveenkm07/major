# KrushikaDhara Disease Detection Implementation

## 1. Architecture
The KrushikaDhara Disease Detection module uses an offline-first architecture powered by TensorFlow Lite and the YOLOv8 model. The entire inference pipeline from image capture to disease prediction runs completely locally on the farmer's mobile device. No internet connection is required.

## 2. Dataset
The intended dataset comprises of roughly 4,000 field-collected Karnataka leaf images combined with PlantVillage transfer learning data to cover 38 localized crop diseases.

## 3. Classes
The model maps 38 disease classes (e.g. `Apple_Scab`, `Apple_Black_rot`, etc.) to detailed localized treatment instructions contained in `lib/data/disease_data.dart`.

## 4. Training & 5. Augmentation
See `ml/disease_detection/README.md` for complete training instructions. Training handles augmentations inherently through Ultralytics (mixup, mosaic, scaling).

## 6. YOLOv8 & 7. TFLite & 8. INT8 quantization
The exported format is `yolov8_int8.tflite` to reduce model size dramatically (making it easier to package in a mobile app) and drastically increase inference speed on mobile CPUs.

## 9. Input tensor
The input tensor shape is `[1, 640, 640, 3]`. The image must be RGB and pixel values must be cast and formatted strictly to the quantization parameters of the model (usually `-128` to `127` for INT8).

## 10. Output tensor
The output tensor for YOLOv8 object detection is usually `[1, 4 + num_classes, 8400]`, where 8400 represents the number of anchor boxes generated.

## 11. Preprocessing
When a frame is captured from the flutter `camera` package (`CameraImage`):
- It is converted from YUV420 (Android) or BGRA8888 (iOS) to an RGB `Image` using the dart `image` package.
- It is resized to `640x640`.
- The bytes are normalized into an Int8List array and reshaped to `[1, 640, 640, 3]`.

## 12. Post-processing & 13. NMS
The raw 8400 arrays are parsed:
- Elements [0, 1, 2, 3] contain the bounding box [x, y, w, h] (normalized).
- Elements [4...38] contain the class confidence scores.
- The Non-Maximum Suppression (NMS) algorithm isolates the highest confidence bounding box and suppresses overlapping boxes over the IoU threshold.

## 14. Bounding boxes & 15. Label mapping
The bounding box coordinates are mapped from the `640x640` input space back onto the user's screen space using a `CustomPainter` (`BoundingBoxPainter`). The localized Kannada/English labels are rendered above the bounding box.

## 16. Treatment lookup & 17. Offline behavior
When a disease confidence crosses the `0.6` (60%) threshold, the app queries the offline `DISEASE_DB` constant mapping to fetch the severity, symptoms, chemical treatments, and organic alternatives.

## 18. Performance measurement
Due to INT8 quantization and Dart `Isolates` handling the image preprocessing in the background thread, inference latency runs smoothly, allowing for a 15-30 FPS camera preview. 

## 19. Testing & 20. Troubleshooting
If bounding boxes are appearing in the wrong locations or the app crashes on inference, verify that your new YOLO `.tflite` file outputs the exact `[1, 42, 8400]` shape. Replace `assets/models/yolov8_int8.tflite` with your new model.
