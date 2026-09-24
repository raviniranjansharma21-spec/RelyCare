"""API routers."""
from .health import router as health_router
from .referrals import router as referrals_router
from .auth import router as auth_router

__all__ = ["health_router", "referrals_router", "auth_router"]
