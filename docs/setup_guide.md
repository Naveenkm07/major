# Development Setup Guide

## Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | 18+ | [nodejs.org](https://nodejs.org) |
| Python | 3.10+ | [python.org](https://python.org) |
| Flutter | 3.x | [flutter.dev](https://flutter.dev) |
| MongoDB | 7.0+ | [mongodb.com](https://mongodb.com) or use Docker |
| Docker | 24+ | [docker.com](https://docker.com) |

## Quick Start with Docker

```bash
# 1. Clone the repository
git clone <repo-url> && cd KrushikaDhara

# 2. Copy environment files
cp backend_node_api/.env.example backend_node_api/.env
cp ai_service_python/.env.example ai_service_python/.env

# 3. Edit .env files with your API keys

# 4. Start all services
docker-compose up --build

# Services:
#   Backend API:  http://localhost:5000
#   AI Service:   http://localhost:8000
#   MongoDB:      localhost:27017
```

## Manual Setup

### Backend (Node.js)
```bash
cd backend_node_api
npm install
cp .env.example .env    # Edit with your credentials
npm run dev              # Starts on port 5000
```

### AI Service (Python)
```bash
cd ai_service_python
python -m venv venv
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env     # Edit with your credentials
uvicorn app.main:app --reload --port 8000
```

### Mobile App (Flutter)
```bash
cd mobile_app_flutter
flutter pub get
flutter run               # Run on connected device/emulator
```

## Environment Variables

### Backend `.env`
| Variable | Description |
|----------|-------------|
| `MONGODB_URI` | MongoDB connection string |
| `JWT_SECRET` | JWT signing secret |
| `AWS_ACCESS_KEY_ID` | AWS S3 access key |
| `AWS_SECRET_ACCESS_KEY` | AWS S3 secret key |
| `FIREBASE_PROJECT_ID` | Firebase project ID |
| `AI_SERVICE_URL` | URL of the Python AI service |
| `WEATHER_API_KEY` | OpenWeatherMap API key |
| `MARKET_API_KEY` | Data.gov.in API key |

### AI Service `.env`
| Variable | Description |
|----------|-------------|
| `DISEASE_MODEL_PATH` | Path to TensorFlow disease model |
| `WEATHER_API_KEY` | OpenWeatherMap API key |
