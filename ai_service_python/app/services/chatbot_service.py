"""
Chatbot service with OpenAI GPT integration and rule-based fallback.
Provides agricultural advisory responses in multiple languages.
"""

import logging
from typing import Optional
from app.config import get_settings
from app.models.schemas import ChatResponse

logger = logging.getLogger(__name__)

# ═══════════════════════════════════════════════════════
# Agricultural System Prompt (for OpenAI)
# ═══════════════════════════════════════════════════════
SYSTEM_PROMPT = """You are KrushikaDhara AI, an expert agricultural assistant for Indian farmers.

Your expertise covers:
- Crop cultivation practices (sowing, irrigation, fertilizer, harvesting)
- Pest and disease management (identification, treatment, prevention)
- Market intelligence (price trends, best time to sell)
- Government schemes (PM-KISAN, PMFBY, KCC, Soil Health Card, etc.)
- Agricultural loans and subsidies
- Weather-based farming advice
- Organic and sustainable farming practices

Guidelines:
1. Give practical, actionable advice — include specific dosages, timings, and product names.
2. Recommend both chemical and organic solutions when possible.
3. Always suggest consulting local Krishi Vigyan Kendra (KVK) for complex issues.
4. Be empathetic and supportive — farming is hard work.
5. When unsure, say so honestly and suggest expert consultation.
6. If the user asks in Hindi, respond in Hindi. Match the user's language.
7. Keep responses concise but comprehensive (150–300 words).
"""

