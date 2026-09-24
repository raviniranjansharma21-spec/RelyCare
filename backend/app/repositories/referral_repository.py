from typing import List, Optional, Tuple
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from sqlalchemy import func
from app.models.referral import ReferralModel
from app.schemas.referral import ReferralCreate


class ReferralRepository:
    """Data access repository for ReferralModel in PostgreSQL."""

    def get_by_referral_id(self, db: Session, referral_id: str) -> Optional[ReferralModel]:
        """Fetch a single referral by its unique referral_id token."""
        return db.query(ReferralModel).filter(ReferralModel.referral_id == referral_id).first()

    def get_by_id(self, db: Session, id: int) -> Optional[ReferralModel]:
        """Fetch a single referral by its primary key ID."""
        return db.query(ReferralModel).filter(ReferralModel.id == id).first()

    def list_referrals(
        self,
        db: Session,
        skip: int = 0,
        limit: int = 100,
        status: Optional[str] = None,
        facility_code: Optional[str] = None,
    ) -> Tuple[List[ReferralModel], int]:
        """List referrals with optional status and facility filtering and pagination. Returns (items, total_count)."""
        query = db.query(ReferralModel)
        if status:
            query = query.filter(ReferralModel.status == status)
        if facility_code:
            query = query.filter(
                (ReferralModel.source_facility == facility_code)
                | (ReferralModel.destination_facility == facility_code)
            )
        
        total = query.count()
        items = query.order_by(ReferralModel.created_at.desc()).offset(skip).limit(limit).all()
        return items, total


    def create(self, db: Session, referral_in: ReferralCreate) -> ReferralModel:
        """Insert a new referral record into the database."""
        db_obj = ReferralModel(
            referral_id=referral_in.referral_id,
            patient_name=referral_in.patient_name,
            age=referral_in.age,
            gender=referral_in.gender,
            village_or_location=referral_in.village_or_location,
            contact_number=referral_in.contact_number,
            source_facility=referral_in.source_facility,
            destination_facility=referral_in.destination_facility,
            urgency=referral_in.urgency.value if hasattr(referral_in.urgency, "value") else str(referral_in.urgency),
            reason=referral_in.reason,
            clinical_notes_summary=referral_in.clinical_notes_summary,
            status=referral_in.status.value if hasattr(referral_in.status, "value") else str(referral_in.status),
        )
        db.add(db_obj)
        db.commit()
        db.refresh(db_obj)
        return db_obj

    def update_status(self, db: Session, referral: ReferralModel, new_status: str) -> ReferralModel:
        """Update the status and updated_at timestamp of an existing referral."""
        referral.status = new_status
        referral.updated_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(referral)
        return referral


referral_repository = ReferralRepository()
