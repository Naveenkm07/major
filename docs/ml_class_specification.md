# ML Class Specification

## Authoritative Class Count
**STATUS: RESOLVED — 26 classes (as of September 2026 pilot)**

---

## Final Class List (26 Classes — Pilot Implementation)

These are the authoritative class names used across:
- `ml/disease_detection/train_classifier.py` (PyTorch training)
- `mobile_app_flutter/assets/models/disease_labels.txt` (TFLite inference)
- `mobile_app_flutter/lib/data/disease_data.dart` (treatment lookup)

| Index | Class Name | Crop |
|-------|-----------|------|
| 0 | Corn___Common_Rust | Corn |
| 1 | Corn___Gray_Leaf_Spot | Corn |
| 2 | Corn___Healthy | Corn |
| 3 | Corn___Northern_Leaf_Blight | Corn |
| 4 | Potato___Early_Blight | Potato |
| 5 | Potato___Healthy | Potato |
| 6 | Potato___Late_Blight | Potato |
| 7 | Rice_BrownSpot | Rice |
| 8 | Rice_Healthy | Rice |
| 9 | Rice_Hispa | Rice |
| 10 | Rice_LeafBlast | Rice |
| 11 | Wheat_Aphid | Wheat |
| 12 | Wheat_BlackRust | Wheat |
| 13 | Wheat_Blast | Wheat |
| 14 | Wheat_BrownRust | Wheat |
| 15 | Wheat_CommonRootRot | Wheat |
| 16 | Wheat_FusariumHeadBlight | Wheat |
| 17 | Wheat_Healthy | Wheat |
| 18 | Wheat_LeafBlight | Wheat |
| 19 | Wheat_Mildew | Wheat |
| 20 | Wheat_Mite | Wheat |
| 21 | Wheat_Septoria | Wheat |
| 22 | Wheat_Smut | Wheat |
| 23 | Wheat_Stemfly | Wheat |
| 24 | Wheat_Tanspot | Wheat |
| 25 | Wheat_YellowRust | Wheat |

---

## Model Architecture
- **Architecture**: MobileNetV3-Small (ImageNet pretrained, transfer-learned)
- **Input**: `[1, 224, 224, 3]` — RGB, ImageNet-normalized
- **Output**: `[1, 26]` — class probability vector (softmax)
- **Quantization**: INT8 (`tf.lite.Optimize.DEFAULT`)
- **Asset**: `mobile_app_flutter/assets/models/mobilenet_v3_int8.tflite`

---

## Dataset Source
- **Base**: Kaggle PlantVillage (modified)
- **Location**: `Z:\major\images` → split into `ml/disease_detection/dataset_split/` (train/val/test)
- **Total images**: 1,219 (83 duplicates removed before split)
- **Split ratio**: 70/15/15 (train/val/test)

---

## Notes on Pilot vs. IEEE Paper Claims
The IEEE paper (Section III-B) initially referenced 38 classes — this was the **full production target** for the multi-season extension. The pilot implementation (and this codebase) implements **26 classes** covering the four primary crops in the Chitradurga and Tumkur districts used during the 6-week field trial. The paper text has been corrected to state "26 disease classes" for accuracy.
