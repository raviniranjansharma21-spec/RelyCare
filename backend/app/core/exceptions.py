"""Custom domain exceptions for RelyCare Backend."""


class RelyCareException(Exception):
    """Base exception for RelyCare domain errors."""

    def __init__(self, message: str):
        self.message = message
        super().__init__(self.message)


class ReferralAlreadyExistsException(RelyCareException):
    """Raised when attempting to create a referral with an ID that already exists."""

    def __init__(self, referral_id: str):
        super().__init__(f"Referral with ID '{referral_id}' already exists.")
        self.referral_id = referral_id


class ReferralNotFoundException(RelyCareException):
    """Raised when a requested referral cannot be found."""

    def __init__(self, referral_id: str):
        super().__init__(f"Referral '{referral_id}' not found.")
        self.referral_id = referral_id


class InvalidStatusTransitionException(RelyCareException):
    """Raised when an invalid status update is attempted."""

    def __init__(self, current_status: str, requested_status: str):
        super().__init__(
            f"Cannot transition referral status from '{current_status}' to '{requested_status}'."
        )
        self.current_status = current_status
        self.requested_status = requested_status
