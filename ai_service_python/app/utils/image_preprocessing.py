"""
OpenCV-based image preprocessing for crop disease detection.
Provides advanced preprocessing beyond simple resize — histogram equalization,
noise reduction, and optional segmentation for leaf isolation.
"""

import io
import logging
import numpy as np

logger = logging.getLogger(__name__)

# Try OpenCV, fall back to PIL if not installed
try:
    import cv2
    OPENCV_AVAILABLE = True
    logger.info("OpenCV loaded successfully for image preprocessing")
except ImportError:
    OPENCV_AVAILABLE = False
    logger.warning("OpenCV not available. Install with: pip install opencv-python-headless")
    from PIL import Image


def preprocess_image(image_bytes: bytes, target_size: tuple = (224, 224)) -> np.ndarray:
    """
    Preprocess a raw image for CNN inference.

    Pipeline:
        1. Decode raw bytes → BGR array
        2. Convert BGR → RGB
        3. Resize to target_size (224×224 for MobileNet/EfficientNet)
        4. Apply CLAHE (Contrast Limited Adaptive Histogram Equalization)
        5. Gaussian blur for noise reduction
        6. Normalize pixel values to [0, 1]
        7. Add batch dimension → shape (1, H, W, 3)

    Args:
        image_bytes: Raw image bytes from upload
        target_size: Target (width, height) tuple

    Returns:
        np.ndarray of shape (1, H, W, 3) with float32 values in [0, 1]
    """
    if OPENCV_AVAILABLE:
        return _preprocess_opencv(image_bytes, target_size)
    else:
        return _preprocess_pil(image_bytes, target_size)


def _preprocess_opencv(image_bytes: bytes, target_size: tuple) -> np.ndarray:
    """OpenCV-based preprocessing with histogram equalization."""

    # 1. Decode image from bytes
    np_arr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

    if img is None:
        raise ValueError("Failed to decode image. Ensure it is a valid JPEG/PNG/WebP.")

    # 2. Convert BGR → RGB
    img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)

    # 3. Resize to model input size
    img_resized = cv2.resize(img_rgb, target_size, interpolation=cv2.INTER_AREA)

    # 4. Apply CLAHE for contrast enhancement (helps in low-light field photos)
    lab = cv2.cvtColor(img_resized, cv2.COLOR_RGB2LAB)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    lab[:, :, 0] = clahe.apply(lab[:, :, 0])
    img_enhanced = cv2.cvtColor(lab, cv2.COLOR_LAB2RGB)

    # 5. Gaussian blur for noise reduction
    img_smooth = cv2.GaussianBlur(img_enhanced, (3, 3), 0)

    # 6. Normalize to [0, 1]
    img_normalized = img_smooth.astype(np.float32) / 255.0

    # 7. Add batch dimension
    return np.expand_dims(img_normalized, axis=0)


def _preprocess_pil(image_bytes: bytes, target_size: tuple) -> np.ndarray:
    """PIL fallback when OpenCV is not available."""
    image = Image.open(io.BytesIO(image_bytes))
    image = image.convert("RGB")
    image = image.resize(target_size, Image.LANCZOS)
    img_array = np.array(image, dtype=np.float32) / 255.0
    return np.expand_dims(img_array, axis=0)


def extract_leaf_mask(image_bytes: bytes) -> np.ndarray:
    """
    Optional: Extract leaf region using green color segmentation.
    Useful for isolating the leaf from background for more accurate detection.

    Returns:
        Binary mask of the leaf region.
    """
    if not OPENCV_AVAILABLE:
        raise RuntimeError("OpenCV required for leaf segmentation")

    np_arr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)
    hsv = cv2.cvtColor(img, cv2.COLOR_BGR2HSV)

    # Green color range for leaf detection
    lower_green = np.array([25, 40, 40])
    upper_green = np.array([85, 255, 255])

    mask = cv2.inRange(hsv, lower_green, upper_green)

    # Morphological operations to clean up
    kernel = cv2.getStructuringElement(cv2.MORPH_ELLIPSE, (5, 5))
    mask = cv2.morphologyEx(mask, cv2.MORPH_CLOSE, kernel, iterations=2)
    mask = cv2.morphologyEx(mask, cv2.MORPH_OPEN, kernel, iterations=1)

    return mask
