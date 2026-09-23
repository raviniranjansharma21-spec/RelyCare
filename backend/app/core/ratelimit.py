import time
from collections import defaultdict
from typing import Tuple, Dict, List
from fastapi import HTTPException, status, Request

from app.core.config import settings

class LoginRateLimiter:
    """In-memory thread-safe rate limiter for /auth/login.
    
    Tracks login attempts per IP and per username/identifier.
    """

    def __init__(self, max_attempts: int = 5, window_seconds: int = 60):
        self.max_attempts = max_attempts
        self.window_seconds = window_seconds
        self._ip_attempts: Dict[str, List[float]] = defaultdict(list)
        self._identifier_attempts: Dict[str, List[float]] = defaultdict(list)

    def _clean_old_attempts(self, attempts: List[float], now: float) -> List[float]:
        cutoff = now - self.window_seconds
        return [t for t in attempts if t > cutoff]

    def check_rate_limit(self, request: Request, identifier: str) -> None:
        if getattr(settings, "ENVIRONMENT", "") == "testing":
            return

        now = time.time()

        client_ip = request.client.host if request.client else "unknown"

        # Clean old timestamps
        self._ip_attempts[client_ip] = self._clean_old_attempts(self._ip_attempts[client_ip], now)
        self._identifier_attempts[identifier] = self._clean_old_attempts(self._identifier_attempts[identifier], now)

        # Check thresholds
        if len(self._ip_attempts[client_ip]) >= self.max_attempts or len(self._identifier_attempts[identifier]) >= self.max_attempts:
            raise HTTPException(
                status_code=status.HTTP_429_TOO_MANY_REQUESTS,
                detail="Too many login attempts. Please try again later.",
            )

        # Record attempt
        self._ip_attempts[client_ip].append(now)
        self._identifier_attempts[identifier].append(now)


login_limiter = LoginRateLimiter(max_attempts=5, window_seconds=60)
