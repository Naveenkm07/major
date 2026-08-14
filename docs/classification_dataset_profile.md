# Classification Dataset Profile

## 1. Verified Dataset Overview
- **Location:** `Z:\major\images`
- **Total Image Count:** 1,219
- **Number of Classes:** 26
- **Duplicate Images:** 83 exact file duplicates found via MD5 hashing.
- **Corrupted Images:** 0 (all 1,219 images opened successfully with PIL during inspection).
- **Image Formats:** `.jpg`, `.png`
- **Image Dimensions:** Widely variable, ranging from small (e.g., 256x256, 300x225) to high-resolution (e.g., 6000x4000).

## 2. Class Breakdown (Alphabetical)
1. `Corn___Common_Rust`: 50 images
2. `Corn___Gray_Leaf_Spot`: 38 images
3. `Corn___Healthy`: 50 images
4. `Corn___Northern_Leaf_Blight`: 50 images
5. `Potato___Early_Blight`: 50 images
6. `Potato___Healthy`: 50 images
7. `Potato___Late_Blight`: 50 images
8. `Rice_BrownSpot`: 50 images
9. `Rice_Healthy`: 35 images
10. `Rice_Hispa`: 50 images
11. `Rice_LeafBlast`: 50 images
12. `Wheat_Aphid`: 49 images
13. `Wheat_BlackRust`: 50 images
14. `Wheat_Blast`: 44 images
15. `Wheat_BrownRust`: 50 images
16. `Wheat_CommonRootRot`: 50 images
17. `Wheat_FusariumHeadBlight`: 50 images
18. `Wheat_Healthy`: 50 images
19. `Wheat_LeafBlight`: 50 images
20. `Wheat_Mildew`: 50 images
21. `Wheat_Mite`: 50 images
22. `Wheat_Septoria`: 3 images
23. `Wheat_Smut`: 50 images
24. `Wheat_Stemfly`: 50 images
25. `Wheat_Tanspot`: 50 images
26. `Wheat_YellowRust`: 50 images

## 3. Dataset Characteristics
- **Minimum images/class:** 3 (`Wheat_Septoria`)
- **Maximum images/class:** 50
- **Average images/class:** ~46.8
- **Format:** Purely classification (organized into subfolders by class).
- **Object Detection Viability:** The dataset contains ZERO bounding box annotations (no YOLO `.txt` files, no COCO `.json`, no VOC `.xml`). It strictly supports Image Classification natively.
