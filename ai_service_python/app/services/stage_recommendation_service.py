"""
Stage-based crop recommendation service.
Given a crop name and growth stage, returns specific farming advice
including fertilizer, irrigation, pest watch, and actionable tips.
"""

import logging
from app.models.schemas import StageRecommendationResponse

logger = logging.getLogger(__name__)

# ═══════════════════════════════════════════════════════
# Crop-Stage Knowledge Base
# ═══════════════════════════════════════════════════════

CROP_STAGE_DB = {
    "rice": {
        "seedling": {
            "recommendation": "Transplant 21-25 day old seedlings with 2-3 seedlings per hill. Maintain 2-3 cm water level in the field.",
            "fertilizer": "Apply basal dose of DAP @ 100 kg/ha and MOP @ 50 kg/ha before transplanting.",
            "irrigation": "Maintain thin film of water (2-3 cm) for first 10 days. Avoid submergence.",
            "pest_watch": ["Stem borer", "Brown planthopper", "Leaf folder"],
            "tips": [
                "Use mat nursery for uniform seedlings",
                "Treat seeds with Carbendazim @ 2g/kg before sowing",
                "Transplant in rows for better aeration",
            ],
        },
        "vegetative": {
            "recommendation": "Apply nitrogen fertilizer and monitor water levels. This is the critical tillering stage.",
            "fertilizer": "Top dress Urea @ 65 kg/ha at 30 DAT (days after transplanting). Apply Zinc Sulphate @ 25 kg/ha if deficient.",
            "irrigation": "Maintain 5 cm standing water. Alternate wetting and drying (AWD) can save 20-30% water.",
            "pest_watch": ["Leaf folder", "Gall midge", "Bacterial leaf blight"],
            "tips": [
                "Remove weeds manually or apply Butachlor @ 1.5 kg/ha",
                "Monitor for yellowing leaves (nitrogen deficiency)",
                "Count tillers per hill — target 15-20 tillers",
            ],
        },
        "flowering": {
            "recommendation": "Ensure adequate water during panicle initiation. Avoid any water stress — critical yield determination stage.",
            "fertilizer": "Final top dress Urea @ 35 kg/ha at panicle initiation. Spray KCl 1% for grain filling.",
            "irrigation": "Maintain continuous flooding (5 cm) from panicle initiation to grain filling.",
            "pest_watch": ["Neck blast", "False smut", "Rice bug"],
            "tips": [
                "Spray Propiconazole if blast symptoms appear",
                "Avoid excess nitrogen at this stage",
                "Do not drain water during flowering",
            ],
        },
        "harvesting": {
            "recommendation": "Harvest when 80-85% of grains turn golden yellow. Moisture content should be 20-22%.",
            "fertilizer": "No fertilizer application needed at this stage.",
            "irrigation": "Drain field 10-15 days before harvest for easy harvesting.",
            "pest_watch": ["Grain discoloration", "Storage pests"],
            "tips": [
                "Use combine harvester or manual harvest with sickle",
                "Dry grains to 14% moisture before storage",
                "Leave stubble incorporation for soil health",
            ],
        },
    },
    "wheat": {
        "seedling": {
            "recommendation": "Sow seeds at 3-5 cm depth with row spacing of 22.5 cm. Apply pre-sowing irrigation (Palewa).",
            "fertilizer": "Apply 60 kg N + 40 kg P2O5 + 20 kg K2O per hectare as basal dose.",
            "irrigation": "First irrigation (Crown Root Initiation) at 20-25 DAS is critical.",
            "pest_watch": ["Termites", "Aphids", "Powdery mildew"],
            "tips": [
                "Optimum sowing time: Nov 1-25 for Northern India",
                "Seed rate: 100 kg/ha for timely sown, 125 kg/ha for late",
                "Treat seeds with Vitavax @ 2.5g/kg",
            ],
        },
        "vegetative": {
            "recommendation": "Critical stage for tillering. Ensure adequate nitrogen and timely irrigation.",
            "fertilizer": "Top dress Urea @ 55 kg/ha at first irrigation. Apply foliar spray of zinc if deficient.",
            "irrigation": "Irrigate at CRI (21 DAS), tillering (40 DAS), and jointing (60 DAS).",
            "pest_watch": ["Yellow rust", "Brown rust", "Aphids"],
            "tips": [
                "Apply first irrigation at crown root initiation — do not delay",
                "Apply herbicide Sulfosulfuron @ 25g/ha for weed control",
                "Monitor for rust symptoms on leaves",
            ],
        },
        "flowering": {
            "recommendation": "Flowering and grain filling stage. Ensure water and watch for ear head diseases.",
            "fertilizer": "Spray Urea 2% foliar if leaves show nitrogen deficiency.",
            "irrigation": "Irrigate at heading (80 DAS) and milking (100 DAS) stages.",
            "pest_watch": ["Karnal bunt", "Ear cockle", "Aphids on ear"],
            "tips": [
                "Spray Propiconazole 25EC @ 1ml/L if rust appears",
                "Avoid water stress during grain filling",
                "Monitor for shriveled grains",
            ],
        },
        "harvesting": {
            "recommendation": "Harvest when grains are hard and golden. Moisture should be below 14%.",
            "fertilizer": "No fertilizer needed.",
            "irrigation": "Last irrigation at dough stage. No irrigation after that.",
            "pest_watch": ["Storage insects like Khapra beetle"],
            "tips": [
                "Harvest with combine harvester at correct settings",
                "Thresh immediately to avoid shattering losses",
                "Store in clean, dry, fumigated godowns",
            ],
        },
    },
    "tomato": {
        "seedling": {
            "recommendation": "Transplant 25-30 day old seedlings in well-prepared beds with 60x45 cm spacing.",
            "fertilizer": "Apply FYM @ 25 tonnes/ha + NPK 120:60:60 kg/ha as basal.",
            "irrigation": "Light irrigation immediately after transplanting. Water daily for first week.",
            "pest_watch": ["Damping off", "Cutworm", "Aphids"],
            "tips": [
                "Harden seedlings for 3-4 days before transplanting",
                "Transplant in evening to reduce wilting",
                "Apply Trichoderma to nursery beds for disease prevention",
            ],
        },
        "vegetative": {
            "recommendation": "Stake plants at 30 DAT. Apply nitrogen in split doses for vigorous vegetative growth.",
            "fertilizer": "Top dress Urea @ 55 kg/ha at 30 and 60 DAT. Apply calcium if blossom end rot appears.",
            "irrigation": "Drip irrigation at 2L/plant/day. Maintain consistent moisture — avoid irregular watering.",
            "pest_watch": ["Leaf curl virus (whitefly)", "Early blight", "Spider mites"],
            "tips": [
                "Prune suckers below first flower cluster for determinate varieties",
                "Mulch with black polythene to conserve moisture",
                "Install yellow sticky traps for whitefly monitoring",
            ],
        },
        "flowering": {
            "recommendation": "Critical fruit set stage. Maintain consistent moisture and avoid calcium deficiency.",
            "fertilizer": "Spray Boron 0.2% + Calcium 0.5% for better fruit set. Apply MOP @ 30 kg/ha.",
            "irrigation": "Do not water-stress during flowering. Maintain drip at 3-4 L/plant/day.",
            "pest_watch": ["Fruit borer (Helicoverpa)", "Late blight", "Blossom end rot"],
            "tips": [
                "Tap plants gently at noon to improve pollination",
                "Spray Emamectin Benzoate 5SG for fruit borer",
                "Maintain consistent irrigation to prevent blossom end rot",
            ],
        },
        "harvesting": {
            "recommendation": "Pick fruits at turning (breaker) stage for distant markets, at red ripe for local sale.",
            "fertilizer": "Stop fertilizer 15 days before last harvest.",
            "irrigation": "Reduce irrigation frequency before last harvest.",
            "pest_watch": ["Fruit fly", "Post-harvest fungal rots"],
            "tips": [
                "Harvest in cool morning hours",
                "Use plastic crates — not gunny bags — to reduce damage",
                "Grade by size and color for better market price",
            ],
        },
    },
    "maize": {
        "seedling": {
            "recommendation": "Sow seeds at 5 cm depth with 60x20 cm spacing. Use seed drill for uniform sowing.",
            "fertilizer": "Apply 50% N + full P + full K as basal. Use DAP 100 kg + MOP 60 kg/ha.",
            "irrigation": "First irrigation 3-4 days after sowing if soil is dry.",
            "pest_watch": ["Fall armyworm", "Shoot fly", "Cutworm"],
            "tips": [
                "Treat seeds with Imidacloprid for shoot fly protection",
                "Maintain plant population of 80,000-85,000 per hectare",
                "Use herbicide Atrazine @ 1 kg/ha pre-emergence for weed control",
            ],
        },
        "vegetative": {
            "recommendation": "Knee-high stage to tasseling. Critical for leaf area development and plant vigor.",
            "fertilizer": "Top dress remaining 50% Urea at knee-high stage (30-35 DAS).",
            "irrigation": "Irrigate at V6 and V10 stages. Total 4-5 irrigations needed.",
            "pest_watch": ["Fall armyworm", "Stem borer", "Turcicum leaf blight"],
            "tips": [
                "Earthing up at 30 DAS for root anchorage",
                "Apply Emamectin Benzoate 5SG for fall armyworm",
                "Detassel alternate rows in hybrid seed production",
            ],
        },
        "flowering": {
            "recommendation": "Tasseling to silking — most water-sensitive stage. One day of stress reduces yield by 8%.",
            "fertilizer": "Spray Urea 2% + DAP 2% foliar if deficiency visible.",
            "irrigation": "Critical irrigation at tasseling and silking. Do not allow any moisture stress.",
            "pest_watch": ["Corn earworm", "Downy mildew", "Charcoal rot"],
            "tips": [
                "Do not skip irrigation at tasseling",
                "Monitor for silk clipping by corn earworm",
                "Maintain good air circulation to reduce downy mildew",
            ],
        },
        "harvesting": {
            "recommendation": "Harvest when husks are dry and kernels are hard. Black layer visible at kernel tip.",
            "fertilizer": "No fertilizer needed.",
            "irrigation": "Stop irrigation after dough stage.",
            "pest_watch": ["Cob borer", "Aflatoxin (Aspergillus)"],
            "tips": [
                "Harvest at 25% grain moisture, dry to 12%",
                "Shell immediately to prevent insect damage",
                "Store in airtight containers or bags",
            ],
        },
    },
    "cotton": {
        "seedling": {
            "recommendation": "Sow BT cotton at 90x60 cm spacing. Use dibbling method at 3-5 cm depth.",
            "fertilizer": "Apply FYM @ 10 tonnes/ha + 40 kg N + 20 kg P2O5 as basal.",
            "irrigation": "First irrigation at 3-4 DAS. Light irrigation for establishment.",
            "pest_watch": ["Jassids", "Whitefly", "Thrips"],
            "tips": [
                "Sow refuge rows (5 rows non-BT for every 20 rows BT)",
                "Gap fill within 10 days of sowing",
                "Install pheromone traps for bollworm monitoring",
            ],
        },
        "vegetative": {
            "recommendation": "Square formation to early boll stage. Manage sucking pests actively.",
            "fertilizer": "Top dress 40 kg N at 30 DAS and 40 kg N at 60 DAS.",
            "irrigation": "Irrigate at 15-20 day intervals. Cotton is drought tolerant but responds to irrigation.",
            "pest_watch": ["American bollworm", "Pink bollworm", "Mealybug"],
            "tips": [
                "Spray Neem oil 5% for sucking pests",
                "Avoid excess nitrogen to reduce pest attraction",
                "Detopping at 120 DAS to redirect energy to bolls",
            ],
        },
        "flowering": {
            "recommendation": "Peak boll development. Maintain adequate moisture and nutrition.",
            "fertilizer": "Spray KNO3 2% for boll development. Apply MOP 40 kg/ha.",
            "irrigation": "Irrigate at 10-12 day intervals during boll development.",
            "pest_watch": ["Pink bollworm", "Spotted bollworm", "Alternaria leaf spot"],
            "tips": [
                "Release Trichogramma @ 1.5 lakh/ha for bollworm biocontrol",
                "Pick and destroy fallen squares and damaged bolls",
                "Monitor boll damage — threshold is 10% damaged bolls",
            ],
        },
        "harvesting": {
            "recommendation": "Pick kapas when bolls are fully open. Do 3-4 pickings at 15-day intervals.",
            "fertilizer": "No fertilizer needed.",
            "irrigation": "Stop irrigation 15 days before first picking.",
            "pest_watch": ["Boll rot in late season"],
            "tips": [
                "Pick in dry weather to maintain fiber quality",
                "Keep picked cotton clean — avoid contamination",
                "Uproot and burn stubbles after last picking to destroy pink bollworm",
            ],
        },
    },
    "sugarcane": {
        "seedling": {
            "recommendation": "Plant setts in furrows at 75-90 cm row spacing. Use 3-budded setts treated fungicide.",
            "fertilizer": "Apply 60 kg N + 60 kg P2O5 + 60 kg K2O as basal.",
            "irrigation": "Light irrigation immediately after planting. Maintain moist until germination.",
            "pest_watch": ["Termites", "Scale insects", "Red rot"],
            "tips": [
                "Treat setts with Carbendazim + Malathion solution",
                "Use healthy setts from disease-free mother crop",
                "Plant in January-February for spring season",
            ],
        },
        "vegetative": {
            "recommendation": "Tillering to grand growth. This stage contributes 70% of the total yield.",
            "fertilizer": "Top dress 150 kg Urea at 45 and 90 DAP in split doses.",
            "irrigation": "Irrigate at 7-10 day intervals during summer. 35-40 irrigations total.",
            "pest_watch": ["Early shoot borer", "Top borer", "Pyrilla"],
            "tips": [
                "Earthing up at 90 and 120 DAP",
                "Trash mulching to conserve moisture",
                "Detrash lower leaves at 150 DAP for better aeration",
            ],
        },
        "flowering": {
            "recommendation": "Grand growth to maturity. Reduce nitrogen to promote sugar accumulation.",
            "fertilizer": "Stop nitrogen after 5th month. Spray KCl 5% for sucrose enrichment.",
            "irrigation": "Reduce irrigation frequency to 15-day intervals.",
            "pest_watch": ["Top borer", "Smut", "Red rot"],
            "tips": [
                "Spray Ethephon 200 ppm at 30 days before harvest as ripener",
                "Test juice brix with refractometer — target 20+",
                "Avoid water-logging in late stages",
            ],
        },
        "harvesting": {
            "recommendation": "Harvest at 10-12 months. Cut at ground level. Brix should be 18-20%.",
            "fertilizer": "No fertilizer needed.",
            "irrigation": "Stop irrigation 3 weeks before harvest.",
            "pest_watch": ["Post-harvest deterioration"],
            "tips": [
                "Harvest and crush within 24 hours for best sugar recovery",
                "Cut close to ground — bottom internodes have highest sugar",
                "Keep ratoon crop by leaving stubble at soil level",
            ],
        },
    },
}

