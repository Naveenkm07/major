# Final End-To-End ML Audit

## Dataset Truth
- **Total images:** 1,219 original images.
- **Number of classes:** 26 physical class folders, however 1 class (`Wheat_Septoria`) had only 3 images which were exact byte-for-byte duplicates of `Wheat_LeafBlight`.
- **Duplicate count:** 83 exact duplicates removed via MD5 hashing.
- **True classes trained:** 25 unique distinct classes.
- **Train count:** 789 images
- **Validation count:** 164 images
- **Test count:** 183 images
- **Structure Check:** Verified as `class_name/image.jpg`.

## Class Index Contract
The class mismatch was actively discovered and fixed during this audit.
The original `disease_labels.txt` contained only 8 fake classes. It has now been programmatically generated from the actual training directory (`Z:/major/dataset_split/train/`).
`disease_data.dart` has been updated by stripping out the duplicate `Wheat_Septoria` class, ensuring it perfectly maps the 25 output classes.

## Verify the Trained Model
The model exported is `best_model.pt` and `best_model.onnx`.
- **Architecture:** MobileNetV3-Small (Classification)
- **Input shape:** `[1, 3, 224, 224]`
- **Output shape:** `[1, 25]` (Correctly maps to the 25 unique dataset classes)
- **Status:** The model contains real trained weights from a successful PyTorch training run.

## Determine the Actual Model Format
- `best_model.onnx` physically exists at `ml/disease_detection/output/best_model.onnx` (317,007 bytes).
- A real `crop_disease_classifier_int8.tflite` model **DOES NOT EXIST**. The `assets/models/yolov8_int8.tflite` file currently is an empty 0-byte fake artifact that was cleared.

## Convert ONNX to TFLite
**BLOCKED.** The environment relies on Python 3.14.6, which actively prevents the installation of `tensorflow`, `onnx_tf`, or `ai-edge-torch`. 
I have not fabricated a `.tflite` model. I have created `convert_onnx_to_tflite.py` designed specifically to run in an external Google Colab / Python 3.10 environment to complete the conversion.
