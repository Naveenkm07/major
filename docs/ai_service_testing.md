# KrushikaDhara AI Service – Testing & ML Integration Guide

## Quick Start

```bash
cd ai_service_python

# 1. Create virtual environment
python -m venv venv
venv\Scripts\activate        # Windows
# source venv/bin/activate   # macOS/Linux

# 2. Install dependencies
pip install -r requirements.txt

# 3. Configure environment
cp .env.example .env
# Edit .env — set JWT_SECRET to match your Node.js backend

# 4. Start the server
uvicorn app.main:app --reload --port 8000

# 5. Open Swagger docs
# http://localhost:8000/docs
```

---

## API Testing (curl)

### Step 1: Get a JWT Token

First, get a token from the Node.js backend:

```bash
# Register a test farmer
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Farmer",
    "email": "test@example.com",
    "phoneNumber": "9876543210",
    "passwordHash": "password123"
  }'

# Login to get JWT token
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'

# Save the token from the response:
# export TOKEN="eyJhbGciOiJIUzI1NiIs..."
```

---

### Endpoint 1: POST /api/v1/detect_pest

**Request:**
```bash
curl -X POST http://localhost:8000/api/v1/detect_pest \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@./test_images/wheat_leaf.jpg"
```

**Success Response (200):**
```json
{
  "pest": "rust",
  "confidence": 0.92,
  "description": "Rust appears as orange-brown powdery pustules on leaf undersides. Severe in wheat, soybean, and pulses.",
  "treatment": [
    "Spray Propiconazole 25EC @ 1ml/L immediately",
    "Follow with Mancozeb 75WP @ 2.5g/L after 10 days",
    "Apply Trichoderma viride @ 4g/L as biocontrol alternative"
  ],
  "prevention": [
    "Plant rust-resistant varieties (e.g., HD-3226 for wheat)",
    "Early sowing to escape peak rust period",
    "Balanced NPK — avoid excess nitrogen",
    "Monitor crop weekly during flowering stage"
  ],
  "image_url": "https://krushikadhara-uploads.s3.ap-south-1.amazonaws.com/pest-scans/2026/03/13/abc123.jpeg",
  "scan_id": null
}
```

**Error — No Auth (401):**
```bash
curl -X POST http://localhost:8000/api/v1/detect_pest \
  -F "image=@./test_images/wheat_leaf.jpg"
```
```json
{
  "detail": "Not authenticated"
}
```

**Error — Wrong File Type (400):**
```bash
curl -X POST http://localhost:8000/api/v1/detect_pest \
  -H "Authorization: Bearer $TOKEN" \
  -F "image=@./test_data/document.pdf"
```
```json
{
  "detail": "Unsupported image type: application/pdf. Allowed: JPEG, PNG, WebP."
}
```

---

### Endpoint 2: POST /api/v1/chat

**Request (English):**
```bash
curl -X POST http://localhost:8000/api/v1/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "When should I sow wheat in Madhya Pradesh?",
    "language": "en"
  }'
```

**Success Response (200):**
```json
{
  "answer": "For crop advice, I recommend: 1) Get soil tested at your nearest KVK or soil testing lab. 2) Choose varieties recommended by your state agricultural university. 3) Follow the recommended seed rate and spacing. 4) Apply balanced fertilizers based on soil test report. Would you like specific advice for a particular crop?",
  "intent": "crop_advice",
  "confidence": 0.85,
  "suggestions": [
    "Show crop calendar",
    "Recommend crops for my soil",
    "Wheat best practices"
  ],
  "source": "rule_based"
}
```

**Request (Hindi):**
```bash
curl -X POST http://localhost:8000/api/v1/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "PM-KISAN yojana ke liye kaise apply karein?",
    "language": "hi"
  }'
```

**Response (Hindi):**
```json
{
  "answer": "किसानों के लिए प्रमुख सरकारी योजनाएं: 1) **PM-KISAN**: ₹6,000/वर्ष 3 किस्तों में — pmkisan.gov.in पर आवेदन करें। 2) **PMFBY**: 2% प्रीमियम पर फसल बीमा — बैंक से आवेदन करें। 3) **KCC**: 4% ब्याज पर किसान क्रेडिट कार्ड। 4) **मृदा स्वास्थ्य कार्ड**: मुफ्त मिट्टी परीक्षण।",
  "intent": "scheme",
  "confidence": 0.85,
  "suggestions": [
    "PM-KISAN eligibility",
    "Crop insurance details",
    "How to get Soil Health Card"
  ],
  "source": "rule_based"
}
```

