/// Custom Exception Hierarchy for RelayCare.
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() => '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Thrown when local SQLite/Drift storage operations fail.
class StorageException extends AppException {
  const StorageException(super.message, [super.code]);
}

/// Thrown when network/FastAPI backend calls fail.
class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(String message, {String? code, this.statusCode})
      : super(message, code);
}

/// Thrown when offline synchronization operations encounter errors.
class SyncException extends AppException {
  const SyncException(super.message, [super.code]);
}

/// Thrown when SMS fallback transmission or payload generation fails.
class SmsException extends AppException {
  const SmsException(super.message, [super.code]);
}

/// Thrown when identity matching service fails or encounters malformed inputs.
class MatchingException extends AppException {
  const MatchingException(super.message, [super.code]);
}

// TODO: Add any specific AuthException or ValidationException as needed.
