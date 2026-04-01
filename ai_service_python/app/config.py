import os
from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    """Application settings loaded from environment variables."""

    # Server
    APP_NAME: str = "KrushikaDhara AI Service"
    DEBUG: bool = True
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # JWT (must match the Node.js backend secret)
    JWT_SECRET: str = "your_super_secret_jwt_key_change_in_production"
    JWT_ALGORITHM: str = "HS256"

    # ML Models
    DISEASE_MODEL_PATH: str = "app/ml_models/crop_disease_model.h5"
    DISEASE_LABELS_PATH: str = "app/ml_models/disease_labels.json"

    # AWS S3
    AWS_ACCESS_KEY_ID: str = ""
    AWS_SECRET_ACCESS_KEY: str = ""
    AWS_REGION: str = "ap-south-1"
    AWS_S3_BUCKET: str = "krushikadhara-uploads"

    # OpenAI (for chatbot)
    OPENAI_API_KEY: str = ""
    OPENAI_MODEL: str = "gpt-3.5-turbo"

    # External APIs
    WEATHER_API_KEY: str = ""
    WEATHER_API_URL: str = "https://api.openweathermap.org/data/2.5"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


@lru_cache()
def get_settings() -> Settings:
    """Cached settings singleton."""
    return Settings()