**Request with Context:**
```bash
curl -X POST http://localhost:8000/api/v1/chat \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "question": "What crops should I grow?",
    "language": "en",
    "context": {
      "location": "Raichur, Karnataka",
      "crops": ["rice", "cotton"],
      "season": "kharif"
    }
  }'
```

---

### Health Check

```bash
curl http://localhost:8000/health
```
```json
{
  "status": "healthy",
  "service": "KrushikaDhara AI Service",
  "version": "1.0.0",
  "components": {
    "disease_model": "fallback",
    "s3": "unavailable",
    "chatbot": "rule_based"
  }
}
```

---

## ML Model Integration

### Disease Detection Model

**Architecture:** The service expects a TensorFlow/Keras image classification model.

**Preprocessing pipeline:**
- Input: Raw crop image (any size/format)
- Convert to RGB
- Resize to **224×224** pixels (standard for MobileNet/ResNet)
- Normalize pixel values to **[0, 1]**
- Batch dimension: `(1, 224, 224, 3)`

**Supported base models (transfer learning recommended):**
| Model | Params | Accuracy | Speed |
|-------|--------|----------|-------|
| MobileNetV2 | 3.4M | Good | Fast (mobile-ready) |
| ResNet50 | 25.6M | Better | Medium |
| EfficientNetB0 | 5.3M | Best | Medium |
| InceptionV3 | 23.8M | Good | Slower |

**Training code example (TensorFlow):**
```python
import tensorflow as tf
from tensorflow.keras.applications import MobileNetV2
from tensorflow.keras.layers import Dense, GlobalAveragePooling2D, Dropout
from tensorflow.keras.models import Model

# Base model
base = MobileNetV2(weights='imagenet', include_top=False, input_shape=(224, 224, 3))
base.trainable = False  # Freeze base layers

# Classification head
x = base.output
x = GlobalAveragePooling2D()(x)
x = Dropout(0.3)(x)
x = Dense(256, activation='relu')(x)
x = Dropout(0.2)(x)
output = Dense(8, activation='softmax')(x)  # 8 disease classes

model = Model(inputs=base.input, outputs=output)
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Train
model.fit(train_dataset, epochs=20, validation_data=val_dataset)

# Save
model.save('app/ml_models/crop_disease_model.h5')
```

**Training data sources:**
| Dataset | Size | Classes | Link |
|---------|------|---------|------|
| PlantVillage | 54,000+ images | 38 classes | [Kaggle](https://www.kaggle.com/datasets/emmarex/plantdisease) |
| PlantDoc | 2,598 images | 27 classes | [GitHub](https://github.com/pratikkayal/PlantDoc-Dataset) |
| IARI Crop Disease | Custom | Varies | Contact ICAR-IARI |

**To integrate your trained model:**
1. Save model as `app/ml_models/crop_disease_model.h5`
2. Update labels in `app/ml_models/disease_labels.json`
3. Uncomment `tensorflow` in `requirements.txt`
4. Restart the service — it auto-loads on startup

---

### Chatbot Model

**Current modes:**
1. **OpenAI GPT** (set `OPENAI_API_KEY` in `.env`) — Best quality, costs money
2. **Rule-based** (default) — Free, works offline, covers 6 intent categories

**Intent detection:** Keyword-based matching across 6 categories:
- `crop_advice` — planting, growing, harvesting
- `disease` — pests, diseases, treatment
- `market` — prices, selling, mandis
- `scheme` — government schemes, subsidies
- `loan` — credit, banks, KCC
- `weather` — monsoon, rainfall, temperature

**To upgrade to local LLM (optional):**
```python
# Using Ollama (local LLM)
# pip install ollama
import ollama

response = ollama.chat(model='llama3', messages=[
    {'role': 'system', 'content': SYSTEM_PROMPT},
    {'role': 'user', 'content': question},
])
answer = response['message']['content']
```

---

## Docker

```bash
# Build
docker build -t krushikadhara-ai .

# Run
docker run -p 8000:8000 --env-file .env krushikadhara-ai

# Or with docker-compose (from project root)
docker-compose up ai_service
```
