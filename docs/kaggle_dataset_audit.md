# Kaggle Dataset Audit

## Real Dataset Statistics

- **Total Image Count:** 1,219
- **Total Annotation Count:** 0
- **Number of Classes:** 26
- **Dataset Format:** Classification-only (images organized in folders by class name). No YOLO/COCO/VOC annotations exist.

## Class Breakdown

| Class Name | Image Count | Annotation Count |
|---|---|---|
| Corn___Common_Rust | 50 | 0 |
| Corn___Gray_Leaf_Spot | 38 | 0 |
| Corn___Healthy | 50 | 0 |
| Corn___Northern_Leaf_Blight | 50 | 0 |
| Potato___Early_Blight | 50 | 0 |
| Potato___Healthy | 50 | 0 |
| Potato___Late_Blight | 50 | 0 |
| Rice_BrownSpot | 50 | 0 |
| Rice_Healthy | 35 | 0 |
| Rice_Hispa | 50 | 0 |
| Rice_LeafBlast | 50 | 0 |
| Wheat_Aphid | 49 | 0 |
| Wheat_BlackRust | 50 | 0 |
| Wheat_Blast | 44 | 0 |
| Wheat_BrownRust | 50 | 0 |
| Wheat_CommonRootRot | 50 | 0 |
| Wheat_FusariumHeadBlight | 50 | 0 |
| Wheat_Healthy | 50 | 0 |
| Wheat_LeafBlight | 50 | 0 |
| Wheat_Mildew | 50 | 0 |
| Wheat_Mite | 50 | 0 |
| Wheat_Septoria | 3 | 0 |
| Wheat_Smut | 50 | 0 |
| Wheat_Stemfly | 50 | 0 |
| Wheat_Tanspot | 50 | 0 |
| Wheat_YellowRust | 50 | 0 |

## Dataset Insights
- **Minimum images/class:** 3 (Wheat_Septoria)
- **Maximum images/class:** 50
- **Average images/class:** 46.88
- **Class Imbalance:** Moderate. Most classes have exactly 50 images, but a few have fewer (e.g., Wheat_Septoria has 3).
- **Image dimensions:** Varies widely, including (1920, 1080), (4000, 3000), (6000, 4000), etc.
- **Image formats:** `.jpg`, `.png`

## Dataset Type Conclusion
Dataset supports image classification but does not directly provide object-detection bounding boxes. The KrushikaDhara Flutter app requires bounding boxes, so a YOLO object detector cannot be trained directly on this data.
