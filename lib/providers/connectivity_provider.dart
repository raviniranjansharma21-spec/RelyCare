// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity/connectivity_service.dart';
import '../core/utils/logger.dart';

/// State management for online/offline connectivity status in RelyCare.
///
/// Responsibilities:
/// - Determines and exposes the current network connectivity status ([status], [isOnline], [isOffline]).
/// - Subscribes to [ConnectivityService] state transitions.
/// - Filters duplicate redundant notifications.
/// - Operates safely offline even if platform channel initialization encounters errors.
/// - Cleanly cancels stream subscriptions upon disposal.
class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService connectivityService;
  StreamSubscription<ConnectivityStatus>? _subscription;

  ConnectivityStatus _status = ConnectivityStatus.online;
  bool _isInitialized = false;
  bool _isDisposed = false;

  ConnectivityProvider({required this.connectivityService}) {
    _init();
  }

  /// Current application-level connectivity status.
  ConnectivityStatus get status => _status;

  /// Returns `true` if the device has an active network connection.
  bool get isOnline => _status == ConnectivityStatus.online;

  /// Returns `true` if no active network interface was detected.
  bool get isOffline => _status == ConnectivityStatus.offline;

  /// Whether the initial connectivity check has completed.
  bool get isInitialized => _isInitialized;

  /// Initializes the provider by reading the current network status and subscribing to change events.
  Future<void> _init() async {
    try {
      final initialStatus = await connectivityService.checkConnectivityStatus();
      if (!_isDisposed) {
        _status = initialStatus;
        _isInitialized = true;
        notifyListeners();
      }
    } catch (e) {
      AppLogger.warning(
        'Failed to initialize connectivity status, defaulting to offline: $e',
        'ConnectivityProvider',
      );
      if (!_isDisposed) {
        _status = ConnectivityStatus.offline;
        _isInitialized = true;
        notifyListeners();
      }
    }

    if (!_isDisposed) {
      _subscription = connectivityService.onStatusChanged.listen(
        (newStatus) {
          if (_isDisposed) return;
          _handleStatusChange(newStatus);
        },
        onError: (Object error) {
          AppLogger.warning(
            'Error received from connectivity status stream: $error',
            'ConnectivityProvider',
          );
        },
      );
    }
  }

  /// Updates status and notifies listeners only if the state has actually changed.
  void _handleStatusChange(ConnectivityStatus newStatus) {
    if (_status == newStatus) {
      // Ignore duplicate events to prevent redundant UI rebuilds
      return;
    }

    final previousStatus = _status;
    _status = newStatus;
    AppLogger.info(
      'Connectivity transition: ${previousStatus.displayName} -> ${newStatus.displayName}',
      'ConnectivityProvider',
    );
    notifyListeners();
  }

  /// Manually checks and updates the connectivity status.
  Future<void> refresh() async {
    try {
      final latestStatus = await connectivityService.checkConnectivityStatus();
      if (!_isDisposed) {
        _handleStatusChange(latestStatus);
      }
    } catch (e) {
      AppLogger.warning(
        'Manual connectivity check failed: $e',
        'ConnectivityProvider',
      );
    }
  }

  /// Helper to toggle simulated connectivity during tests or hackathon demos.
  void toggleSimulation() {
    final nextStatus = isOnline ? ConnectivityStatus.offline : ConnectivityStatus.online;
    final service = connectivityService;
    if (service is ConnectivityServiceImpl) {
      service.simulateConnectivityChange(nextStatus);
    } else {
      _handleStatusChange(nextStatus);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}
