# KrushikaDhara: Final Production ML Verification

## 1. DATASET
- **Total Physical Images:** 1,219 images verified on disk.
- **Classes:** 25 true classes (Duplicate `Wheat_Septoria` was investigated and eliminated).
- **Split:** `dataset_split/train`, `dataset_split/val`, `dataset_split/test`.

## 2. MODEL ARCHITECTURE & ASSETS
- **Architecture:** MobileNetV3-Small (Image Classification).
- **PyTorch File:** `ml/disease_detection/output/best_model.pt` (Verified).
- **ONNX File:** `ml/disease_detection/output/best_model.onnx` (Verified).
- **TFLite File:** `mobile_app_flutter/assets/models/crop_disease_classifier_int8.tflite` (Blocked pending Colab conversion).
- **Input Shape:** `[1, 3, 224, 224]` (ONNX). Expected `[1, 224, 224, 3]` or `[1, 3, 224, 224]` (TFLite).
- **Output Shape:** `[1, 25]`.

## 3. PREPROCESSING CONTRACT
- **Resize:** 224x224.
- **Normalization:** ImageNet Mean `[0.485, 0.456, 0.406]`, Std `[0.229, 0.224, 0.225]`.
- **Channel Order:** RGB.
- **Tensor Layout:** TFLite Service implemented dynamically to handle quantization scales.

## 4. PERFORMANCE
- **PyTorch Accuracy:** 69.4%
- **Weighted F1 Score:** 0.67
- **TFLite Metrics:** PENDING (Waiting for TFLite file to run `verify_tflite.py`).

## 5. CONVERSION AGREEMENT
- **PyTorch vs ONNX:** PENDING.
- **PyTorch vs TFLite:** PENDING.
- **ONNX vs TFLite:** PENDING.

*(Will be computed by `verify_tflite.py` once model is converted).*

## 6. FLUTTER INTEGRATION
- **Model Asset Present:** No (Waiting for TFLite file).
- **Labels Match:** YES. `disease_labels.txt` contains exactly 25 classes.
- **Disease Data Mapping Match:** YES. `disease_data.dart` handles the 25 classes without YOLO/NMS bounds.
- **Flutter Test Result:** 100% PASSED (`tflite_service_test.dart`).
- **Dart Analyze Result:** PASSED (Only deprecation/context warnings, 0 compilation errors).

## 7. DEVICE VALIDATION
- **Android Physical Test:** PENDING
- **iOS Physical Test:** PENDING
- **Camera Test:** PENDING
- **Gallery Test:** PENDING

## FINAL STATUS
🟡 **BLOCKED — TFLITE CONVERSION REQUIRED**

### Next Steps:
1. Upload `colab_convert_tflite.ipynb` to Google Colab.
2. Upload `best_model.onnx` and `dataset_split/test/` to Colab.
3. Run the notebook to generate `crop_disease_classifier_int8.tflite`.
4. Download the generated `.tflite` file and place it in `mobile_app_flutter/assets/models/`.
5. Run `python ml/disease_detection/verify_tflite.py` locally (or in a compatible environment) to validate PyTorch vs ONNX vs TFLite agreement and generate the final report.
6. Test on a physical device.
