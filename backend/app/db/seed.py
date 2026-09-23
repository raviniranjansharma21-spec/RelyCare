import os
from app.db.database import SessionLocal
from app.models.facility import FacilityModel
from app.models.user import UserModel
from app.core.security import hash_password


def seed_development_data():
    """Seed development test facilities and staff users safely into local PostgreSQL."""
    phc_password = os.getenv("DEV_PHC_PASSWORD")
    dh_password = os.getenv("DEV_HOSPITAL_PASSWORD")

    if not phc_password or not dh_password:
        raise RuntimeError(
            "DEV_PHC_PASSWORD and DEV_HOSPITAL_PASSWORD environment variables must be set before running seed script."
        )

    db = SessionLocal()
    try:
        # 1. Seed facilities
        phc_code = os.getenv("DEV_PHC_CODE", "PHC-TEST")
        phc = db.query(FacilityModel).filter(FacilityModel.facility_code == phc_code).first()
        if not phc:
            phc = FacilityModel(
                facility_code=phc_code,
                name="Primary Health Centre Test",
                facility_type="PHC",
                is_active=True,
            )
            db.add(phc)

        dh_code = os.getenv("DEV_DH_CODE", "DH-TEST")
        dh = db.query(FacilityModel).filter(FacilityModel.facility_code == dh_code).first()
        if not dh:
            dh = FacilityModel(
                facility_code=dh_code,
                name="District Hospital Test",
                facility_type="DISTRICT_HOSPITAL",
                is_active=True,
            )
            db.add(dh)

        db.commit()

        # 2. Seed development users
        phc_username = os.getenv("DEV_PHC_USERNAME", "phc_user1")

        u_phc = db.query(UserModel).filter(UserModel.username == phc_username).first()
        if not u_phc:
            u_phc = UserModel(
                username=phc_username,
                email="phc_user1@relycare.local",
                phone="+919800000111",
                password_hash=hash_password(phc_password),
                role="PHC_STAFF",
                facility_id=phc_code,
                is_active=True,
            )
            db.add(u_phc)

        dh_username = os.getenv("DEV_HOSPITAL_USERNAME", "hosp_user1")

        u_dh = db.query(UserModel).filter(UserModel.username == dh_username).first()
        if not u_dh:
            u_dh = UserModel(
                username=dh_username,
                email="hosp_user1@relycare.local",
                phone="+919800000222",
                password_hash=hash_password(dh_password),
                role="HOSPITAL_STAFF",
                facility_id=dh_code,
                is_active=True,
            )
            db.add(u_dh)

        db.commit()
        print("Development facilities and users seeded successfully.")
    except Exception as e:
        db.rollback()
        print(f"Error seeding development data: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    seed_development_data()