# ═══════════════════════════════════════════════════════
# Rule-Based Fallback Knowledge
# ═══════════════════════════════════════════════════════
FARMING_KB = {
    "crop_advice": {
        "keywords": ["grow", "plant", "crop", "cultivate", "sow", "harvest", "seed", "variety", "yield", "ugana", "fasal"],
        "response_en": "For crop advice, I recommend: 1) Get soil tested at your nearest KVK or soil testing lab. 2) Choose varieties recommended by your state agricultural university. 3) Follow the recommended seed rate and spacing. 4) Apply balanced fertilizers based on soil test report. Would you like specific advice for a particular crop?",
        "response_hi": "फसल सलाह के लिए: 1) अपनी नजदीकी KVK या मिट्टी परीक्षण प्रयोगशाला में मिट्टी की जांच कराएं। 2) अपने राज्य कृषि विश्वविद्यालय द्वारा अनुशंसित किस्में चुनें। 3) अनुशंसित बीज दर और दूरी का पालन करें। क्या आप किसी विशेष फसल के बारे में जानना चाहते हैं?",
    },
    "disease": {
        "keywords": ["disease", "pest", "sick", "yellow", "spots", "wilt", "rot", "insect", "blight", "rog", "keet"],
        "response_en": "For pest/disease issues: 1) Upload a clear photo of the affected plant using our Disease Detection feature for AI diagnosis. 2) Isolate affected plants immediately. 3) Avoid overhead watering. 4) Contact your local Krishi Vigyan Kendra for field diagnosis. Would you like to upload a photo for analysis?",
        "response_hi": "कीट/रोग समस्याओं के लिए: 1) AI निदान के लिए हमारी रोग पहचान सुविधा का उपयोग करके प्रभावित पौधे की स्पष्ट फोटो अपलोड करें। 2) प्रभावित पौधों को तुरंत अलग करें। 3) ऊपर से पानी देने से बचें। 4) क्षेत्र निदान के लिए अपने स्थानीय KVK से संपर्क करें।",
    },
    "market": {
        "keywords": ["price", "market", "sell", "mandi", "rate", "cost", "bhav", "daam", "bazar"],
        "response_en": "For market prices: 1) Check the Market Prices section in the app for real-time mandi rates. 2) Compare prices across multiple mandis before selling. 3) Consider government MSP (Minimum Support Price) as a baseline. 4) Store produce properly if prices are low — wait for better rates if storage allows.",
        "response_hi": "बाजार भाव के लिए: 1) वास्तविक समय मंडी भाव के लिए ऐप में बाजार भाव अनुभाग देखें। 2) बेचने से पहले कई मंडियों में कीमतों की तुलना करें। 3) सरकारी MSP को आधार रेखा मानें। 4) कीमतें कम हों तो उपज को ठीक से भंडारित करें।",
    },
    "scheme": {
        "keywords": ["scheme", "government", "subsidy", "yojana", "pm-kisan", "insurance", "pmfby", "kcc", "sarkar", "sarkari"],
        "response_en": "Key government schemes for farmers: 1) **PM-KISAN**: ₹6,000/year in 3 installments — apply at pmkisan.gov.in. 2) **PMFBY**: Crop insurance at 2% premium (Kharif) — apply through your bank. 3) **KCC**: Kisan Credit Card at 4% interest — apply at any bank. 4) **Soil Health Card**: Free soil testing — apply at soilhealth.dac.gov.in. Check our Government Schemes section for more details.",
        "response_hi": "किसानों के लिए प्रमुख सरकारी योजनाएं: 1) **PM-KISAN**: ₹6,000/वर्ष 3 किस्तों में — pmkisan.gov.in पर आवेदन करें। 2) **PMFBY**: 2% प्रीमियम पर फसल बीमा — बैंक से आवेदन करें। 3) **KCC**: 4% ब्याज पर किसान क्रेडिट कार्ड। 4) **मृदा स्वास्थ्य कार्ड**: मुफ्त मिट्टी परीक्षण।",
    },
    "loan": {
        "keywords": ["loan", "credit", "kcc", "bank", "finance", "interest", "rin", "karz"],
        "response_en": "Agricultural loan options: 1) **KCC (Kisan Credit Card)**: Up to ₹3 lakh at 4% interest (with subsidy). Apply at any nationalized bank. 2) **Crop Loan**: Short-term loans for crop cultivation. 3) **Term Loan**: For farm equipment, irrigation, land development. Documents needed: Aadhaar, land records, bank passbook. Visit your nearest bank branch or CSC center.",
        "response_hi": "कृषि ऋण विकल्प: 1) **KCC**: ₹3 लाख तक 4% ब्याज पर (सब्सिडी सहित)। किसी भी राष्ट्रीयकृत बैंक में आवेदन करें। 2) **फसल ऋण**: फसल खेती के लिए अल्पकालिक ऋण। 3) **सावधि ऋण**: कृषि उपकरण, सिंचाई के लिए। दस्तावेज: आधार, भूमि रिकॉर्ड, बैंक पासबुक।",
    },
    "weather": {
        "keywords": ["weather", "rain", "temperature", "forecast", "monsoon", "drought", "mausam", "barish"],
        "response_en": "Weather-based farming tips: 1) Check the weather forecast before any spraying operation — avoid if rain expected within 6 hours. 2) Plan irrigation based on forecast — save water if rain is predicted. 3) During monsoon: ensure proper drainage in fields. 4) Install rain gauge for accurate field-level rainfall measurement.",
        "response_hi": "मौसम आधारित कृषि सुझाव: 1) किसी भी छिड़काव से पहले मौसम पूर्वानुमान जांचें — 6 घंटे में बारिश हो तो बचें। 2) पूर्वानुमान के आधार पर सिंचाई योजना बनाएं। 3) मानसून में: खेतों में उचित जल निकासी सुनिश्चित करें।",
    },
}

DEFAULT_RESPONSE = {
    "en": "I'm KrushikaDhara AI, your farming assistant. I can help with: 🌾 Crop advice, 🐛 Pest/disease identification, 📈 Market prices, 🏛️ Government schemes, 💰 Loan guidance, and 🌤️ Weather-based farming tips. What would you like to know?",
    "hi": "मैं कृषिकाधारा AI हूं, आपका कृषि सहायक। मैं इनमें मदद कर सकता हूं: 🌾 फसल सलाह, 🐛 कीट/रोग पहचान, 📈 बाजार भाव, 🏛️ सरकारी योजनाएं, 💰 ऋण मार्गदर्शन, और 🌤️ मौसम आधारित सुझाव। आप क्या जानना चाहते हैं?",
}

