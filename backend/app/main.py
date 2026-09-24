import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.exceptions import RequestValidationError

from app.core.config import settings
from app.db.database import Base, engine
from app.api.routes import health_router, referrals_router, auth_router


# Configure basic structured logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [%(name)s] %(message)s",
)
logger = logging.getLogger("relycare.backend")


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifecycle hook: logs application startup/shutdown."""
    logger.info("Starting RelyCare Backend API v%s...", settings.VERSION)
    yield
    logger.info("Shutting down RelyCare Backend API...")



app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description=(
        "Centralized REST API for RelyCare Offline-First Referral Continuity System. "
        "Receives synchronized referrals from local PHC SQLite databases and persists to PostgreSQL."
    ),
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc",
    lifespan=lifespan,
)

# Set up CORS middleware for Flutter web and desktop/mobile client access
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.BACKEND_CORS_ORIGINS,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )


# Exception Handlers
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    """Format request validation errors consistently without exposing internal code."""
    logger.warning("Validation error on %s %s: %s", request.method, request.url.path, exc.errors())
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content={
            "detail": "Invalid request payload",
            "errors": [
                {
                    "loc": list(err.get("loc", [])),
                    "msg": err.get("msg", ""),
                    "type": err.get("type", ""),
                }
                for err in exc.errors()
            ],
        },
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    """Sanitize unexpected 500 errors to prevent credential or internal trace leakage."""
    logger.error("Unhandled server exception on %s %s: %s", request.method, request.url.path, str(exc), exc_info=True)
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={"detail": "An internal server error occurred. Please try again later."},
    )


# Route Registration
# 1. Root and versioned health endpoints
app.include_router(health_router)
app.include_router(health_router, prefix=settings.API_V1_STR)

# 2. Versioned Auth endpoints (/api/v1/auth)
app.include_router(auth_router, prefix=settings.API_V1_STR)

# 3. Versioned Referral endpoints (/api/v1/referrals)
app.include_router(referrals_router, prefix=settings.API_V1_STR)
