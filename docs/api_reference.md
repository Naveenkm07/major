# API Reference

Base URL: `http://localhost:5000/api/v1`

## Authentication (`/auth`)

### `POST /auth/register`
Register a new user.
```json
{ "name": "string", "email": "string", "phone": "string", "password": "string" }
```

### `POST /auth/login`
Login with email and password. Returns JWT token.

### `POST /auth/phone-sync`
Sync contacts or phone details.

### `POST /auth/google-sync`
Sync Google account details.

### `GET /auth/me` 🔒
Get current user profile.

### `PUT /auth/update-profile` 🔒
Update user profile fields.

### `PUT /auth/fcm-token` 🔒
Update Firebase Cloud Messaging token.

### `POST /auth/bookmarks/schemes/:id` 🔒
Toggle a bookmark for a specific government scheme.

### `POST /auth/bookmarks/equipment/:id` 🔒
Toggle a bookmark for a specific equipment item.

---

## Crops (`/crops`)

### `GET /crops` 🔒
List crops. Query: `season`, `category`, `search`, `page`, `limit`

### `GET /crops/:cropName/calendar` 🔒
Get a crop's growth calendar by name.

---

## Market Prices (`/market`)

### `GET /market` 🔒
List market prices. Query: `commodity`, `state`, `district`, `page`

### `GET /market/nearby` 🔒
Get market prices near the user.

### `GET /market/:id` 🔒
Get details for a specific market price entry.

---

## Government Schemes (`/schemes`)

### `GET /schemes` 🔒
List schemes. Query: `type`, `state`, `search`, `page`

### `GET /schemes/:id` 🔒
Get scheme details.

---

## Loans (`/loans`)

### `GET /loans` 🔒
List loans. Query: `loanType`, `bankName`, `page`

### `GET /loans/:id` 🔒
Get loan details.

---

## Community (`/community`)

### `GET /community/posts` 🔒
List posts. Query: `category`, `search`, `page`

### `GET /community/posts/:id` 🔒
Get details of a single post.

### `POST /community/posts` 🔒
Create a post.

### `PUT /community/posts/:id/like` 🔒
Toggle like on a post.

### `POST /community/posts/:id/comments` 🔒
Add a comment. Body: `{ "text": "string" }`

### `DELETE /community/posts/:id` 🔒
Delete a post.

---

## Chat & AI (`/chat` & `/pest`)

### `POST /chat` 🔒
Send message to AI chatbot.

### `GET /chat/history` 🔒
Get chat history for the current session.

### `GET /chat/sessions` 🔒
List all chat sessions.

### `POST /pest` 🔒
Upload crop image for disease detection. Multipart form: `image` field.

### `GET /pest/history` 🔒
Get the history of pest scans.

### `GET /pest/:id` 🔒
Get a specific pest scan result.

---

## Notifications (`/notifications`)

### `GET /notifications` 🔒
List user notifications.

### `PUT /notifications/read-all` 🔒
Mark all notifications as read.

### `PUT /notifications/:id/read` 🔒
Mark a specific notification as read.

### `POST /notifications/send` 🔒 (Admin)
Send a notification broadcast.

---

## Weather (`/weather`)

### `GET /weather/logs` 🔒
Get historical weather logs.

### `GET /weather/:location/forecast` 🔒
Get weather forecast for a location.

### `GET /weather/:location` 🔒
Get current weather for a location.

---

## Farmers (`/farmer`)

### `GET /farmer/nearby` 🔒
Get nearby farmers for community connection.

---

## Admin (`/admin`)

### `POST /admin/login`
Admin login to access the dashboard.

### `GET /admin/farmers` 🔒 (Admin)
List all farmers.

### `GET /admin/farmers/:id` 🔒 (Admin)
Get specific farmer details.

### `PUT /admin/farmers/:id` 🔒 (Admin)
Update a farmer's profile.

### `DELETE /admin/farmers/:id` 🔒 (Admin)
Delete a farmer's profile.

### `POST /admin/schemes` 🔒 (Admin)
Create a new government scheme.

### `POST /admin/schemes/seed` 🔒 (Admin)
Seed default government schemes.

### `PUT /admin/schemes/:id` 🔒 (Admin)
Update an existing government scheme.

### `DELETE /admin/schemes/:id` 🔒 (Admin)
Deactivate/delete a scheme.

---

## Equipment Rental (`/equipment`)

### `GET /equipment` 🔒
List all equipment listings. Query: `radius`, `lat`, `lng`, `type`, `page`

### `POST /equipment` 🔒
Create a new equipment listing. Body: `{ name, type, dailyRate, location, available }`

### `GET /equipment/:id` 🔒
Get a specific equipment listing.

### `PUT /equipment/:id` 🔒
Update an equipment listing (owner only).

### `DELETE /equipment/:id` 🔒
Delete an equipment listing (owner only).

### `POST /equipment/:id/connect` 🔒
Send a connection request to an equipment owner.

---

## Drone Analytics (`/drone`)

### `POST /drone/upload` 🔒
Upload drone imagery for a registered plot. Multipart form: `images[]`, `plotId`, `flightDate`

### `GET /drone/results/:plotId` 🔒
Get processed yield estimate and pest hotspot overlay for a plot.

---

## Voice Interface (`/voice`)

### `POST /voice/process` 🔒
Process a Kannada voice query via Bhashini ASR → Intent Classifier → Module Routing → Bhashini TTS.
Body: `{ audioBase64, language: "kn" }`

---

## Python AI Service
Base URL: `http://localhost:8000/api/v1`

### `POST /detect_pest`
Internal endpoint for MobileNetV3-Small INT8 disease classification from images.
Input: `224×224` RGB image. Output: top-N disease labels with confidence scores.

### `POST /recommend_crop`
Internal endpoint for AI crop recommendations based on soil/weather data.

### `POST /chat`
Internal endpoint for the RAG-powered AI farming assistant.
Queries ChromaDB for relevant Karnataka scheme chunks and calls Groq Llama 3 8B.

### `POST /rag/query`
Internal RAG endpoint for government scheme retrieval.
Embeds query with `all-MiniLM-L6-v2`, retrieves top-5 chunks from ChromaDB, returns answer grounded in retrieved text only.

### `POST /crop_calendar`
Internal endpoint for dynamic crop calendar generation.
Merges Open-Meteo forecast + UAS Bangalore crop rules, passes to Groq Llama 3 8B for Kannada week-by-week action plan.

### `POST /drone/analyze`
Internal endpoint for drone orthomosaic analysis.
Returns canopy health index, pest hotspot GeoJSON overlay, and per-acre yield estimate.

---
🔒 = Requires `Authorization: Bearer <token>` header
