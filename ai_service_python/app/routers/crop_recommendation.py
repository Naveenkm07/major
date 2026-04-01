"""
Crop Recommendation Routes:
  POST /api/v1/crop-recommendation         — Soil-based crop recommendation
  POST /api/v1/crop-recommendation/stage    — Stage-based crop advice (crop+stage → recommendation)
"""

from fastapi import APIRouter, Depends
from app.auth import verify_jwt, AuthenticatedUser
from app.models.schemas import (
    CropRecommendationRequest,
    CropRecommendationResponse,
    StageRecommendationRequest,
    StageRecommendationResponse,
)
from app.services.recommendation_service import CropRecommendationService
from app.services.stage_recommendation_service import stage_recommendation_service

router = APIRouter(prefix="/api/v1", tags=["Crop Recommendation"])
recommendation_service = CropRecommendationService()


@router.post(
    "/crop-recommendation",
    response_model=CropRecommendationResponse,
    summary="Recommend crops based on soil & weather",
)
async def recommend_crops(
    request: CropRecommendationRequest,
    user: AuthenticatedUser = Depends(verify_jwt),
):
    """
    Recommend suitable crops based on soil parameters (N, P, K, pH)
    and weather conditions (temperature, humidity, rainfall).

    Example Input:
        { "nitrogen": 90, "phosphorus": 42, "potassium": 43,
          "temperature": 25, "humidity": 80, "ph": 6.5, "rainfall": 200 }

    Example Output:
        { "recommended_crops": [{"crop": "rice", "suitability_score": 0.92}],
          "soil_analysis": "Nitrogen levels are adequate...",
          "tips": ["Top recommendation: Rice (92%)"] }
    """
    return await recommendation_service.recommend(
        nitrogen=request.nitrogen,
        phosphorus=request.phosphorus,
        potassium=request.potassium,
        temperature=request.temperature,
        humidity=request.humidity,
        ph=request.ph,
        rainfall=request.rainfall,
    )


@router.post(
    "/crop-recommendation/stage",
    response_model=StageRecommendationResponse,
    summary="Get stage-specific crop recommendation",
)
async def recommend_by_stage(
    request: StageRecommendationRequest,
    user: AuthenticatedUser = Depends(verify_jwt),
):
    """
    Get stage-specific farming advice for a given crop.

    Example Input:
        { "crop": "Rice", "stage": "Vegetative" }

    Example Output:
        { "crop": "Rice", "stage": "vegetative",
          "recommendation": "Apply nitrogen fertilizer and monitor water levels...",
          "fertilizer": "Top dress Urea @ 65 kg/ha...",
          "irrigation": "Maintain 5 cm standing water...",
          "pest_watch": ["Leaf folder", "Gall midge"],
          "tips": ["Remove weeds...", "Monitor for yellowing..."] }
    """
    return stage_recommendation_service.get_recommendation(
        crop=request.crop,
        stage=request.stage,
    )
