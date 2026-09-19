import 'package:flutter/foundation.dart';

/// Lightweight, safe logging utility.
/// Prevents sensitive information leaks in production release builds.
class AppLogger {
  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag] ' : '';
      debugPrint('[INFO] $tagStr$message');
    }
  }

  static void warning(String message, [String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag] ' : '';
      debugPrint('[WARN] $tagStr$message');
    }
  }

  static void error(String message, [Object? error, StackTrace? stackTrace, String? tag]) {
    if (kDebugMode) {
      final tagStr = tag != null ? '[$tag] ' : '';
      debugPrint('[ERROR] $tagStr$message');
      if (error != null) debugPrint('Error detail: $error');
      if (stackTrace != null) debugPrint('StackTrace:\n$stackTrace');
    }
  }

  // TODO: Connect to local log file or crash reporting service in future phases.
}
