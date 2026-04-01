from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime


# ═══════════════════════════════════════════════════════
# Pest Detection
# ═══════════════════════════════════════════════════════

class PestDetectionResponse(BaseModel):
    """Response schema for /api/v1/detect_pest."""

    pest: str = Field(..., description="Predicted disease/pest label")
    confidence: float = Field(
        ..., ge=0.0, le=1.0, description="Model confidence score (0–1)"
    )
    description: str = Field("", description="Disease description")
    treatment: List[str] = Field(
        default_factory=list, description="Recommended treatments"
    )
    prevention: List[str] = Field(
        default_factory=list, description="Prevention measures"
    )
    image_url: Optional[str] = Field(
        None, description="S3 URL of the uploaded image"
    )
    scan_id: Optional[str] = Field(
        None, description="Reference ID for this scan"
    )


# ═══════════════════════════════════════════════════════
# Chatbot
# ═══════════════════════════════════════════════════════

class ChatRequest(BaseModel):
    """Request schema for /api/v1/chat."""

    question: str = Field(
        ...,
        min_length=1,
        max_length=2000,
        description="Farmer's question to the AI assistant",
    )
    language: str = Field(
        default="en",
        description="Language code (en, hi, kn, te, etc.)",
    )
    context: Optional[dict] = Field(
        default=None,
        description="Optional user context (location, crops, etc.)",
    )


class ChatResponse(BaseModel):
    """Response schema for /api/v1/chat."""

    answer: str = Field(..., description="AI-generated response")
    intent: Optional[str] = Field(
        None, description="Detected intent of the question"
    )
    confidence: Optional[float] = Field(
        None, ge=0.0, le=1.0, description="Intent confidence"
    )
    suggestions: List[str] = Field(
        default_factory=list, description="Follow-up suggestions"
    )
    source: str = Field(
        default="rule_based", description="Response source: openai | rule_based"
    )


# ═══════════════════════════════════════════════════════
# Error
# ═══════════════════════════════════════════════════════

class ErrorResponse(BaseModel):
    """Standard error response."""

    detail: str
    status_code: int = 400


# ═══════════════════════════════════════════════════════
# Crop Recommendation (soil-based)
# ═══════════════════════════════════════════════════════

class CropRecommendationRequest(BaseModel):
    """Request for POST /api/v1/crop-recommendation (soil + weather)."""

    nitrogen: float = Field(..., ge=0, description="Soil nitrogen (kg/ha)")
    phosphorus: float = Field(..., ge=0, description="Soil phosphorus (kg/ha)")
    potassium: float = Field(..., ge=0, description="Soil potassium (kg/ha)")
    temperature: float = Field(..., description="Average temperature (°C)")
    humidity: float = Field(..., ge=0, le=100, description="Relative humidity (%)")
    ph: float = Field(..., ge=0, le=14, description="Soil pH")
    rainfall: float = Field(..., ge=0, description="Average rainfall (mm)")


class CropRecommendationResponse(BaseModel):
    """Response from crop recommendation engine."""

    recommended_crops: list = Field(
        default_factory=list, description="Top crops with suitability scores"
    )
    soil_analysis: str = Field("", description="Soil health analysis summary")
    tips: List[str] = Field(default_factory=list, description="Farming tips")


# ═══════════════════════════════════════════════════════
# Stage-Based Crop Recommendation
# ═══════════════════════════════════════════════════════

class StageRecommendationRequest(BaseModel):
    """Request for POST /api/v1/crop-recommendation/stage."""

    crop: str = Field(..., min_length=1, description="Crop name (e.g., Rice, Tomato)")
    stage: str = Field(
        ..., min_length=1,
        description="Growth stage (e.g., Seedling, Vegetative, Flowering, Harvesting)"
    )


class StageRecommendationResponse(BaseModel):
    """Response for stage-based crop recommendation."""

    crop: str
    stage: str
    recommendation: str = Field(..., description="Stage-specific advice")
    fertilizer: str = Field("", description="Fertilizer recommendation")
    irrigation: str = Field("", description="Irrigation advice")
    pest_watch: List[str] = Field(default_factory=list, description="Pests to watch for")
    tips: List[str] = Field(default_factory=list, description="Stage-specific tips")
