from typing import Optional
from pydantic import BaseModel, ConfigDict


class HealthResponse(BaseModel):
    """Health check endpoint response schema."""
    status: str = "ok"
    version: Optional[str] = None
    environment: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)


class ErrorResponse(BaseModel):
    """Standardized API error response schema."""
    detail: str

    model_config = ConfigDict(from_attributes=True)


class MessageResponse(BaseModel):
    """Simple status/confirmation response."""
    message: str

    model_config = ConfigDict(from_attributes=True)
