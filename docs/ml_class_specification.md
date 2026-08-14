# ML Class Specification

## Authoritative Class Count
**STATUS: UNRESOLVED**

## Background
The KrushikaDhara project documentation (`disease_detection_report.md` and `disease_detection.md`) explicitly cites a goal of detecting **38 localized crop diseases** utilizing a combination of field-collected Karnataka leaf images and PlantVillage transfer learning data.

However, the current functional implementation within the Flutter app (`lib/data/disease_data.dart` and `disease_labels.txt`) contains only **8 generic classes**:
1. healthy
2. bacterial_blight
3. leaf_spot
4. rust
5. powdery_mildew
6. late_blight
7. aphids
8. stem_borer

## Unresolved Issues
Without the authoritative `data.yaml` from the genuine YOLOv8 dataset or the exact PlantVillage class map intended for the 38 classes, the true class list cannot be proven or mapped to localized treatments.

The dataset classes must eventually map perfectly 1:1 with the output tensor of the `.tflite` model and the Flutter app's `disease_labels.txt`.

**Action Required:**
Do NOT modify the 8 classes in `disease_data.dart` or `disease_labels.txt` until the genuine dataset provides the absolute 38-class specification.
