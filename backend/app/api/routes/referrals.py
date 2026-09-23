from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.referral import (
    ReferralCreate,
    ReferralResponse,
    ReferralStatusUpdate,
    ReferralListResponse,
    ReferralStatusEnum,
)
from app.schemas.common import ErrorResponse
from app.services.referral_service import referral_service
from app.models.user import UserModel
from app.api.dependencies.auth import get_current_active_user
from app.core.exceptions import (
    ReferralAlreadyExistsException,
    ReferralNotFoundException,
)

router = APIRouter(prefix="/referrals", tags=["Referrals"])


@router.post(
    "",
    response_model=ReferralResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Ingest a synchronized referral from client",
    responses={
        status.HTTP_201_CREATED: {"description": "Referral successfully created and stored in PostgreSQL"},
        status.HTTP_401_UNAUTHORIZED: {"description": "Authentication token missing or invalid"},
        status.HTTP_403_FORBIDDEN: {"description": "Facility or role authorization denied"},
        status.HTTP_409_CONFLICT: {"model": ErrorResponse, "description": "Duplicate referral_id detected"},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"description": "Validation error in referral payload"},
    },
)
def create_referral(
    referral_in: ReferralCreate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_active_user),
) -> ReferralResponse:
    """Receive a referral created offline/online in RelyCare and persist it in the central server database."""
    if current_user.role not in {"PHC_STAFF", "HOSPITAL_STAFF"}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Role '{current_user.role}' cannot perform this operation",
        )

    if current_user.role == "PHC_STAFF" and current_user.facility_id and referral_in.source_facility != current_user.facility_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"PHC staff at facility '{current_user.facility_id}' cannot create referrals for source facility '{referral_in.source_facility}'",
        )

    try:
        created = referral_service.create_referral(db=db, referral_in=referral_in)
        return ReferralResponse.model_validate(created)
    except ReferralAlreadyExistsException as e:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=e.message,
        )


@router.get(
    "/{referral_id}",
    response_model=ReferralResponse,
    summary="Get referral by ID",
    responses={
        status.HTTP_200_OK: {"description": "Referral details"},
        status.HTTP_401_UNAUTHORIZED: {"description": "Authentication token missing or invalid"},
        status.HTTP_403_FORBIDDEN: {"description": "Not authorized to access referral for another facility"},
        status.HTTP_404_NOT_FOUND: {"model": ErrorResponse, "description": "Referral not found"},
    },
)
def get_referral(
    referral_id: str,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_active_user),
) -> ReferralResponse:
    """Retrieve an existing referral by its unique RelyCare identifier."""
    try:
        referral = referral_service.get_referral(db=db, referral_id=referral_id)

        if (
            current_user.facility_id
            and referral.source_facility != current_user.facility_id
            and referral.destination_facility != current_user.facility_id
        ):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not authorized to access this referral",
            )

        return ReferralResponse.model_validate(referral)
    except ReferralNotFoundException as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=e.message,
        )


@router.patch(
    "/{referral_id}/status",
    response_model=ReferralResponse,
    summary="Update referral status",
    responses={
        status.HTTP_200_OK: {"description": "Status updated successfully"},
        status.HTTP_401_UNAUTHORIZED: {"description": "Authentication token missing or invalid"},
        status.HTTP_403_FORBIDDEN: {"description": "Not authorized to update status for this referral"},
        status.HTTP_404_NOT_FOUND: {"model": ErrorResponse, "description": "Referral not found"},
        status.HTTP_422_UNPROCESSABLE_ENTITY: {"description": "Invalid status value"},
    },
)
def update_referral_status(
    referral_id: str,
    status_update: ReferralStatusUpdate,
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_active_user),
) -> ReferralResponse:
    """Update the lifecycle status of a referral (e.g. RECEIVED, PATIENT_ARRIVED, UNDER_TREATMENT, COMPLETED)."""
    if current_user.role not in {"PHC_STAFF", "HOSPITAL_STAFF"}:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Role '{current_user.role}' cannot perform this operation",
        )

    try:
        referral = referral_service.get_referral(db=db, referral_id=referral_id)

        if current_user.role == "HOSPITAL_STAFF" and current_user.facility_id and referral.destination_facility != current_user.facility_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Hospital staff at '{current_user.facility_id}' cannot update referral destined for '{referral.destination_facility}'",
            )

        if current_user.role == "PHC_STAFF" and current_user.facility_id and referral.source_facility != current_user.facility_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"PHC staff at '{current_user.facility_id}' cannot update referral originating from '{referral.source_facility}'",
            )

        updated = referral_service.update_referral_status(
            db=db,
            referral_id=referral_id,
            new_status=status_update.status,
        )
        return ReferralResponse.model_validate(updated)
    except ReferralNotFoundException as e:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=e.message,
        )


@router.get(
    "",
    response_model=ReferralListResponse,
    summary="List referrals",
    responses={
        status.HTTP_200_OK: {"description": "Paginated list of referrals"},
        status.HTTP_401_UNAUTHORIZED: {"description": "Authentication token missing or invalid"},
    },
)
def list_referrals(
    skip: int = Query(0, ge=0, description="Pagination offset"),
    limit: int = Query(100, ge=1, le=500, description="Pagination limit"),
    status: Optional[ReferralStatusEnum] = Query(None, description="Filter by referral lifecycle status"),
    db: Session = Depends(get_db),
    current_user: UserModel = Depends(get_current_active_user),
) -> ReferralListResponse:
    """List referrals with optional status filtering and pagination for the user's facility."""
    status_str = status.value if status else None
    items, total = referral_service.list_referrals(
        db=db,
        skip=skip,
        limit=limit,
        status=status_str,
        facility_code=current_user.facility_id,
    )
    return ReferralListResponse(
        items=[ReferralResponse.model_validate(item) for item in items],
        total=total,
        skip=skip,
        limit=limit,
    )
