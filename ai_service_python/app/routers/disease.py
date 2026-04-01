"""
Pest/Disease Detection Router
POST /api/v1/detect_pest — JWT-protected, multipart/form-data image upload
"""

import logging
from fastapi import APIRouter, Depends, File, UploadFile, HTTPException, status
from app.auth import verify_jwt, AuthenticatedUser
from app.models.schemas import PestDetectionResponse, ErrorResponse
from app.services.disease_service import disease_service
from app.services.s3_service import s3_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1", tags=["Pest Detection"])

# Allowed image MIME types
ALLOWED_TYPES = {"image/jpeg", "image/png", "image/webp", "image/jpg"}
MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB


@router.post(
    "/detect_pest",
    response_model=PestDetectionResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Unauthorized"},
        400: {"model": ErrorResponse, "description": "Invalid input"},
        413: {"model": ErrorResponse, "description": "File too large"},
        500: {"model": ErrorResponse, "description": "Server error"},
    },
    summary="Detect crop pest/disease from image",
    description=(
        "Upload a crop photo for AI-powered pest and disease detection. "
        "Accepts JPEG, PNG, or WebP images (max 10 MB). "
        "Returns the predicted disease label, confidence score, "
        "treatment suggestions, and prevention measures."
    ),
)
async def detect_pest(
    image: UploadFile = File(
        ..., description="Crop image file (JPEG, PNG, or WebP, max 10 MB)"
    ),
    user: AuthenticatedUser = Depends(verify_jwt),
):
    """
    Pest/disease detection endpoint.

    1. Validates the uploaded image (type, size).
    2. Uploads the image to S3 (if configured).
    3. Runs inference using TensorFlow model (or fallback classifier).
    4. Returns prediction with treatment advice.
    """

    # ─── Validate file type ──────────────────────────
    if image.content_type not in ALLOWED_TYPES:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported image type: {image.content_type}. Allowed: JPEG, PNG, WebP.",
        )

    # ─── Read file bytes ─────────────────────────────
    try:
        file_bytes = await image.read()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Failed to read uploaded image: {str(e)}",
        )

    # ─── Validate file size ──────────────────────────
    if len(file_bytes) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Image too large: {len(file_bytes) / (1024*1024):.1f} MB. Max allowed: 10 MB.",
        )

    if len(file_bytes) == 0:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Empty file uploaded.",
        )

    # ─── Upload to S3 ────────────────────────────────
    image_url = None
    try:
        image_url = await s3_service.upload_image(file_bytes, image.content_type)
    except RuntimeError as e:
        logger.error(f"S3 upload failed for user {user.user_id}: {e}")
        # Continue — S3 failure should not block detection

    # ─── Run model inference ─────────────────────────
    try:
        result = await disease_service.detect(file_bytes, image_url)
        logger.info(
            f"User {user.user_id} scanned: {result.pest} ({result.confidence:.2%})"
        )
        return result

    except Exception as e:
        logger.error(f"Detection failed for user {user.user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Disease detection failed: {str(e)}",
        )