SUGGESTIONS_MAP = {
    "crop_advice": ["Show crop calendar", "Recommend crops for my soil", "Wheat best practices"],
    "disease": ["Upload photo for diagnosis", "Common rice diseases", "Organic pest control"],
    "market": ["Today's wheat prices", "Price trends this month", "Nearest mandi rates"],
    "scheme": ["PM-KISAN eligibility", "Crop insurance details", "How to get Soil Health Card"],
    "loan": ["KCC interest rates", "Compare bank loans", "Documents for farm loan"],
    "weather": ["7-day forecast", "Best time for sowing", "Monsoon predictions"],
    "default": ["Crop advice", "Pest help", "Market prices", "Government schemes"],
}


class ChatbotService:
    """
    Dual-mode chatbot:
    1. OpenAI GPT (if API key configured)
    2. Rule-based keyword matching (fallback)
    """

    def __init__(self):
        settings = get_settings()
        self._openai_client = None
        self._openai_model = settings.OPENAI_MODEL

        if settings.OPENAI_API_KEY:
            try:
                from openai import OpenAI

                self._openai_client = OpenAI(api_key=settings.OPENAI_API_KEY)
                logger.info("OpenAI client initialized successfully")
            except ImportError:
                logger.warning(
                    "openai package not installed. Install with: pip install openai"
                )
            except Exception as e:
                logger.warning(f"OpenAI initialization failed: {e}")
        else:
            logger.info(
                "OPENAI_API_KEY not set — using rule-based chatbot fallback"
            )

    def _detect_intent(self, message: str) -> tuple:
        """Keyword-based intent detection."""
        msg_lower = message.lower()
        for intent, data in FARMING_KB.items():
            for keyword in data["keywords"]:
                if keyword in msg_lower:
                    return intent, 0.85
        return "default", 0.5

    async def _get_openai_response(
        self, question: str, language: str, context: Optional[dict]
    ) -> ChatResponse:
        """Generate response using OpenAI GPT."""
        messages = [{"role": "system", "content": SYSTEM_PROMPT}]

        # Add context if available
        if context:
            ctx_str = f"User context: Location={context.get('location', 'unknown')}, Crops={context.get('crops', 'unknown')}"
            messages.append({"role": "system", "content": ctx_str})

        if language != "en":
            messages.append(
                {
                    "role": "system",
                    "content": f"The user is communicating in language code '{language}'. Respond in the same language.",
                }
            )

        messages.append({"role": "user", "content": question})

        try:
            response = self._openai_client.chat.completions.create(
                model=self._openai_model,
                messages=messages,
                max_tokens=500,
                temperature=0.7,
            )

            answer = response.choices[0].message.content.strip()
            intent, confidence = self._detect_intent(question)

            return ChatResponse(
                answer=answer,
                intent=intent,
                confidence=confidence,
                suggestions=SUGGESTIONS_MAP.get(intent, SUGGESTIONS_MAP["default"]),
                source="openai",
            )

        except Exception as e:
            logger.error(f"OpenAI API error: {e}. Falling back to rule-based.")
            return await self._get_rule_based_response(question, language)

    async def _get_rule_based_response(
        self, question: str, language: str
    ) -> ChatResponse:
        """Generate response using keyword matching."""
        intent, confidence = self._detect_intent(question)

        lang_key = "hi" if language in ("hi",) else "en"

        if intent == "default":
            answer = DEFAULT_RESPONSE.get(lang_key, DEFAULT_RESPONSE["en"])
        else:
            kb = FARMING_KB[intent]
            answer = kb.get(f"response_{lang_key}", kb["response_en"])

        return ChatResponse(
            answer=answer,
            intent=intent if intent != "default" else None,
            confidence=confidence,
            suggestions=SUGGESTIONS_MAP.get(intent, SUGGESTIONS_MAP["default"]),
            source="rule_based",
        )

    async def get_response(
        self,
        question: str,
        language: str = "en",
        context: Optional[dict] = None,
    ) -> ChatResponse:
        """
        Generate a chatbot response.
        Uses OpenAI if configured, otherwise falls back to rule-based.
        """
        if self._openai_client is not None:
            return await self._get_openai_response(question, language, context)
        else:
            return await self._get_rule_based_response(question, language)


# Singleton
chatbot_service = ChatbotService()
