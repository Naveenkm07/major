# Infrastructure & Security Guide

## ☁️ Cloud Infrastructure (AWS / GCP)

### 1. Recommended Setup on AWS
To host KrushikaDhara at scale, the following AWS architecture is recommended:

- **EC2 Instances / ECS**: 
  - Host the Dockerized Node.js backend on a standard `t3.medium` instance.
  - Host the Python AI microservice on a compute-optimized or GPU-enabled instance (e.g., `g4dn.xlarge` if running complex local LLMs, or `t3.large` for standard TensorFlow models).
- **Application Load Balancer (ALB)**: Routes incoming traffic on port 443 (HTTPS) to the Node.js instances (port 5000). Terminates SSL certificates managed by ACM.
- **Amazon S3 + CloudFront**: For storing crop images and serving them efficiently to rural areas with low latency.
- **MongoDB Atlas**: Use the AWS-peered tier to ensure database traffic never leaves the private AWS network.

## 🔐 Security Best Practices Implemented

### Middleware Configured in Node.js
- **Helmet**: Secures Express apps by setting various HTTP headers.
- **CORS**: Configured strictly to allow only recognized frontend origins or the mobile app bundle identifier.
- **Express Rate Limit**: Applied globally (`config.rateLimit.windowMs` = 15 mins, `config.rateLimit.max` = 100 requests) to prevent DDoS attacks and brute-force login attempts.
- **Mongo Sanitize & HPP**: Prevents NoSQL injection attacks (`express-mongo-sanitize`) and HTTP Parameter Pollution (`hpp`).

### Authentication & Passwords
- **Bcrypt**: All passwords are hashed using `bcryptjs` with a salt round of 10 prior to database insertion.
- **JWT**: Stateless, short-lived JSON Web Tokens passed inside the Authorization header as `Bearer <token>`.

### Environment Secret Management
- Secrets (`JWT_SECRET`, `MONGO_URI`, `AWS` keys) must be injected securely at runtime via GitHub Actions secrets and Docker environment variables. **Never hardcode secrets in the repository.**

## 📊 Logging and Monitoring

### Winston Logger
The application uses Winston for intelligent log recording.
- Development mode logs output to the console with colorized formats.
- Production mode writes error logs to files (`logs/error.log` and `logs/combined.log`) in JSON format.

### Prometheus & Grafana (Next Step)
For production container monitoring:
1. Instrument the Node.js code with `prom-client` to expose a `/metrics` endpoint.
2. Deploy a **Prometheus** docker container to scrape the metrics.
3. Deploy **Grafana** to visualize CPU, RAM, database query times, and active concurrent farmers using dashboards.
