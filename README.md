<div align="center">
  
# 🌾 KrushikaDhara

**The Intelligent Farming Companion**

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev/)
[![React](https://img.shields.io/badge/React-20232A?style=for-the-badge&logo=react&logoColor=61DAFB)](https://reactjs.org/)
[![Node.js](https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)](https://www.python.org/)
[![MongoDB](https://img.shields.io/badge/MongoDB-4EA94B?style=for-the-badge&logo=mongodb&logoColor=white)](https://www.mongodb.com/)

*Empowering modern farmers with AI-driven insights, real-time market data, and community connection.*

---
</div>

## 📖 Overview

**KrushikaDhara** is a production-ready, comprehensive smart agriculture ecosystem. It seamlessly bridges the gap between traditional farming and modern technology by providing farmers with powerful AI tools, dynamic data, and financial guidance, all accessible through an intuitive mobile interface.

## ✨ Key Features

- **📸 AI Crop Disease Detection:** Instant, camera-based diagnosis powered by advanced computer vision models.
- **💬 Intelligent Chatbot:** A 24/7 virtual assistant providing personalized farming advice and troubleshooting.
- **📈 Real-Time Market Prices:** Live Mandi pricing data to help farmers secure the best value for their crops.
- **📅 Dynamic Crop Calendar:** Automated, customized planting and harvesting schedules.
- **🏛️ Government Schemes Explorer:** A curated, searchable database of agricultural grants and subsidies.
- **💰 Loan Guidance Engine:** Smart comparison tools for agricultural financing and loans.
- **👥 Farmer Connect Community:** Dedicated forums for peer-to-peer knowledge sharing and support.

---

## 🏗️ System Architecture

Our platform utilizes a robust, modern microservices architecture designed for scalability and offline resilience.

```mermaid
graph TD
    %% Define Styles
    classDef mobile fill:#4fc3f7,stroke:#01579b,stroke-width:2px,color:black
    classDef apiGateway fill:#ffb74d,stroke:#e65100,stroke-width:2px,color:black
    classDef backend fill:#81c784,stroke:#1b5e20,stroke-width:2px,color:black
    classDef ai fill:#ba68c8,stroke:#4a148c,stroke-width:2px,color:black
    classDef db fill:#e57373,stroke:#b71c1c,stroke-width:2px,color:black
    classDef 3rdparty fill:#e0e0e0,stroke:#616161,stroke-width:2px,stroke-dasharray: 5, 5,color:black

    %% Mobile App & Web
    subgraph "Frontend Layer"
        FlutterApp["📱 KrushikaDhara Mobile App\n(Flutter)"]:::mobile
        AdminPanel["💻 Admin Dashboard\n(React/Vite)"]:::mobile
    end

    %% Network / Entry
    subgraph "Network Layer"
        CDN["🌐 CloudFront CDN\n(Static Assets)"]:::apiGateway
        AGW["🛡️ API Gateway / Load Balancer\n(Reverse Proxy)"]:::apiGateway
    end

    %% Backend Services
    subgraph "Application Layer"
        NodeAPI["🟢 Node.js Backend API\n(Express / JWT Auth)"]:::backend
        AIApi["🧠 Python AI Microservice\n(FastAPI / TensorFlow)"]:::ai
    end

    %% Data Storage
    subgraph "Data Layer"
        MongoDB[("🍃 MongoDB Atlas\n(User Data, Logs, Posts)")]:::db
        Hive[("📦 Hive Local DB\n(Offline Sync)")]:::db
        S3[("🪣 AWS S3\n(Images & Media)")]:::db
    end

    %% External Services
    subgraph "External Integrations"
        FCM["🔔 Firebase FCM\n(Push Notifications)"]:::3rdparty
        Weather["🌤️ OpenWeatherMap API"]:::3rdparty
        Market["📈 Data.gov.in Market API"]:::3rdparty
    end

    %% Connections
    FlutterApp -- "Caches Data" --> Hive
    FlutterApp -- "Fetches media" --> CDN
    AdminPanel -- "Fetches media" --> CDN
    CDN -. "Points to" .-> S3

    FlutterApp -- "HTTPS / REST" --> AGW
    AdminPanel -- "HTTPS / REST" --> AGW
    AGW -- "/api/v1/*" --> NodeAPI

    NodeAPI -- "CRUD Operations" --> MongoDB
    NodeAPI -- "Image Uploads" --> S3
    
    NodeAPI -- "Triggers Push" --> FCM
    FCM -- "Sends Notification" --> FlutterApp

    NodeAPI -- "Fetches Weather" --> Weather
    NodeAPI -- "Fetches Prices" --> Market
    
    NodeAPI -- "Forwards Image / Text" --> AIApi
    AIApi -- "Returns AI Predictions" --> NodeAPI
```

---

## 📁 Repository Structure

The project is structured as a monorepo containing all platform services:

```text
KrushikaDhara/
├── 📱 mobile_app_flutter/    # Primary end-user application (Flutter/Dart)
├── 💻 admin_panel/           # Internal dashboard for platform management (React/Vite)
├── ⚙️ backend_node_api/      # Core business logic and REST API (Node.js/Express)
├── 🧠 ai_service_python/     # ML inference and Chatbot engine (Python/FastAPI)
├── 🗄️ database_models/       # Shared Mongoose schema definitions
├── 📚 docs/                  # In-depth architectural and API documentation
└── 🐳 docker-compose.yml     # Container orchestration for local development
```

---

## 🚀 Getting Started

### Prerequisites

Ensure you have the following installed before proceeding:
- **Node.js** (v18 or higher)
- **Python** (v3.10 or higher)
- **Flutter SDK** (v3.x)
- **Docker & Docker Compose** (highly recommended for local backend orchestration)

### Option 1: Docker Setup (Recommended)

The fastest way to get the backend services running is via Docker Compose.

```bash
# 1. Clone the repository
git clone <your-repo-url> KrushikaDhara
cd KrushikaDhara

# 2. Duplicate environment templates
cp backend_node_api/.env.example backend_node_api/.env
cp ai_service_python/.env.example ai_service_python/.env

# 3. Spin up all containers
docker-compose up --build
```

### Option 2: Manual Setup

If you prefer to run services bare-metal, follow these steps in separate terminal windows:

<details>
<summary><b>1. Start the Node.js Backend API</b></summary>

```bash
cd backend_node_api
npm install
cp .env.example .env   # Ensure you populate required API keys
npm run dev            # API runs on http://localhost:5000
```
</details>

<details>
<summary><b>2. Start the Python AI Microservice</b></summary>

```bash
cd ai_service_python
python -m venv venv
source venv/bin/activate   # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env       
uvicorn app.main:app --reload --port 8000
```
</details>

<details>
<summary><b>3. Launch the Admin Dashboard</b></summary>

```bash
cd admin_panel
npm install
npm run dev               # Dashboard runs on http://localhost:5173
```
</details>

<details>
<summary><b>4. Run the Mobile App</b></summary>

```bash
cd mobile_app_flutter
flutter pub get
flutter run               # Launches on your connected device or emulator
```
</details>

---

## 📚 Documentation

For deep dives into the platform's inner workings, check the `/docs` directory:
- [API Reference](docs/api_reference.md)
- [System Architecture](docs/architecture.md)
- [Setup Guide](docs/setup_guide.md)

---

## 📄 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.
