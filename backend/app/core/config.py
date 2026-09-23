from typing import List, Union
from pydantic import AnyHttpUrl, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """RelyCare Backend Application Settings."""

    PROJECT_NAME: str = "RelyCare Backend API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    ENVIRONMENT: str = "development"

    # PostgreSQL Database URL
    # Can be overridden via DATABASE_URL environment variable or .env file
    DATABASE_URL: str = "postgresql://postgres:postgres@localhost:5432/relycare_db"

    # Security & JWT Configuration
    JWT_SECRET_KEY: str = "dev-secret-key-change-in-production-relycare-2026"
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440  # 24 hours

    @field_validator("JWT_SECRET_KEY")
    @classmethod
    def validate_jwt_secret_key(cls, v: str, info) -> str:
        env = info.data.get("ENVIRONMENT", "development")
        if env != "development" and v == "dev-secret-key-change-in-production-relycare-2026":
            raise ValueError("JWT_SECRET_KEY must be changed from the default value in non-development environments")
        return v

    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost",
        "http://localhost:3000",
        "http://localhost:8000",
        "http://localhost:8080",
        "http://127.0.0.1",
        "http://127.0.0.1:8000",
    ]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )


settings = Settings()