# Normalized stage aliases
STAGE_ALIASES = {
    "seedling": "seedling", "nursery": "seedling", "germination": "seedling", "sowing": "seedling",
    "transplanting": "seedling", "planting": "seedling", "emergence": "seedling",
    "vegetative": "vegetative", "tillering": "vegetative", "growth": "vegetative",
    "growing": "vegetative", "branching": "vegetative",
    "flowering": "flowering", "reproductive": "flowering", "fruiting": "flowering",
    "booting": "flowering", "heading": "flowering", "panicle": "flowering", "silking": "flowering",
    "harvesting": "harvesting", "harvest": "harvesting", "maturity": "harvesting",
    "ripening": "harvesting", "picking": "harvesting",
}


class StageRecommendationService:
    """Provides stage-specific farming advice for crops."""

    def get_recommendation(self, crop: str, stage: str) -> StageRecommendationResponse:
        """
        Get stage-specific recommendation for a given crop.

        Args:
            crop: Crop name (e.g., "rice", "tomato")
            stage: Growth stage (e.g., "vegetative", "flowering")

        Returns:
            StageRecommendationResponse with advice, fertilizer, irrigation, pests, tips
        """
        crop_lower = crop.lower().strip()
        stage_lower = stage.lower().strip()

        # Normalize stage name using aliases
        normalized_stage = STAGE_ALIASES.get(stage_lower, stage_lower)

        # Look up in knowledge base
        crop_data = CROP_STAGE_DB.get(crop_lower)

        if crop_data is None:
            # Return generic advice for unknown crops
            return StageRecommendationResponse(
                crop=crop,
                stage=stage,
                recommendation=f"Specific advice for {crop} is not yet in our database. Consult your local Krishi Vigyan Kendra (KVK) for tailored guidance.",
                fertilizer="Apply balanced NPK based on soil test results.",
                irrigation="Maintain adequate moisture based on crop type and soil condition.",
                pest_watch=["Monitor regularly for any unusual symptoms"],
                tips=[
                    "Get a soil test done at your nearest KVK",
                    "Follow recommended spacing for your variety",
                    "Maintain field hygiene — remove weeds regularly",
                ],
            )

        stage_data = crop_data.get(normalized_stage)

        if stage_data is None:
            available = ", ".join(crop_data.keys())
            return StageRecommendationResponse(
                crop=crop,
                stage=stage,
                recommendation=f"Stage '{stage}' not found for {crop}. Available stages: {available}.",
                fertilizer="Follow general fertilizer schedule for this crop.",
                irrigation="Maintain adequate moisture.",
                pest_watch=[],
                tips=[f"Available stages for {crop}: {available}"],
            )

        return StageRecommendationResponse(
            crop=crop,
            stage=normalized_stage,
            **stage_data,
        )


# Singleton
stage_recommendation_service = StageRecommendationService()
