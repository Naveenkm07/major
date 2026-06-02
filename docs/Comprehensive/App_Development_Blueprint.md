# KrushikaDhara: Full Application Development Blueprint

This document is a **Technical Implementation Guide** designed to be fed into AI Coding Agents (like Cursor, GitHub Copilot, Devin, or Antigravity) or a human development team. It provides the exact step-by-step instructions, schemas, and requirements needed to physically write the code for the KrushikaDhara platform from scratch, aligning 1:1 with the Comprehensive Documentation.

---

## 1. Technology Stack Requirements

### Backend (Node.js API)
- **Runtime**: Node.js v18+
- **Framework**: Express.js (REST API)
- **Database**: MongoDB (Mongoose ODM)
- **Key Libraries**: `jsonwebtoken`, `bcryptjs`, `node-cron`, `firebase-admin`, `jsoup` (for HTML scraping fallback), `axios`.

### AI Microservice (Python)
- **Runtime**: Python 3.10+
- **Framework**: FastAPI
- **Machine Learning**: `tensorflow` (YOLOv8 INT8 Quantized for Pest Detection), `scikit-learn` (Logistic Regression for Voice Intent Classification), `opencv-python`.
- **LLM/RAG**: `chromadb` (Vector Store), `langchain`, `groq` (Llama 3 8B), `apache-tika` (PDF parsing).

### Frontend (Mobile App)
- **Framework**: Flutter 3.19+ (Dart)
- **Local Storage**: `hive` (Offline-first persistence), `sqflite`.
- **State Management**: `provider` or `riverpod`
- **Key Plugins**: `camera`, `tflite_flutter`, `geolocator`, `flutter_local_notifications`, `speech_to_text`, `flutter_blue_plus` (for Bluetooth Mesh).

---

## 2. Core Database Schemas (MongoDB)

**1. User Schema**
```javascript
{
  name: { type: String, required: true },
  phone: { type: String, required: true, unique: true },
  passwordHash: { type: String, required: true },
  location: { lat: Number, lng: Number, district: String },
  fcmToken: String,
  cropsGrown: [String]
}
```

**2. MarketPrice Schema**
```javascript
{
  commodity: { type: String, required: true },
  district: { type: String, required: true },
  pricePerKg: { type: Number, required: true },
  date: { type: Date, default: Date.now }
}
```

**3. Scheme Schema**
```javascript
{
  title: { type: String, required: true },
  type: { type: String, enum: ['Subsidy', 'Loan', 'Equipment'] },
  state: { type: String, required: true },
  eligibilityCriteria: String,
  applicationLink: String
}
```

**4. Community Post Schema**
```javascript
{
  authorId: { type: ObjectId, ref: 'User' },
  content: { type: String, required: true },
  imageUrls: [String],
  likes: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now }
}
```

---

## 3. Step-by-Step Implementation Roadmap

### Phase 1: Foundation (Node.js Backend)
1. **Server Setup**: Initialize Express with Helmet, CORS, and Express-Rate-Limit. Connect to MongoDB Atlas.
2. **Authentication**: Implement `POST /auth/register` and `POST /auth/login` returning JWTs.
3. **Core CRUD APIs**: Implement endpoints for Community Forums (`/community/posts`) and Government Schemes (`/schemes`, `/loans`).
4. **Mandi Price Alert Engine**: 
   - Set up a `node-cron` job (06:00 IST) to fetch `data.gov.in` Agmarknet API.
   - **Crucial Fallback**: Implement a `jsoup` HTML-scraper that automatically activates if the REST API fails.
   - Compare prices to yesterday; if variance > 10%, trigger FCM Push Notifications.
5. **Pest-Weather Correlation Engine**:
   - Create a cron job running every 6 hours fetching Open-Meteo GPS forecasts and ESA Sentinel-2 NDVI data.
   - Evaluate against rule-based thresholds (e.g., Temp 25-33°C + RH > 60% = Pomegranate Blight Risk) and push FCM alerts for preventative spraying.
6. **Dynamic Crop Calendar**: Implement `GET /crops/:id/calendar` merging local UAS JSON rules with Open-Meteo forecasts, passing the payload to Groq Llama 3 for structured weekly Kannada advice.

### Phase 2: AI Microservice (Python FastAPI)
1. **Pest Detection**: Create `POST /detect_pest` to run the INT8 YOLOv8 `.tflite` model locally.
2. **Scheme RAG Pipeline**: 
   - Ingest government PDFs using Apache Tika. Chunk into 512-token segments (50-token overlap).
   - Embed via `all-MiniLM-L6-v2` and store in ChromaDB.
   - Create `POST /scheme_chat` to query ChromaDB and pass strict context to Groq Llama 3 (0% hallucination mandate).
3. **Voice-First Vernacular Pipeline**:
   - Create the orchestration endpoint.
   - Route audio to **Bhashini ASR** for Kannada speech-to-text.
   - Pass transcript to a **Logistic Regression Intent Classifier** (trained on 2k utterances) to route to the correct module (Weather, Mandi, Schemes).
   - Translate Llama 3's English response via **Bhashini NMT**.
   - Synthesize to Kannada audio via **Bhashini TTS**.

### Phase 3: Mobile App Shell & Offline Architecture
1. **Initialization**: Set up Flutter with Hive for local offline storage.
2. **Offline-First Resilience**: Cache the farmer profile, registered plots, and the last 30 days of Mandi prices in Hive/SQLite so the app launches instantly without network.
3. **Auth & Interceptors**: Build Login/Register and attach JWT to HTTP clients.

### Phase 4: Feature Integration & UI Screens
1. **Home Dashboard**: Displays local weather, recent Mandi price alerts, and the dynamic crop calendar.
2. **Disease Scanner (Offline)**: Use `camera` and `tflite_flutter` to run the YOLOv8 model directly on the handset (no network call needed) taking ~178ms.
3. **Voice Assistant Interface**: A floating microphone button using `speech_to_text`. Streams audio to the AI Microservice Voice Pipeline and plays back the returned audio.
4. **Farmer Connect Map**: A proximity-based map for sharing equipment. Implement a Bluetooth Mesh fallback (`flutter_blue_plus`) for communicating in dead-zones.

---

## 4. UI/UX Screen Requirements

- **Color Palette**: Primary: Agricultural Green (`#2E7D32`), Secondary: Harvest Orange (`#F57C00`), Background: Off-white (`#F9FBE7`).
- **Typography**: High contrast, large fonts (minimum 16sp for body text) for older demographics.
- **Accessibility**: Use universally recognized iconography (Rupee symbol for Mandi, Leaf for crops). Text labels must accompany all icons. Voice-first design is paramount.

---

## 5. Instructions for AI Coding Agents

If an AI (like Cursor, Devin, or GitHub Copilot) is reading this file to generate code, follow these rules strictly:
1. **Zero Hallucination Tolerance**: Do not mock the RAG pipeline. Implement ChromaDB vector search and ensure the LLM prompt explicitly blocks answering from outside knowledge.
2. **Graceful Degradation**: In Flutter, wrap all HTTP calls in a try/catch block. On `SocketException`, fallback to the Hive local database immediately. On Node.js, if Agmarknet API returns 500, fallback to the Jsoup scraper immediately.
3. **Resource Efficiency**: Use INT8 quantization for all on-device ML models to ensure it runs on low-end Android hardware. Ensure the Python backend runs within a 12GB RAM limit (e.g., Oracle Free Tier specifications).
