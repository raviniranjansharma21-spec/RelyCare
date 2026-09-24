/// Custom Exception Hierarchy for RelyCare.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, {this.code});

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Thrown when local SQLite/Drift storage operations fail.
class StorageException extends AppException {
  const StorageException(super.message, {super.code});
}

/// Thrown when network/FastAPI backend calls fail.
class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {super.code, this.statusCode});
}

/// Thrown when authentication fails or token is expired (HTTP 401 Unauthorized).
class UnauthenticatedException extends NetworkException {
  const UnauthenticatedException([super.message = 'Authentication required or session expired'])
      : super(code: 'UNAUTHENTICATED', statusCode: 401);
}

/// Thrown when user lacks permission/role authorization (HTTP 403 Forbidden).
class UnauthorizedException extends NetworkException {
  const UnauthorizedException([super.message = 'Access denied for this resource'])
      : super(code: 'UNAUTHORIZED', statusCode: 403);
}



/// Thrown when a duplicate referral token is detected by FastAPI (HTTP 409 Conflict).
class DuplicateReferralException extends NetworkException {
  final String referralId;
  const DuplicateReferralException(this.referralId, {String? message})
      : super(
          message ?? 'Duplicate referral token detected on server: $referralId',
          code: 'DUPLICATE_REFERRAL',
          statusCode: 409,
        );
}

/// Thrown when offline synchronization operations encounter errors.
class SyncException extends AppException {
  const SyncException(super.message, {super.code});
}

/// Thrown when SMS fallback transmission or payload generation fails.
class SmsException extends AppException {
  const SmsException(super.message, {super.code});
}

/// Thrown when identity matching service fails or encounters malformed inputs.
class MatchingException extends AppException {
  const MatchingException(super.message, {super.code});
}
