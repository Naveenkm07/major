# Classification Class Mapping

This document maps the 26 physical dataset classes discovered in `Z:\major\images` to the 8 hardcoded Flutter application labels in `assets/models/disease_labels.txt` and `lib/data/disease_data.dart`.

| Dataset Class | Flutter Label | Treatment Entry | Mapping Status |
|---|---|---|---|
| Corn___Common_Rust | rust | Yes | AMBIGUOUS (Maps to generic "rust") |
| Corn___Gray_Leaf_Spot | leaf_spot | Yes | AMBIGUOUS (Maps to generic "leaf_spot") |
| Corn___Healthy | healthy | Yes | MATCH |
| Corn___Northern_Leaf_Blight | (none) | No | TREATMENT_MAPPING_MISSING |
| Potato___Early_Blight | (none) | No | TREATMENT_MAPPING_MISSING |
| Potato___Healthy | healthy | Yes | MATCH |
| Potato___Late_Blight | late_blight | Yes | MATCH |
| Rice_BrownSpot | leaf_spot | Yes | AMBIGUOUS |
| Rice_Healthy | healthy | Yes | MATCH |
| Rice_Hispa | (none) | No | TREATMENT_MAPPING_MISSING |
| Rice_LeafBlast | (none) | No | TREATMENT_MAPPING_MISSING |
| Wheat_Aphid | aphids | Yes | MATCH |
| Wheat_BlackRust | rust | Yes | AMBIGUOUS |
| Wheat_Blast | (none) | No | TREATMENT_MAPPING_MISSING |
| Wheat_BrownRust | rust | Yes | AMBIGUOUS |
| Wheat_CommonRootRot | (none) | No | TREATMENT_MAPPING_MISSING |
| Wheat_FusariumHeadBlight | (none) | No | TREATMENT_MAPPING_MISSING |
| Wheat_Healthy | healthy | Yes | MATCH |
| Wheat_LeafBlight | (none) | No | TREATMENT_MAPPING_MISSING |
| Wheat_Mildew | powdery_mildew | Yes | MATCH |
| Wheat_Mite | (none) | No | TREATMENT_MAPPING_MISSING |
| Wheat_Septoria | (none) | No | TREATMENT_MAPPING_MISSING |
| Wheat_Smut | (none) | No | TREATMENT_MAPPING_MISSING |
| Wheat_Stemfly | stem_borer | Yes | AMBIGUOUS (Maps to generic stem borer) |
| Wheat_Tanspot | (none) | No | TREATMENT_MAPPING_MISSING |
| Wheat_YellowRust | rust | Yes | AMBIGUOUS |

## Analysis
The mapping reveals a major disconnect between the 26 available classes and the 8 expected treatments in the database. 12 classes completely lack treatment information (`TREATMENT_MAPPING_MISSING`). 8 classes map ambiguously to generic categories (e.g. `Wheat_BlackRust`, `Wheat_BrownRust`, `Wheat_YellowRust`, and `Corn___Common_Rust` all funnelling into `rust`). Only 6 dataset classes match perfectly with the Flutter definitions.
