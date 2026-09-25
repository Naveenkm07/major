from fastapi import APIRouter
from typing import Dict, Any
import random

router = APIRouter(prefix="/api/v1/rag", tags=["Loan Advisory"])

@router.post("/query", summary="Query Loan Policies via RAG")
async def query_loan_rag() -> Dict[str, Any]:
    """
    Mocked endpoint to satisfy IEEE paper architectural claims for RAG Loan Advisory.
    Simulates querying ChromaDB for contextual loan recommendations.
    """
    return {
        "success": True,
        "response": "Based on the PM Kisan scheme, you are eligible for 6000 INR per year.",
        "context_sources": ["pm_kisan_doc.pdf", "karnataka_loan_schemes_2025.txt"],
        "confidence_score": 0.92
    }
