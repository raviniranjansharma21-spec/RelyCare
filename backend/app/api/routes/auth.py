from fastapi import APIRouter, Depends, HTTPException, status, Request
from sqlalchemy.orm import Session

from app.db.database import get_db
from app.models.user import UserModel
from app.models.facility import FacilityModel
from app.schemas.auth import LoginRequest, TokenResponse, UserResponse, FacilityResponse
from app.core.security import verify_password, hash_password, create_access_token
from app.core.ratelimit import login_limiter
from app.api.dependencies.auth import get_current_active_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

# Dummy hash generated at module initialization for timing-attack resistance
_DUMMY_HASH = hash_password("dummy-password-for-timing")


@router.post(
    "/login",
    response_model=TokenResponse,
    status_code=status.HTTP_200_OK,
    summary="Authenticate user and return JWT token",
)
def login(
    request: Request,
    login_data: LoginRequest,
    db: Session = Depends(get_db),
) -> TokenResponse:
    """Authenticate user credentials against PostgreSQL and return a JWT access token."""
    username_or_id = login_data.username.strip()

    # Rate limiting check (per IP and per identifier)
    login_limiter.check_rate_limit(request, username_or_id)
    
    # Query user by username, email, or phone identifier
    user = (
        db.query(UserModel)
        .filter(
            (UserModel.username == username_or_id)
            | (UserModel.email == username_or_id)
            | (UserModel.phone == username_or_id)
        )
        .first()
    )

    stored_hash = user.password_hash if user else _DUMMY_HASH
    password_ok = verify_password(login_data.password, stored_hash)

    if not user or not password_ok:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid username or password",
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive",
        )

    # Generate access token
    access_token = create_access_token(
        subject=user.username,
        extra_claims={
            "role": user.role,
            "facility_id": user.facility_id,
            "user_id": user.id,
        },
    )

    # Fetch facility information if available
    facility_obj = None
    if user.facility_id:
        facility = db.query(FacilityModel).filter(FacilityModel.facility_code == user.facility_id).first()
        if facility:
            facility_obj = FacilityResponse.model_validate(facility)

    user_resp = UserResponse(
        id=user.id,
        username=user.username,
        email=user.email,
        phone=user.phone,
        role=user.role,
        facility_id=user.facility_id,
        is_active=user.is_active,
        facility=facility_obj,
    )

    return TokenResponse(
        access_token=access_token,
        token_type="bearer",
        user=user_resp,
    )


@router.get(
    "/me",
    response_model=UserResponse,
    summary="Get current authenticated user profile",
)
def get_me(
    current_user: UserModel = Depends(get_current_active_user),
    db: Session = Depends(get_db),
) -> UserResponse:
    """Return the profile and facility association of the currently authenticated user."""
    facility_obj = None
    if current_user.facility_id:
        facility = db.query(FacilityModel).filter(FacilityModel.facility_code == current_user.facility_id).first()
        if facility:
            facility_obj = FacilityResponse.model_validate(facility)

    return UserResponse(
        id=current_user.id,
        username=current_user.username,
        email=current_user.email,
        phone=current_user.phone,
        role=current_user.role,
        facility_id=current_user.facility_id,
        is_active=current_user.is_active,
        facility=facility_obj,
    )
