"""
JWT Authentication dependency for FastAPI.
Validates Bearer tokens issued by the Node.js backend.
"""

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import jwt
from app.config import get_settings, Settings

security = HTTPBearer()


class AuthenticatedUser:
    """Represents a decoded JWT user payload."""

    def __init__(self, user_id: str, phone_number: str = None):
        self.user_id = user_id
        self.phone_number = phone_number

    def __repr__(self):
        return f"AuthenticatedUser(id={self.user_id})"


async def verify_jwt(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    settings: Settings = Depends(get_settings),
) -> AuthenticatedUser:
    """
    FastAPI dependency that extracts and verifies the JWT Bearer token.
    Raises 401 if the token is missing, expired, or invalid.
    """
    token = credentials.credentials

    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET,
            algorithms=[settings.JWT_ALGORITHM],
        )
    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token has expired",
            headers={"WWW-Authenticate": "Bearer"},
        )
    except jwt.InvalidTokenError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Invalid token: {str(e)}",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user_id = payload.get("id")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token payload missing user ID",
        )

    return AuthenticatedUser(
        user_id=user_id,
        phone_number=payload.get("phoneNumber"),
    )
