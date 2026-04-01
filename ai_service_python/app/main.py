"""
KrushikaDhara AI Microservice
FastAPI application entry point.

Endpoints:
  POST /api/v1/detect_pest — Crop disease classification (JWT protected)
  POST /api/v1/chat        — AI farming assistant (JWT protected)
  GET  /health             — Health check (public)
"""

import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError

from app.config import get_settings
from app.routers import disease, chatbot, crop_recommendation

# ─── Logging config ──────────────────────────────────
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s │ %(levelname)-7s │ %(name)s │ %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
logger = logging.getLogger("krushikadhara.ai")

# ─── Lifespan (startup/shutdown) ─────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    logger.info("=" * 60)
    logger.info(f"🌾 {settings.APP_NAME} starting...")
    logger.info(f"   Debug mode : {settings.DEBUG}")
    logger.info(f"   ML model   : {settings.DISEASE_MODEL_PATH}")
    logger.info(f"   S3 bucket  : {settings.AWS_S3_BUCKET}")
    logger.info(f"   OpenAI     : {'configured' if settings.OPENAI_API_KEY else 'not configured (rule-based fallback)'}")
    logger.info("=" * 60)

    yield  # Application runs

    logger.info("🔴 AI Service shutting down...")


# ─── Create FastAPI app ──────────────────────────────
settings = get_settings()

app = FastAPI(
    title=settings.APP_NAME,
    description=(
        "AI microservice for KrushikaDhara Smart Farming Companion. "
        "Provides crop disease detection and AI chatbot for Indian farmers."
    ),
    version="1.0.0",
    lifespan=lifespan,
    docs_url="/docs",
    redoc_url="/redoc",
)

# ─── CORS Middleware ─────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:5000",
        "http://localhost:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ─── Global Exception Handlers ──────────────────────
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Return cleaner validation error messages."""
    errors = []
    for error in exc.errors():
        field = " → ".join(str(loc) for loc in error["loc"])
        errors.append(f"{field}: {error['msg']}")

    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "detail": "Validation error",
            "errors": errors,
        },
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Catch-all handler for unhandled exceptions."""
    logger.error(f"Unhandled exception on {request.method} {request.url}: {exc}")
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "detail": "Internal server error. Please try again later.",
        },
    )


# ─── Register Routers ───────────────────────────────
app.include_router(disease.router)
app.include_router(chatbot.router)
app.include_router(crop_recommendation.router)


# ─── Health Check (public) ───────────────────────────
@app.get(
    "/health",
    tags=["Health"],
    summary="Service health check",
)
async def health_check():
    """Returns service status. Used by Docker HEALTHCHECK and load balancers."""
    from app.services.disease_service import disease_service
    from app.services.s3_service import s3_service

    return {
        "status": "healthy",
        "service": settings.APP_NAME,
        "version": "1.0.0",
        "components": {
            "disease_model": "loaded" if disease_service._model_loaded else "fallback",
            "s3": "connected" if s3_service.is_available else "unavailable",
            "chatbot": "openai" if settings.OPENAI_API_KEY else "rule_based",
        },
    }
