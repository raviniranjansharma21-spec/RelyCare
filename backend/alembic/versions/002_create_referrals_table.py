"""Create referrals table migration.

Revision ID: 002_create_referrals_table
Revises: 001_initial_auth_schema
Create Date: 2026-09-23 11:30:00.000000

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

# revision identifiers, used by Alembic.
revision: str = '002_create_referrals_table'
down_revision: Union[str, None] = '001_initial_auth_schema'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    conn = op.get_bind()
    inspector = sa.inspect(conn)
    tables = inspector.get_table_names()

    if 'referrals' not in tables:
        op.create_table(
            'referrals',
            sa.Column('id', sa.Integer(), autoincrement=True, nullable=False),
            sa.Column('referral_id', sa.String(length=64), nullable=False),
            sa.Column('patient_name', sa.String(length=255), nullable=False),
            sa.Column('age', sa.Integer(), nullable=False),
            sa.Column('gender', sa.String(length=32), nullable=False),
            sa.Column('village_or_location', sa.String(length=255), nullable=True),
            sa.Column('contact_number', sa.String(length=64), nullable=True),
            sa.Column('source_facility', sa.String(length=128), nullable=False),
            sa.Column('destination_facility', sa.String(length=128), nullable=False),
            sa.Column('urgency', sa.String(length=32), server_default='ROUTINE', nullable=False),
            sa.Column('reason', sa.Text(), nullable=False),
            sa.Column('clinical_notes_summary', sa.Text(), nullable=True),
            sa.Column('status', sa.String(length=32), server_default='CREATED', nullable=False),
            sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
            sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
            sa.PrimaryKeyConstraint('id'),
            sa.UniqueConstraint('referral_id')
        )
        op.create_index(op.f('ix_referrals_id'), 'referrals', ['id'], unique=False)
        op.create_index(op.f('ix_referrals_referral_id'), 'referrals', ['referral_id'], unique=True)


def downgrade() -> None:
    # No-op downgrade to ensure pre-existing referrals tables and records are never deleted.
    pass

