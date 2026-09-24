from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Text, DateTime
from sqlalchemy.sql import func
from app.db.database import Base


class ReferralModel(Base):
    """SQLAlchemy model representing a centralized referral in PostgreSQL."""

    __tablename__ = "referrals"

    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    referral_id = Column(String(64), unique=True, index=True, nullable=False)
    
    # Patient Demographic Fields (Minimum Data for Synchronization)
    patient_name = Column(String(255), nullable=False)
    age = Column(Integer, nullable=False)
    gender = Column(String(32), nullable=False)
    village_or_location = Column(String(255), nullable=True)
    contact_number = Column(String(64), nullable=True)

    # Referral Routing & Clinical Metadata
    source_facility = Column(String(128), nullable=False)
    destination_facility = Column(String(128), nullable=False)
    urgency = Column(String(32), default="ROUTINE", nullable=False)
    reason = Column(Text, nullable=False)
    clinical_notes_summary = Column(Text, nullable=True)

    # Status Lifecycle
    status = Column(String(32), default="CREATED", nullable=False)

    # Timestamps
    created_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        nullable=False,
    )
    updated_at = Column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc),
        onupdate=lambda: datetime.now(timezone.utc),
        nullable=False,
    )

    def __repr__(self) -> str:
        return f"<ReferralModel(referral_id='{self.referral_id}', patient_name='{self.patient_name}', status='{self.status}')>"
