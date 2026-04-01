# KrushikaDhara Backend API – Testing Guide

## Setup

```bash
cd backend_node_api
cp .env.example .env     # Edit with your values
npm install
npm run dev              # Starts on http://localhost:5000
```

Make sure MongoDB is running on `mongodb://localhost:27017/krushikadhara`.

---

## Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `MONGODB_URI` | MongoDB connection string | ✅ |
| `JWT_SECRET` | Token signing secret | ✅ |
| `AI_SERVICE_URL` | Python FastAPI URL (default: `http://localhost:8000`) | ✅ for pest/chat |
| `AWS_ACCESS_KEY_ID` | S3 image storage | Optional |
| `FIREBASE_PROJECT_ID` | Push notifications | Optional |
| `MARKET_API_KEY` | data.gov.in API key | Optional |

---

## API Endpoints

### 1. Register Farmer

```bash
curl -X POST http://localhost:5000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Rajesh Kumar",
    "phoneNumber": "9876543210",
    "email": "rajesh@example.com",
    "passwordHash": "securePass123",
    "village": "Mandya",
    "district": "Mandya",
    "state": "Karnataka",
    "farmSize": 5.5,
    "cropTypes": ["rice", "sugarcane"]
  }'
```

**Response (201):**
```json
{
  "success": true,
  "token": "eyJhbGciOiJIUzI1NiIs...",
  "user": {
    "_id": "65f...",
    "name": "Rajesh Kumar",
    "email": "rajesh@example.com",
    "phoneNumber": "9876543210",
    "village": "Mandya",
    "district": "Mandya",
    "state": "Karnataka",
    "farmSize": 5.5
  }
}
```

**Validation errors (400):**
```json
{
  "success": false,
  "errors": [
    { "field": "phoneNumber", "message": "Enter a valid 10-digit Indian mobile number" }
  ]
}
```

---

### 2. Login

```bash
curl -X POST http://localhost:5000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{ "email": "rajesh@example.com", "password": "securePass123" }'
```

---

### 3. Pest Detection (Image Upload → AI Service)

```bash
curl -X POST http://localhost:5000/api/v1/pest-detect \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -F "image=@./leaf_photo.jpg"
```

**Flow:**
```
Mobile App
  → POST /api/v1/pest-detect (Node.js with multer)
    → Node.js forwards image via axios.post to Python AI service
    → POST http://localhost:8000/api/v1/detect_pest (FastAPI)
    → AI model returns prediction
  ← Node.js saves to PestScan collection
  ← Returns enriched result to mobile app
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "scanId": "65f...",
    "pest": "leaf_rust",
    "confidence": 0.92,
    "description": "Rust appears as orange-brown pustules...",
    "treatment": [
      "Spray Propiconazole 25EC @ 1ml/litre",
      "Apply Mancozeb 75WP @ 2.5g/litre"
    ],
    "prevention": [
      "Plant rust-resistant varieties",
      "Remove infected crop debris"
    ],
    "imageUrl": "https://s3.ap-south-1.amazonaws.com/.../scan.jpg"
  }
}
```

---

### 4. AI Chatbot

```bash
curl -X POST http://localhost:5000/api/v1/chat \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "question": "My rice leaves are turning yellow", "language": "en" }'
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "answer": "Yellow leaves in rice can indicate nitrogen deficiency...",
    "intent": "pest_disease",
    "confidence": 0.88,
    "suggestions": ["What fertilizer should I use?", "How to prevent this?"],
    "source": "rule_based",
    "sessionId": "session_a3b8d1b6"
  }
}
```

---

### 5. Market Prices

```bash
curl http://localhost:5000/api/v1/market-prices?commodity=rice&state=Karnataka
```

---

### 6. Community Posts

```bash
# Create post
curl -X POST http://localhost:5000/api/v1/community/posts \
  -H "Authorization: Bearer <JWT_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{ "content": "Got great yield with SRI method!", "category": "success_story" }'

# Get posts
curl http://localhost:5000/api/v1/community/posts \
  -H "Authorization: Bearer <JWT_TOKEN>"

# Like a post
curl -X PUT http://localhost:5000/api/v1/community/posts/<POST_ID>/like \
  -H "Authorization: Bearer <JWT_TOKEN>"
```

---

### 7. Government Schemes

```bash
curl "http://localhost:5000/api/v1/schemes?type=central"
```

---

### 8. Crop Calendar

```bash
curl "http://localhost:5000/api/v1/crops?season=kharif"
```

---

## Architecture: Pest Detection Proxy (Key Implementation)

```javascript
// pestController.js – Core logic
const formData = new FormData();
formData.append('image', req.file.buffer, {
    filename: req.file.originalname,
    contentType: req.file.mimetype,
});

const aiResponse = await axios.post(
    `${config.aiService.url}/api/v1/detect_pest`,
    formData,
    {
        headers: {
            ...formData.getHeaders(),
            Authorization: req.headers.authorization, // JWT passthrough
        },
        timeout: 30000,
    }
);
```

## Running with AI Service

```bash
# Terminal 1: Start AI service
cd ai_service_python
pip install -r requirements.txt
uvicorn app.main:app --host 0.0.0.0 --port 8000

# Terminal 2: Start Node.js API
cd backend_node_api
npm run dev

# Terminal 3: Start MongoDB
mongod --dbpath /data/db
```
