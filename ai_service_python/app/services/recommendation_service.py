import numpy as np
from app.models.schemas import CropRecommendationResponse


# Crop database with growing conditions
CROP_DATABASE = {
    "rice": {"temp": (20, 35), "humidity": (60, 90), "ph": (5.5, 7.0), "rainfall": (100, 200), "n": (60, 120), "p": (20, 60), "k": (20, 60)},
    "wheat": {"temp": (10, 25), "humidity": (30, 70), "ph": (6.0, 7.5), "rainfall": (30, 90), "n": (80, 140), "p": (30, 60), "k": (20, 50)},
    "maize": {"temp": (18, 32), "humidity": (50, 80), "ph": (5.5, 7.5), "rainfall": (60, 120), "n": (60, 120), "p": (30, 60), "k": (20, 50)},
    "cotton": {"temp": (20, 35), "humidity": (40, 70), "ph": (6.0, 8.0), "rainfall": (50, 100), "n": (40, 100), "p": (20, 50), "k": (15, 40)},
    "sugarcane": {"temp": (20, 38), "humidity": (50, 85), "ph": (5.0, 8.0), "rainfall": (75, 200), "n": (80, 150), "p": (30, 60), "k": (40, 80)},
    "chickpea": {"temp": (15, 30), "humidity": (30, 60), "ph": (6.0, 8.0), "rainfall": (20, 60), "n": (15, 40), "p": (30, 60), "k": (15, 30)},
    "mustard": {"temp": (10, 25), "humidity": (30, 60), "ph": (6.0, 7.5), "rainfall": (25, 50), "n": (40, 80), "p": (20, 40), "k": (10, 30)},
    "groundnut": {"temp": (20, 35), "humidity": (40, 70), "ph": (5.5, 7.0), "rainfall": (50, 120), "n": (10, 30), "p": (30, 60), "k": (20, 40)},
    "soybean": {"temp": (20, 30), "humidity": (50, 80), "ph": (6.0, 7.5), "rainfall": (60, 100), "n": (20, 50), "p": (40, 70), "k": (20, 40)},
    "tomato": {"temp": (18, 30), "humidity": (40, 70), "ph": (6.0, 7.0), "rainfall": (40, 80), "n": (80, 140), "p": (40, 80), "k": (60, 100)},
}


class CropRecommendationService:
    def __init__(self):
        self.model = None
        self.crop_db = CROP_DATABASE

    def _calculate_suitability(
        self, crop_params: dict, n: float, p: float, k: float,
        temp: float, humidity: float, ph: float, rainfall: float,
    ) -> float:
        """Calculate suitability score (0–1) for given conditions."""
        scores = []

        def range_score(value, vmin, vmax):
            if vmin <= value <= vmax:
                mid = (vmin + vmax) / 2
                spread = (vmax - vmin) / 2
                return 1.0 - (abs(value - mid) / spread) * 0.3
            elif value < vmin:
                return max(0, 1.0 - (vmin - value) / vmin) if vmin > 0 else 0
            else:
                return max(0, 1.0 - (value - vmax) / vmax) if vmax > 0 else 0

        scores.append(range_score(temp, *crop_params["temp"]))
        scores.append(range_score(humidity, *crop_params["humidity"]))
        scores.append(range_score(ph, *crop_params["ph"]))
        scores.append(range_score(rainfall, *crop_params["rainfall"]))
        scores.append(range_score(n, *crop_params["n"]))
        scores.append(range_score(p, *crop_params["p"]))
        scores.append(range_score(k, *crop_params["k"]))

        return round(float(np.mean(scores)), 4)

    def _analyze_soil(self, n: float, p: float, k: float, ph: float) -> str:
        """Generate soil analysis summary."""
        parts = []

        if n < 30:
            parts.append("Low nitrogen – consider urea or green manure")
        elif n > 120:
            parts.append("High nitrogen – reduce nitrogen fertilizers")
        else:
            parts.append("Nitrogen levels are adequate")

        if p < 20:
            parts.append("Low phosphorus – apply DAP or SSP")
        elif p > 60:
            parts.append("High phosphorus – reduce phosphate input")
        else:
            parts.append("Phosphorus levels are good")

        if k < 20:
            parts.append("Low potassium – apply MOP (Muriate of Potash)")
        elif k > 60:
            parts.append("High potassium – monitor levels")
        else:
            parts.append("Potassium levels are adequate")

        if ph < 5.5:
            parts.append("Soil is acidic – consider liming")
        elif ph > 8.0:
            parts.append("Soil is alkaline – add gypsum or sulfur")
        else:
            parts.append("Soil pH is in a good range")

        return ". ".join(parts) + "."

    async def recommend(
        self,
        nitrogen: float,
        phosphorus: float,
        potassium: float,
        temperature: float,
        humidity: float,
        ph: float,
        rainfall: float,
    ) -> CropRecommendationResponse:
        """Recommend crops based on soil and weather parameters."""
        results = []
        for crop_name, params in self.crop_db.items():
            score = self._calculate_suitability(
                params, nitrogen, phosphorus, potassium,
                temperature, humidity, ph, rainfall,
            )
            results.append({"crop": crop_name, "suitability_score": score})

        results.sort(key=lambda x: x["suitability_score"], reverse=True)
        top_crops = results[:5]

        soil_analysis = self._analyze_soil(nitrogen, phosphorus, potassium, ph)

        tips = [
            f"Top recommendation: {top_crops[0]['crop'].title()} (score: {top_crops[0]['suitability_score']:.0%})",
            "Get a detailed soil test from your nearest Krishi Vigyan Kendra",
            "Consider crop rotation to maintain soil health",
            "Check local weather forecast before sowing",
        ]

        return CropRecommendationResponse(
            recommended_crops=top_crops,
            soil_analysis=soil_analysis,
            tips=tips,
        )
