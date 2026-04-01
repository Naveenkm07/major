# Deployment Guide

## Production Deployment with Docker

### 1. Build Production Images
```bash
docker-compose -f docker-compose.yml build
```

### 2. Environment Configuration
- Set `NODE_ENV=production` in backend `.env`
- Use strong `JWT_SECRET` (64+ character random string)
- Set proper MongoDB credentials
- Configure real AWS S3 and Firebase credentials

### 3. Deploy
```bash
# Start in detached mode
docker-compose up -d

# View logs
docker-compose logs -f backend
docker-compose logs -f ai_service
```

### 4. SSL/HTTPS
Use a reverse proxy (Nginx or Caddy) for SSL termination:

```nginx
server {
    listen 443 ssl;
    server_name api.krushikadhara.com;

    ssl_certificate /path/to/cert.pem;
    ssl_certificate_key /path/to/key.pem;

    location / {
        proxy_pass http://localhost:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

## Cloud Deployment Options

| Platform | Service | Recommended For |
|----------|---------|-----------------|
| AWS | ECS + ECR | Backend + AI Service containers |
| AWS | DocumentDB | MongoDB-compatible database |
| AWS | S3 | File storage (already configured) |
| GCP | Cloud Run | Serverless containers |
| Azure | AKS | Kubernetes orchestration |
| Railway | App | Quick deployment |
| Render | Web Service | Free tier available |

## Mobile App Release

### Android
```bash
cd mobile_app_flutter
flutter build apk --release
# APK: build/app/outputs/flutter-apk/app-release.apk
```

### iOS
```bash
flutter build ios --release
# Open in Xcode for App Store submission
```

## Monitoring
- Use `winston` logs (backend writes to `logs/` directory)
- Setup PM2 for Node.js process management outside Docker
- Monitor MongoDB with MongoDB Compass
- Health check endpoints: `GET /api/v1/health` and `GET /health`
