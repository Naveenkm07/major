# 🌾 KrushikaDhara – Smart Farming Companion

A production-ready smart agriculture mobile application that empowers farmers with AI-powered crop disease detection, real-time market prices, dynamic crop calendars, government scheme information, agricultural loan guidance, community forums, and an AI chatbot assistant.

---

## 🏗️ Architecture

```
┌──────────────────────┐   ┌──────────────────────┐
│  Flutter Mobile App  │   │  React Admin Panel   │
│ (mobile_app_flutter) │   │    (admin_panel)     │
└─────────┬────────────┘   └─────────┬────────────┘
          │ REST API                 │ REST API
          └───────────┐  ┌───────────┘
                      ▼  ▼
            ┌──────────────────────┐
            │  Node.js Express API │
            │  (backend_node_api)  │
            └─────────┬────────────┘
                      │
                ┌─────┴──────┐
                │            │
┌───▼──┐  ┌─────▼──────────┐
│MongoDB│  │ Python FastAPI  │
│  DB   │  │ (ai_service)    │
└───────┘  └─────┬──────────┘
                 │
         ┌───────┴────────┐
         │  External APIs  │
         │ Weather + Market│
         └────────────────┘
```

## 📁 Project Structure

```
KrushikaDhara/
├── mobile_app_flutter/    # Flutter mobile application
├── admin_panel/           # React/Vite Admin Dashboard
├── backend_node_api/      # Node.js Express REST API
├── ai_service_python/     # Python FastAPI AI microservice
├── database_models/       # Shared MongoDB schema definitions
├── docs/                  # Project documentation
├── docker-compose.yml     # Multi-service Docker setup
└── README.md
```

## 🚀 Quick Start

### Prerequisites
- **Node.js** v18+
- **Python** 3.10+
- **Flutter** 3.x
- **MongoDB** 7.0+ (or use Docker)
- **Docker** & **Docker Compose** (recommended)

### 1. Clone & Setup

```bash
git clone <your-repo-url> KrushikaDhara
cd KrushikaDhara
```

### 2. Start with Docker (Recommended)

```bash
# Copy env files
cp backend_node_api/.env.example backend_node_api/.env
cp ai_service_python/.env.example ai_service_python/.env

# Start all services
docker-compose up --build
```

### 3. Manual Setup

#### Backend API
```bash
cd backend_node_api
npm install
cp .env.example .env   # Edit with your values
npm run dev
```

#### AI Service
```bash
cd ai_service_python
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env       # Edit with your values
uvicorn app.main:app --reload --port 8000
```

#### Mobile App
```bash
cd mobile_app_flutter
flutter pub get
flutter run
```

#### Admin Dashboard
```bash
cd admin_panel
npm install
npm run dev
```

## 🔑 Key Features

| Feature | Description |
|---------|-------------|
| 📸 Crop Disease Detection | Camera-based AI diagnosis |
| 📈 Market Prices | Real-time mandi price data |
| 📅 Crop Calendar | Dynamic planting schedules |
| 🏛️ Government Schemes | Searchable scheme database |
| 💰 Loan Guidance | Agricultural loan comparisons |
| 👥 Community Connect | Farmer discussion forums |
| 🤖 AI Chatbot | Farming assistant chatbot |

## 🛡️ Tech Stack

| Layer | Technology |
|-------|-----------|
| Mobile | Flutter (Dart) |
| Admin Web | React + Vite |
| Backend | Node.js + Express |
| Database | MongoDB + Mongoose |
| AI Service | Python + FastAPI |
| Auth | JWT |
| Notifications | Firebase Cloud Messaging |
| Storage | AWS S3 |
| Containers | Docker + Docker Compose |

## 📄 License

MIT License – see [LICENSE](LICENSE) for details.
