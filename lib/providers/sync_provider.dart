// ignore_for_file: prefer_initializing_formals
import 'package:flutter/material.dart';
import '../repositories/sync_repository.dart';
import '../providers/connectivity_provider.dart';
import '../core/utils/logger.dart';

/// State management for synchronization progress, queue metrics, and retry triggers.
class SyncProvider extends ChangeNotifier {
  final SyncRepository syncRepository;
  final ConnectivityProvider? connectivityProvider;
  VoidCallback? _connectivityListener;

  int _pendingCount = 0;
  int _failedCount = 0;
  bool _isSyncing = false;
  String? _lastSyncTime;
  String? _syncError;
  bool _isDisposed = false;
  bool _wasOffline = true;

  SyncProvider({
    required this.syncRepository,
    this.connectivityProvider,
  }) {
    _init();
  }


  int get pendingCount => _pendingCount;
  int get failedCount => _failedCount;
  bool get isSyncing => _isSyncing;
  String? get lastSyncTime => _lastSyncTime;
  String? get syncError => _syncError;
  String? get lastError => _syncError;

  void _init() {
    refreshCounts();

    if (connectivityProvider != null) {
      _wasOffline = !connectivityProvider!.isOnline;

      // If already online at startup, trigger sync
      if (connectivityProvider!.isOnline) {
        syncPending();
      }

      // Listen for connectivity transitions
      _connectivityListener = () {
        if (_isDisposed) return;
        final isCurrentlyOnline = connectivityProvider!.isOnline;

        // Trigger sync when transitioning from offline -> online
        if (isCurrentlyOnline && _wasOffline) {
          AppLogger.info(
            'Connectivity transitioned to ONLINE. Automatically triggering sync/retry.',
            'SyncProvider',
          );
          syncPending();
        }
        _wasOffline = !isCurrentlyOnline;
      };

      connectivityProvider!.addListener(_connectivityListener!);
    }
  }

  /// Refreshes the count of pending and failed items in the offline queue.
  Future<void> refreshCounts() async {
    try {
      _pendingCount = await syncRepository.getPendingQueueCount();
      _failedCount = await syncRepository.getFailedQueueCount();
      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e) {
      AppLogger.warning('Failed to refresh sync queue counts: $e', 'SyncProvider');
    }
  }

  /// Refreshes the count of pending items (backward compatibility).
  Future<void> refreshPendingCount() => refreshCounts();

  /// Triggers a synchronization pass for eligible pending/failed queue items.
  Future<int> syncPending() async {
    if (_isSyncing || _isDisposed) {
      return 0;
    }

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final syncedCount = await syncRepository.triggerSync();
      _lastSyncTime = DateTime.now().toIso8601String();
      _syncError = null;
      await refreshCounts();
      return syncedCount;
    } catch (e) {
      _syncError = 'Sync failed: $e';
      AppLogger.warning('Sync pass failed with error: $e', 'SyncProvider');
      await refreshCounts();
      return 0;
    } finally {
      if (!_isDisposed) {
        _isSyncing = false;
        notifyListeners();
      }
    }
  }

  /// Triggers a retry pass specifically for retryable failed queue items.
  Future<int> retryFailed() async {
    if (_isSyncing || _isDisposed) {
      return 0;
    }

    _isSyncing = true;
    _syncError = null;
    notifyListeners();

    try {
      final retriedCount = await syncRepository.retryFailed();
      _lastSyncTime = DateTime.now().toIso8601String();
      _syncError = null;
      await refreshCounts();
      return retriedCount;
    } catch (e) {
      _syncError = 'Retry pass failed: $e';
      AppLogger.warning('Retry pass failed with error: $e', 'SyncProvider');
      await refreshCounts();
      return 0;
    } finally {
      if (!_isDisposed) {
        _isSyncing = false;
        notifyListeners();
      }
    }
  }

  /// Alias for syncPending()
  Future<int> triggerSync() => syncPending();

  @override
  void dispose() {
    _isDisposed = true;
    if (_connectivityListener != null && connectivityProvider != null) {
      connectivityProvider!.removeListener(_connectivityListener!);
      _connectivityListener = null;
    }
    super.dispose();
  }
}
