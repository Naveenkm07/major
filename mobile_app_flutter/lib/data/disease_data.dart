class DiseaseData {
  static const Map<String, Map<String, dynamic>> diseaseDb = {
    "healthy": {
      "description": "The plant appears healthy with no visible signs of disease or pest damage.",
      "treatment": [
        "Continue current care practices",
        "Maintain balanced fertilizer application",
      ],
      "prevention": [
        "Regular crop monitoring every 7 days",
        "Proper spacing between plants",
        "Balanced nutrient management",
      ],
    },
    "bacterial_blight": {
      "description": "Bacterial blight causes water-soaked lesions on leaves that turn brown. Common in rice, cotton, and beans.",
      "treatment": [
        "Remove and destroy infected plant parts immediately",
        "Apply copper-based bactericide (Copper Oxychloride 50WP @ 2.5g/L)",
        "Spray Streptomycin Sulphate @ 500 ppm at 10-day intervals",
        "Use Pseudomonas fluorescens @ 10g/L as biocontrol",
      ],
      "prevention": [
        "Use certified disease-resistant seed varieties",
        "Seed treatment with Pseudomonas fluorescens @ 10g/kg seed",
        "Avoid overhead irrigation — use drip or furrow",
        "Maintain proper plant spacing for air circulation",
      ],
    },
    "leaf_spot": {
      "description": "Fungal leaf spot appears as circular brown or tan spots with dark borders. Affects most crops.",
      "treatment": [
        "Spray Mancozeb 75WP @ 2.5g/L at first appearance",
        "Follow up with Carbendazim 50WP @ 1g/L after 15 days",
        "Remove severely affected leaves and destroy",
      ],
      "prevention": [
        "Crop rotation with non-host crops",
        "Avoid wetting foliage during irrigation",
        "Apply neem oil @ 5ml/L as preventive every 20 days",
        "Use certified disease-free seeds",
      ],
    },
    "rust": {
      "description": "Rust appears as orange-brown powdery pustules on leaf undersides. Severe in wheat, soybean, and pulses.",
      "treatment": [
        "Spray Propiconazole 25EC @ 1ml/L immediately",
        "Follow with Mancozeb 75WP @ 2.5g/L after 10 days",
        "Apply Trichoderma viride @ 4g/L as biocontrol alternative",
      ],
      "prevention": [
        "Plant rust-resistant varieties",
        "Early sowing to escape peak rust period",
        "Balanced NPK — avoid excess nitrogen",
        "Monitor crop weekly during flowering stage",
      ],
    },
    "powdery_mildew": {
      "description": "White powdery coating on leaves, stems, and buds. Reduces photosynthesis and stunts growth.",
      "treatment": [
        "Spray Wettable Sulphur 80WP @ 3g/L",
        "Apply Karathane 48EC @ 1ml/L for severe infection",
        "Organic: Baking soda solution (5g/L) + liquid soap (2ml/L)",
      ],
      "prevention": [
        "Ensure adequate plant spacing (do not crowd)",
        "Avoid excess nitrogen fertilization",
        "Water at the base of plants, not overhead",
        "Grow resistant varieties when available",
      ],
    },
    "late_blight": {
      "description": "Late blight causes dark water-soaked lesions on leaves and stems. Devastating in potato and tomato.",
      "treatment": [
        "Spray Metalaxyl + Mancozeb (Ridomil Gold) @ 2.5g/L",
        "Apply Cymoxanil + Mancozeb @ 3g/L for severe cases",
        "Remove and destroy infected plants immediately",
      ],
      "prevention": [
        "Use certified disease-free seed tubers",
        "Plant resistant varieties",
        "Avoid excess irrigation during humid weather",
        "Prophylactic spray of Mancozeb before onset",
      ],
    },
    "aphids": {
      "description": "Small sap-sucking insects found in clusters on new growth. Cause curling, yellowing, and transmit viruses.",
      "treatment": [
        "Spray Imidacloprid 17.8SL @ 0.3ml/L",
        "Apply Dimethoate 30EC @ 1.5ml/L for severe infestation",
        "Organic: Neem oil @ 5ml/L + liquid soap (1ml/L)",
      ],
      "prevention": [
        "Install yellow sticky traps @ 12/acre",
        "Encourage natural predators (ladybugs, lacewings)",
        "Avoid excessive nitrogen — it promotes soft growth",
        "Regular monitoring of undersides of leaves",
      ],
    },
    "stem_borer": {
      "description": "Larvae bore into stems causing dead hearts and white ears. Major pest of rice and maize.",
      "treatment": [
        "Apply Carbofuran 3G granules @ 25kg/ha in leaf whorls",
        "Spray Chlorantraniliprole 18.5SC @ 0.3ml/L",
        "Use Trichogramma chilonis egg parasitoid (1 lakh/ha)",
      ],
      "prevention": [
        "Remove and destroy stubbles after harvest",
        "Use light traps @ 1/acre to monitor adult moth activity",
        "Avoid late planting — early sowing reduces infestation",
        "Clip tips of seedlings before transplanting to remove eggs",
      ],
    },
  };
}
