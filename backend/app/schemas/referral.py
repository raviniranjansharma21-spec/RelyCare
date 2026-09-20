from datetime import datetime
from enum import Enum
from typing import Optional, List
from pydantic import BaseModel, Field, ConfigDict, field_validator


class ReferralStatusEnum(str, Enum):
    """RelyCare Referral Lifecycle Statuses."""
    CREATED = "CREATED"
    QUEUED = "QUEUED"
    SYNCED = "SYNCED"
    SENT = "SENT"
    RECEIVED = "RECEIVED"
    PATIENT_ARRIVED = "PATIENT_ARRIVED"
    UNDER_TREATMENT = "UNDER_TREATMENT"
    COMPLETED = "COMPLETED"


class ReferralUrgencyEnum(str, Enum):
    """Referral Urgency Tiers."""
    ROUTINE = "ROUTINE"
    URGENT = "URGENT"
    EMERGENCY = "EMERGENCY"


class ReferralBase(BaseModel):
    """Base schema for referral data shared across create and responses."""
    referral_id: str = Field(
        ...,
        min_length=3,
        max_length=64,
        description="Unique referral token or identifier (e.g. RC-2026-000142)",
        examples=["RC-2026-000142"],
    )
    patient_name: str = Field(
        ...,
        min_length=1,
        max_length=255,
        description="Patient's full name",
        examples=["Rahul Sharma"],
    )
    age: int = Field(
        ...,
        ge=0,
        le=150,
        description="Patient's age in years (0-150)",
        examples=[42],
    )
    gender: str = Field(
        ...,
        min_length=1,
        max_length=32,
        description="Patient's gender",
        examples=["Male"],
    )
    village_or_location: Optional[str] = Field(
        None,
        max_length=255,
        description="Patient's village or home location",
        examples=["Village Rampur"],
    )
    contact_number: Optional[str] = Field(
        None,
        max_length=64,
        description="Patient contact phone number",
        examples=["+91 9876543210"],
    )
    source_facility: str = Field(
        ...,
        min_length=1,
        max_length=128,
        description="Originating PHC or health facility identifier",
        examples=["PHC-MUM"],
    )
    destination_facility: str = Field(
        ...,
        min_length=1,
        max_length=128,
        description="Target district hospital or tertiary centre identifier",
        examples=["DIST-HOSP-01"],
    )
    urgency: ReferralUrgencyEnum = Field(
        default=ReferralUrgencyEnum.ROUTINE,
        description="Urgency tier of the referral",
        examples=["URGENT"],
    )
    reason: str = Field(
        ...,
        min_length=1,
        description="Clinical reason for referral",
        examples=["Specialist consultation and ultrasound evaluation required"],
    )
    clinical_notes_summary: Optional[str] = Field(
        None,
        description="Summary of clinical examination or notes",
        examples=["Patient presented with abdominal pain for 3 days"],
    )

    @field_validator("referral_id", "patient_name", "source_facility", "destination_facility", "reason")
    @classmethod
    def strip_and_validate_non_empty(cls, v: str) -> str:
        stripped = v.strip()
        if not stripped:
            raise ValueError("Field cannot be empty or whitespace only.")
        return stripped


class ReferralCreate(ReferralBase):
    """Schema for creating a referral from Flutter sync."""
    status: ReferralStatusEnum = Field(
        default=ReferralStatusEnum.CREATED,
        description="Initial referral status upon ingestion",
        examples=["CREATED"],
    )


class ReferralStatusUpdate(BaseModel):
    """Schema for updating the status of an existing referral."""
    status: ReferralStatusEnum = Field(
        ...,
        description="New lifecycle status for the referral",
        examples=["RECEIVED"],
    )


class ReferralResponse(ReferralBase):
    """Complete schema for referral responses returned to API clients."""
    id: int = Field(..., description="Server database primary key ID")
    status: ReferralStatusEnum = Field(..., description="Current referral status")
    created_at: datetime = Field(..., description="Timestamp of creation (UTC)")
    updated_at: datetime = Field(..., description="Timestamp of last update (UTC)")

    model_config = ConfigDict(from_attributes=True)


class ReferralListResponse(BaseModel):
    """Schema for paginated list of referrals."""
    items: List[ReferralResponse]
    total: int
    skip: int
    limit: int

    model_config = ConfigDict(from_attributes=True)
