# KrushikaDhara System Architecture

## High-Level Architecture Diagram

```mermaid
graph TD
    %% Define Styles
    classDef mobile fill:#4fc3f7,stroke:#01579b,stroke-width:2px,color:black
    classDef apiGateway fill:#ffb74d,stroke:#e65100,stroke-width:2px,color:black
    classDef backend fill:#81c784,stroke:#1b5e20,stroke-width:2px,color:black
    classDef ai fill:#ba68c8,stroke:#4a148c,stroke-width:2px,color:black
    classDef db fill:#e57373,stroke:#b71c1c,stroke-width:2px,color:black
    classDef 3rdparty fill:#e0e0e0,stroke:#616161,stroke-width:2px,stroke-dasharray: 5, 5,color:black

    %% Mobile App
    subgraph "Frontend Layer"
        FlutterApp["📱 KrushikaDhara Mobile App\n(Flutter)"]:::mobile
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
    CDN -. "Points to" .-> S3

    FlutterApp -- "HTTPS / REST" --> AGW
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

## Component Details

### 1. Flutter Mobile Application
The user-facing mobile app handles offline persistence using **Hive**, state management, and direct connectivity to the API Gateway. Modules include the voice assistant UI, Maps integration for Farmer Connect, and Dashboard metrics.

### 2. Node.js Backend 
The primary monolith server handling core business logic, including:
- **JWT Authentication** and Profile Management.
- **Community Services** handling chat and posts.
- **Government Schemes** CRUD operations through an admin interface.
- **Node-Cron Jobs** fetching external API data every 3 hours.

### 3. Python AI Microservice
A stateless containerized service running **FastAPI**. Heavily optimized with **OpenCV-Python-Headless** for image processing and **Transformers/PyTorch** for model inference (Pest Detection and Chatbot). Only the Node.js backend communicates directly with this microservice, hiding it from the public internet.

### 4. Database & Storage
- **MongoDB Atlas**: Fully managed NoSQL cloud database storing all application state. Secured with VPC peering.
- **AWS S3**: Scalable object storage for all images uploaded by farmers. Served to the end user via **CloudFront** CDN to reduce latency.
