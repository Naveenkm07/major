import io
import numpy as np
from PIL import Image


def preprocess_image(image_bytes: bytes, target_size: tuple = (224, 224)) -> np.ndarray:
    """
    Preprocess an image for model inference.
    - Converts to RGB
    - Resizes to target size
    - Normalizes pixel values to [0, 1]
    """
    image = Image.open(io.BytesIO(image_bytes))
    image = image.convert("RGB")
    image = image.resize(target_size)
    img_array = np.array(image, dtype=np.float32) / 255.0
    return np.expand_dims(img_array, axis=0)


def validate_image(image_bytes: bytes, max_size_mb: int = 5) -> bool:
    """Validate that the uploaded bytes form a valid image under size limit."""
    if len(image_bytes) > max_size_mb * 1024 * 1024:
        return False
    try:
        Image.open(io.BytesIO(image_bytes)).verify()
        return True
    except Exception:
        return False
