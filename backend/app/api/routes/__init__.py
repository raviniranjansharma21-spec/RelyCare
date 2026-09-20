"""API routers."""
from .health import router as health_router
from .referrals import router as referrals_router

__all__ = ["health_router", "referrals_router"]
