import pytest
from datetime import timedelta
import jwt
from app.core.security import (
    hash_password,
    verify_password,
    create_access_token,
    decode_access_token,
)


def test_password_hashing():
    raw_pass = "TestPassword123!"
    hashed = hash_password(raw_pass)

    assert hashed != raw_pass
    assert verify_password(raw_pass, hashed) is True
    assert verify_password("WrongPassword", hashed) is False


def test_jwt_token_flow():
    user_id = "user123"
    claims = {"role": "PHC_STAFF", "facility_id": "PHC_TEST"}

    token = create_access_token(subject=user_id, extra_claims=claims)
    decoded = decode_access_token(token)

    assert decoded["sub"] == user_id
    assert decoded["role"] == "PHC_STAFF"
    assert decoded["facility_id"] == "PHC_TEST"
    assert "exp" in decoded


def test_jwt_expired_token():
    token = create_access_token(
        subject="expired_user",
        expires_delta=timedelta(seconds=-10),  # expired 10s ago
    )
    with pytest.raises(jwt.ExpiredSignatureError):
        decode_access_token(token)


def test_jwt_malformed_token():
    with pytest.raises(jwt.DecodeError):
        decode_access_token("invalid.token.string")
