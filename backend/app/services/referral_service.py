from typing import List, Optional, Tuple
from sqlalchemy.orm import Session
from app.models.referral import ReferralModel
from app.schemas.referral import ReferralCreate, ReferralStatusEnum
from app.repositories.referral_repository import referral_repository, ReferralRepository
from app.core.exceptions import ReferralAlreadyExistsException, ReferralNotFoundException


class ReferralService:
    """Service handling business rules, validation, and orchestration for referrals."""

    def __init__(self, repo: ReferralRepository = referral_repository):
        self.repo = repo

    def create_referral(self, db: Session, referral_in: ReferralCreate) -> ReferralModel:
        """Create a new referral after checking for duplicate referral_id."""
        existing = self.repo.get_by_referral_id(db, referral_in.referral_id)
        if existing:
            raise ReferralAlreadyExistsException(referral_in.referral_id)

        return self.repo.create(db, referral_in)

    def get_referral(self, db: Session, referral_id: str) -> ReferralModel:
        """Retrieve a referral by referral_id or raise ReferralNotFoundException."""
        referral = self.repo.get_by_referral_id(db, referral_id)
        if not referral:
            raise ReferralNotFoundException(referral_id)
        return referral

    def update_referral_status(
        self,
        db: Session,
        referral_id: str,
        new_status: ReferralStatusEnum,
    ) -> ReferralModel:
        """Update referral status lifecycle state."""
        referral = self.get_referral(db, referral_id)
        status_str = new_status.value if hasattr(new_status, "value") else str(new_status)
        return self.repo.update_status(db, referral, status_str)

    def list_referrals(
        self,
        db: Session,
        skip: int = 0,
        limit: int = 100,
        status: Optional[str] = None,
    ) -> Tuple[List[ReferralModel], int]:
        """List referrals with pagination and optional filtering."""
        return self.repo.list_referrals(db, skip=skip, limit=limit, status=status)


referral_service = ReferralService()
