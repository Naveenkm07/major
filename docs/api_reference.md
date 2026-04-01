# API Reference

Base URL: `http://localhost:5000/api/v1`

## Authentication

### `POST /auth/register`
Register a new user.
```json
{ "name": "string", "email": "string", "phone": "string", "password": "string" }
```

### `POST /auth/login`
Login with email and password. Returns JWT token.

### `GET /auth/me` 🔒
Get current user profile.

### `PUT /auth/update-profile` 🔒
Update user profile fields.

### `PUT /auth/fcm-token` 🔒
Update Firebase Cloud Messaging token.

---

## Crops

### `GET /crops` 🔒
List crops. Query: `season`, `category`, `search`, `page`, `limit`

### `GET /crops/:id` 🔒
Get single crop details.

### `GET /crops/:id/calendar` 🔒
Get crop's growth calendar.

### `POST /crops` 🔒 (Admin)
Create a new crop entry.

---

## Market Prices

### `GET /market-prices` 🔒
List prices. Query: `commodity`, `state`, `district`, `page`

### `GET /market-prices/trends/:commodity` 🔒
Get price trends. Query: `days` (default 30)

---

## Government Schemes

### `GET /schemes` 🔒
List schemes. Query: `type`, `state`, `search`, `page`

### `GET /schemes/:id` 🔒
Get scheme details.

---

## Loans

### `GET /loans` 🔒
List loans. Query: `loanType`, `bankName`, `page`

### `GET /loans/:id` 🔒
Get loan details.

### `POST /loans/compare` 🔒
Compare multiple loans. Body: `{ "loanIds": ["id1", "id2"] }`

---

## Community

### `GET /community/posts` 🔒
List posts. Query: `category`, `search`, `page`

### `POST /community/posts` 🔒
Create a post.

### `PUT /community/posts/:id/like` 🔒
Toggle like on a post.

### `POST /community/posts/:id/comments` 🔒
Add a comment. Body: `{ "text": "string" }`

---

## Chat / AI

### `POST /chat/message` 🔒
Send message to AI chatbot. Body: `{ "message": "string", "sessionId": "string" }`

### `GET /chat/history/:sessionId` 🔒
Get chat history for a session.

### `GET /chat/sessions` 🔒
List all chat sessions.

### `POST /chat/detect-disease` 🔒
Upload crop image for disease detection. Multipart form: `image` field.

---

🔒 = Requires `Authorization: Bearer <token>` header
