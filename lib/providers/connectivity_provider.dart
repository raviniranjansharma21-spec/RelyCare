import 'dart:async';
import 'package:flutter/material.dart';
import '../services/connectivity/connectivity_service.dart';

/// State management for online/offline connectivity status.
class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivityService;
  StreamSubscription<bool>? _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  ConnectivityProvider({required this._connectivityService}) {
    _init();
  }

  void _init() async {
    _isOnline = await _connectivityService.checkConnectivity();
    notifyListeners();

    _subscription = _connectivityService.onConnectivityChanged.listen((online) {
      _isOnline = online;
      notifyListeners();
    });
  }

  /// Helper to manually toggle connectivity simulation during hackathon demo
  void toggleSimulation() {
    _isOnline = !_isOnline;
    if (_connectivityService is ConnectivityServiceImpl) {
      (_connectivityService).simulateConnectivityChange(_isOnline);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
