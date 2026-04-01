"""
AWS S3 service for uploading pest scan images.
"""

import uuid
import logging
from datetime import datetime
import boto3
from botocore.exceptions import ClientError
from app.config import get_settings

logger = logging.getLogger(__name__)


class S3Service:
    """Handles image uploads to AWS S3."""

    def __init__(self):
        settings = get_settings()
        self._bucket = settings.AWS_S3_BUCKET
        self._region = settings.AWS_REGION
        self._client = None

        # Only initialize if credentials are provided
        if settings.AWS_ACCESS_KEY_ID and settings.AWS_SECRET_ACCESS_KEY:
            try:
                self._client = boto3.client(
                    "s3",
                    region_name=settings.AWS_REGION,
                    aws_access_key_id=settings.AWS_ACCESS_KEY_ID,
                    aws_secret_access_key=settings.AWS_SECRET_ACCESS_KEY,
                )
                logger.info("S3 client initialized successfully")
            except Exception as e:
                logger.warning(f"S3 client initialization failed: {e}")
                self._client = None
        else:
            logger.info(
                "S3 credentials not configured — uploads will return local placeholder URLs"
            )

    @property
    def is_available(self) -> bool:
        return self._client is not None

    async def upload_image(
        self, file_bytes: bytes, content_type: str, folder: str = "pest-scans"
    ) -> str:
        """
        Upload image bytes to S3.

        Returns:
            S3 public URL of the uploaded image, or a placeholder if S3 is unavailable.
        """
        # Generate unique key
        timestamp = datetime.utcnow().strftime("%Y/%m/%d")
        file_ext = content_type.split("/")[-1]  # e.g., jpeg, png
        key = f"{folder}/{timestamp}/{uuid.uuid4().hex}.{file_ext}"

        if not self.is_available:
            logger.info(f"S3 unavailable — returning placeholder for key: {key}")
            return f"https://{self._bucket}.s3.{self._region}.amazonaws.com/{key}"

        try:
            self._client.put_object(
                Bucket=self._bucket,
                Key=key,
                Body=file_bytes,
                ContentType=content_type,
            )

            url = f"https://{self._bucket}.s3.{self._region}.amazonaws.com/{key}"
            logger.info(f"Uploaded image to S3: {url}")
            return url

        except ClientError as e:
            logger.error(f"S3 upload failed: {e}")
            raise RuntimeError(f"Failed to upload image to S3: {e}")


# Singleton
s3_service = S3Service()
