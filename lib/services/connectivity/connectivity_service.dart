import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/utils/logger.dart';

/// Simplified application-level connectivity status.
///
/// Distinct from backend API reachability:
/// - [online] indicates a physical/logical network connection (Wi-Fi, Mobile, Ethernet, VPN) is present on the device.
/// - [offline] indicates no active network interface was detected.
///
/// Actual HTTP/API server reachability is verified separately during synchronization passes (Phase 4).
enum ConnectivityStatus {
  online,
  offline,
}

extension ConnectivityStatusExtension on ConnectivityStatus {
  bool get isOnline => this == ConnectivityStatus.online;
  bool get isOffline => this == ConnectivityStatus.offline;

  String get displayName {
    switch (this) {
      case ConnectivityStatus.online:
        return 'Online';
      case ConnectivityStatus.offline:
        return 'Offline';
    }
  }
}

/// Abstract contract for network connectivity detection.
abstract class ConnectivityService {
  /// Checks the current network connectivity status.
  Future<ConnectivityStatus> checkConnectivityStatus();

  /// Backward-compatible helper returning `true` if network is online.
  Future<bool> checkConnectivity();

  /// Stream of simplified [ConnectivityStatus] changes.
  Stream<ConnectivityStatus> get onStatusChanged;

  /// Stream of boolean changes (`true` = online, `false` = offline).
  Stream<bool> get onConnectivityChanged;

  /// Current cached connectivity status.
  ConnectivityStatus get currentStatus;

  /// Disposes internal streams and subscriptions.
  void dispose();
}

/// Concrete implementation of [ConnectivityService] using `connectivity_plus`.
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _platformSubscription;

  ConnectivityStatus _currentStatus = ConnectivityStatus.online;
  bool _isDisposed = false;

  ConnectivityServiceImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity() {
    _initPlatformListener();
  }

  void _initPlatformListener() {
    try {
      _platformSubscription = _connectivity.onConnectivityChanged.listen(
        (results) {
          if (_isDisposed) return;
          final status = mapResultsToStatus(results);
          if (status != _currentStatus) {
            _currentStatus = status;
            AppLogger.info(
              'Network state changed to: ${status.displayName}',
              'ConnectivityService',
            );
            _statusController.add(status);
          }
        },
        onError: (Object error) {
          AppLogger.warning(
            'Error listening to platform connectivity stream: $error',
            'ConnectivityService',
          );
        },
      );
    } catch (e) {
      AppLogger.warning(
        'Failed to initialize platform connectivity listener: $e',
        'ConnectivityService',
      );
    }
  }

  @override
  ConnectivityStatus get currentStatus => _currentStatus;

  @override
  Future<ConnectivityStatus> checkConnectivityStatus() async {
    if (_isDisposed) return _currentStatus;
    try {
      final results = await _connectivity.checkConnectivity();
      _currentStatus = mapResultsToStatus(results);
      return _currentStatus;
    } catch (e) {
      AppLogger.warning(
        'Platform checkConnectivity failed, defaulting to offline: $e',
        'ConnectivityService',
      );
      _currentStatus = ConnectivityStatus.offline;
      return _currentStatus;
    }
  }

  @override
  Future<bool> checkConnectivity() async {
    final status = await checkConnectivityStatus();
    return status == ConnectivityStatus.online;
  }

  @override
  Stream<ConnectivityStatus> get onStatusChanged => _statusController.stream;

  @override
  Stream<bool> get onConnectivityChanged =>
      _statusController.stream.map((status) => status == ConnectivityStatus.online);

  /// Helper used in tests and manual UI demos to simulate connectivity transitions.
  void simulateConnectivityChange(dynamic statusOrBool) {
    if (_isDisposed) return;
    final ConnectivityStatus targetStatus;
    if (statusOrBool is ConnectivityStatus) {
      targetStatus = statusOrBool;
    } else if (statusOrBool is bool) {
      targetStatus = statusOrBool ? ConnectivityStatus.online : ConnectivityStatus.offline;
    } else {
      return;
    }

    if (targetStatus != _currentStatus) {
      _currentStatus = targetStatus;
      AppLogger.info(
        'Simulated connectivity change: ${targetStatus.displayName}',
        'ConnectivityService',
      );
      _statusController.add(targetStatus);
    }
  }

  /// Maps `connectivity_plus` results to high-level [ConnectivityStatus].
  static ConnectivityStatus mapResultsToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty) {
      return ConnectivityStatus.offline;
    }

    final hasActiveInterface = results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn ||
        result == ConnectivityResult.other);

    return hasActiveInterface ? ConnectivityStatus.online : ConnectivityStatus.offline;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _platformSubscription?.cancel();
    _platformSubscription = null;
    _statusController.close();
  }
}
