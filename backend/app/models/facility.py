from datetime import datetime, timezone
from sqlalchemy import Column, Integer, String, Boolean, DateTime
from app.db.database import Base


class FacilityModel(Base):
    """SQLAlchemy model representing a healthcare facility in RelyCare."""

    __tablename__ = "facilities"

    id = Column(Integer, primary_key=True, autoincrement=True, index=True)
    facility_code = Column(String(64), unique=True, index=True, nullable=False)
    name = Column(String(255), nullable=False)
    facility_type = Column(String(64), nullable=False)  # PHC or DISTRICT_HOSPITAL
    is_active = Column(Boolean, default=True, nullable=False)

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
        return f"<FacilityModel(code='{self.facility_code}', name='{self.name}', type='{self.facility_type}')>"
