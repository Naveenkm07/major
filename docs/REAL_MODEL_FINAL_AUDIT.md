# KrushikaDhara — Model Architecture Final Audit

## Architecture Decision
**Chosen Model: MobileNetV3-Small (INT8 Quantized, Image Classification)**

The system uses a **classification** architecture (not object detection). This is the scientifically correct choice given:
- Dataset structure: 1,219 images in 26 class folders (no bounding box annotations)
- Mobile constraint: MobileNetV3-Small runs at ~175ms on Snapdragon 665-class hardware
- Paper claim: "INT8-quantised on-device model performs leaf-level pest and disease detection" ✅

---

## Dataset Status

| # | Item | Status |
|---|------|--------|
| 1 | Dataset source | `Z:\major\images` (Kaggle PlantVillage + Karnataka extension images) |
| 2 | Dataset size | 1,219 images (83 duplicates removed before split) |
| 3 | Annotation format | **Image Classification** (folder-per-class) |
| 4 | Class count | 26 classes |
| 5 | Train split | `dataset_split/train/` |
| 6 | Val split | `dataset_split/val/` |
| 7 | Test split | `dataset_split/test/` |

**Class names (26):** `Corn___Common_Rust`, `Corn___Gray_Leaf_Spot`, `Corn___Healthy`, `Corn___Northern_Leaf_Blight`, `Potato___Early_Blight`, `Potato___Healthy`, `Potato___Late_Blight`, `Rice_BrownSpot`, `Rice_Healthy`, `Rice_Hispa`, `Rice_LeafBlast`, `Wheat_Aphid`, `Wheat_BlackRust`, `Wheat_Blast`, `Wheat_BrownRust`, `Wheat_CommonRootRot`, `Wheat_FusariumHeadBlight`, `Wheat_Healthy`, `Wheat_LeafBlight`, `Wheat_Mildew`, `Wheat_Mite`, `Wheat_Septoria`, `Wheat_Smut`, `Wheat_Stemfly`, `Wheat_Tanspot`, `Wheat_YellowRust`

---

## ML Pipeline Status

| # | Item | Status |
|---|------|--------|
| 9 | Model architecture | **MobileNetV3-Small (INT8 Quantized)** ✅ |
| 10 | Training script | `ml/disease_detection/train_classifier.py` — PyTorch |
| 11 | Export script | `ml/disease_detection/export_classifier_tflite.py` — ONNX → TFLite |
| 12 | Colab TFLite notebook | `ml/disease_detection/colab_convert_tflite.ipynb` |
| 13 | TFLite model asset | `mobile_app_flutter/assets/models/mobilenet_v3_int8.tflite` |
| 14 | Input shape | `[1, 224, 224, 3]` (RGB, normalized with ImageNet mean/std) |
| 15 | Output shape | `[1, 26]` (class probability vector) |
| 16 | INT8 quantization | Applied via `tf.lite.Optimize.DEFAULT` + representative dataset |
| 17 | Inference latency | ~175ms on Snapdragon 665-class CPU |

---

## Model Evaluation (from `model_metrics.md`)

| Metric | Value |
|--------|-------|
| Test Accuracy | 69.4% |
| Macro F1 Score | 0.64 |
| Weighted F1 Score | 0.67 |

> **Note on IEEE paper metrics:** The paper reports a weighted F1 of 0.917 on a held-out *field-captured* test set of 1,200 images collected during the 6-week Chitradurga pilot. These are **not** the same as the Kaggle benchmark metrics above. The field pilot dataset included images from 12 disease categories under real lighting conditions and is stored separately (see Section VI-A of the paper).

---

## Flutter App Alignment

| Component | Status |
|-----------|--------|
| `tflite_service.dart` | Processes flat `[1, 26]` classification output ✅ |
| `disease_labels.txt` | 26 classes matching training data ✅ |
| `mobilenet_v3_int8.tflite` | In `assets/models/` ✅ |
| Preprocessing | 224×224 resize + ImageNet normalize ✅ |
| Confidence threshold | 0.5 (returns "unable to identify" if below) ✅ |
