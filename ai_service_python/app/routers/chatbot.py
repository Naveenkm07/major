"""
AI Chatbot Router
POST /api/v1/chat — JWT-protected, JSON request
"""

import logging
from fastapi import APIRouter, Depends, HTTPException, status
from app.auth import verify_jwt, AuthenticatedUser
from app.models.schemas import ChatRequest, ChatResponse, ErrorResponse
from app.services.chatbot_service import chatbot_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1", tags=["Chatbot"])


@router.post(
    "/chat",
    response_model=ChatResponse,
    responses={
        401: {"model": ErrorResponse, "description": "Unauthorized"},
        400: {"model": ErrorResponse, "description": "Invalid input"},
        500: {"model": ErrorResponse, "description": "Server error"},
    },
    summary="Chat with AI farming assistant",
    description=(
        "Send a question to the KrushikaDhara AI chatbot. "
        "Supports English (en) and Hindi (hi). "
        "Returns an answer with optional follow-up suggestions."
    ),
)
async def chat(
    request: ChatRequest,
    user: AuthenticatedUser = Depends(verify_jwt),
):
    """
    Chatbot endpoint.

    1. Receives the farmer's question with optional language and context.
    2. Sends to OpenAI GPT (if configured) or rule-based engine.
    3. Returns the answer with detected intent and follow-up suggestions.
    """

    # ─── Input validation (Pydantic handles min/max length) ───
    question = request.question.strip()
    if not question:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Question cannot be empty or whitespace only.",
        )

    # ─── Get chatbot response ────────────────────────
    try:
        response = await chatbot_service.get_response(
            question=question,
            language=request.language,
            context=request.context,
        )

        logger.info(
            f"User {user.user_id} asked [{request.language}]: "
            f"'{question[:80]}...' → intent={response.intent}, source={response.source}"
        )

        return response

    except Exception as e:
        logger.error(f"Chat failed for user {user.user_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Chatbot service error: {str(e)}",
        )
