/// Global application constants for RelayCare.
class AppConstants {
  // App Metadata
  static const String appName = 'RelyCare';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Offline-First Healthcare Referral Continuity';

  // Timeouts & Durations (in milliseconds)
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;
  static const int syncIntervalSeconds = 60;

  // Matching Thresholds
  static const double highConfidenceThreshold = 0.85;
  static const double mediumConfidenceThreshold = 0.60;

  // TODO: Add any additional global constants (e.g. pagination limits, retry counts).
}
