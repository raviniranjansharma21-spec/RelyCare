import pytest
from sqlalchemy import create_engine, text, inspect
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool
from alembic.config import Config
from alembic import command
import os

def test_migration_002_downgrade_is_non_destructive():
    """Verify that downgrade of 002 does NOT drop referrals table or delete data."""
    engine = create_engine(
        "sqlite:///:memory:",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )

    with engine.connect() as conn:
        conn.execute(text("""
            CREATE TABLE referrals (
                id INTEGER PRIMARY KEY,
                referral_id VARCHAR(64) UNIQUE,
                patient_name VARCHAR(255),
                age INTEGER,
                gender VARCHAR(32),
                source_facility VARCHAR(128),
                destination_facility VARCHAR(128),
                urgency VARCHAR(32),
                reason TEXT,
                status VARCHAR(32),
                created_at DATETIME,
                updated_at DATETIME
            );
        """))
        conn.execute(text("""
            INSERT INTO referrals (id, referral_id, patient_name, age, gender, source_facility, destination_facility, urgency, reason, status)
            VALUES (1, 'RC-TEST-001', 'Test Patient', 30, 'Male', 'PHC-TEST', 'DH-TEST', 'ROUTINE', 'Reason', 'CREATED');
        """))
        conn.commit()

        inspector = inspect(conn)
        assert 'referrals' in inspector.get_table_names()

        import importlib.util
        file_path = os.path.join(os.path.dirname(__file__), "..", "alembic", "versions", "002_create_referrals_table.py")
        spec = importlib.util.spec_from_file_location("m002", file_path)
        m002 = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(m002)

        m002.downgrade()

        # Verify referrals table and data still exist intact
        inspector_after = inspect(conn)
        assert 'referrals' in inspector_after.get_table_names()

        result = conn.execute(text("SELECT COUNT(*) FROM referrals;")).scalar()
        assert result == 1
