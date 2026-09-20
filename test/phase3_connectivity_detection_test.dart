import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relycare/providers/connectivity_provider.dart';
import 'package:relycare/services/connectivity/connectivity_service.dart';

/// Test implementation of [ConnectivityService] with controlled stream emission and state mocking.
class FakeConnectivityService implements ConnectivityService {
  ConnectivityStatus _status;
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();
  bool throwOnCheck = false;
  bool isDisposed = false;

  FakeConnectivityService({ConnectivityStatus initialStatus = ConnectivityStatus.online})
      : _status = initialStatus;

  @override
  ConnectivityStatus get currentStatus => _status;

  @override
  Future<ConnectivityStatus> checkConnectivityStatus() async {
    if (throwOnCheck) {
      throw Exception('Simulated platform connectivity channel failure');
    }
    return _status;
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
      _statusController.stream.map((s) => s == ConnectivityStatus.online);

  void emitStatus(ConnectivityStatus newStatus) {
    _status = newStatus;
    _statusController.add(newStatus);
  }

  void emitError(Object error) {
    _statusController.addError(error);
  }

  @override
  void dispose() {
    isDisposed = true;
    _statusController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 3: Connectivity Detection Layer Tests', () {
    test('A. Initial online state: Provider correctly initializes in ONLINE state', () async {
      final fakeService = FakeConnectivityService(initialStatus: ConnectivityStatus.online);
      final provider = ConnectivityProvider(connectivityService: fakeService);

      // Allow async initialization to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.isInitialized, isTrue);
      expect(provider.status, equals(ConnectivityStatus.online));
      expect(provider.isOnline, isTrue);
      expect(provider.isOffline, isFalse);

      provider.dispose();
      fakeService.dispose();
    });

    test('B. Initial offline state: Provider correctly initializes in OFFLINE state', () async {
      final fakeService = FakeConnectivityService(initialStatus: ConnectivityStatus.offline);
      final provider = ConnectivityProvider(connectivityService: fakeService);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.isInitialized, isTrue);
      expect(provider.status, equals(ConnectivityStatus.offline));
      expect(provider.isOnline, isFalse);
      expect(provider.isOffline, isTrue);

      provider.dispose();
      fakeService.dispose();
    });

    test('C. ONLINE -> OFFLINE transition: Provider receives event and notifies listeners', () async {
      final fakeService = FakeConnectivityService(initialStatus: ConnectivityStatus.online);
      final provider = ConnectivityProvider(connectivityService: fakeService);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      // Simulate network loss
      fakeService.emitStatus(ConnectivityStatus.offline);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.status, equals(ConnectivityStatus.offline));
      expect(provider.isOnline, isFalse);
      expect(provider.isOffline, isTrue);
      expect(notificationCount, equals(1));

      provider.dispose();
      fakeService.dispose();
    });

    test('D. OFFLINE -> ONLINE transition: Provider receives event and notifies listeners', () async {
      final fakeService = FakeConnectivityService(initialStatus: ConnectivityStatus.offline);
      final provider = ConnectivityProvider(connectivityService: fakeService);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      // Simulate network restored
      fakeService.emitStatus(ConnectivityStatus.online);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.status, equals(ConnectivityStatus.online));
      expect(provider.isOnline, isTrue);
      expect(provider.isOffline, isFalse);
      expect(notificationCount, equals(1));

      provider.dispose();
      fakeService.dispose();
    });

    test('E. Duplicate states: Repeated identical states do not trigger redundant listener notifications', () async {
      final fakeService = FakeConnectivityService(initialStatus: ConnectivityStatus.online);
      final provider = ConnectivityProvider(connectivityService: fakeService);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      // Emit repeated identical ONLINE states
      fakeService.emitStatus(ConnectivityStatus.online);
      fakeService.emitStatus(ConnectivityStatus.online);
      fakeService.emitStatus(ConnectivityStatus.online);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(notificationCount, equals(0),
          reason: 'Duplicate ONLINE states must be ignored');

      // Now emit OFFLINE (should notify once)
      fakeService.emitStatus(ConnectivityStatus.offline);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(notificationCount, equals(1));

      // Emit repeated identical OFFLINE states
      fakeService.emitStatus(ConnectivityStatus.offline);
      fakeService.emitStatus(ConnectivityStatus.offline);
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(notificationCount, equals(1),
          reason: 'Duplicate OFFLINE states must be ignored');

      provider.dispose();
      fakeService.dispose();
    });

    test('F. Disposal: Disposed provider cancels subscription and ignores subsequent updates', () async {
      final fakeService = FakeConnectivityService(initialStatus: ConnectivityStatus.online);
      final provider = ConnectivityProvider(connectivityService: fakeService);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      int notificationCount = 0;
      provider.addListener(() {
        notificationCount++;
      });

      // Dispose provider
      provider.dispose();

      // Emit new status on service
      fakeService.emitStatus(ConnectivityStatus.offline);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(notificationCount, equals(0),
          reason: 'Disposed provider must not trigger listener callbacks');

      fakeService.dispose();
    });

    test('G. Error handling: Platform failure defaults safely to OFFLINE without crashing', () async {
      final fakeService = FakeConnectivityService(initialStatus: ConnectivityStatus.online);
      fakeService.throwOnCheck = true;

      final provider = ConnectivityProvider(connectivityService: fakeService);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      // Should default safely to offline rather than crashing
      expect(provider.isInitialized, isTrue);
      expect(provider.status, equals(ConnectivityStatus.offline));
      expect(provider.isOffline, isTrue);

      // Stream error should also be handled gracefully without unhandled exceptions
      fakeService.emitError(Exception('Platform stream error'));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(provider.status, equals(ConnectivityStatus.offline));

      provider.dispose();
      fakeService.dispose();
    });

    test('H. Result Mapping: ConnectivityServiceImpl.mapResultsToStatus accurately maps interface types', () {
      expect(
        ConnectivityServiceImpl.mapResultsToStatus([ConnectivityResult.wifi]),
        equals(ConnectivityStatus.online),
      );
      expect(
        ConnectivityServiceImpl.mapResultsToStatus([ConnectivityResult.mobile]),
        equals(ConnectivityStatus.online),
      );
      expect(
        ConnectivityServiceImpl.mapResultsToStatus([ConnectivityResult.ethernet]),
        equals(ConnectivityStatus.online),
      );
      expect(
        ConnectivityServiceImpl.mapResultsToStatus([ConnectivityResult.vpn]),
        equals(ConnectivityStatus.online),
      );
      expect(
        ConnectivityServiceImpl.mapResultsToStatus([ConnectivityResult.other]),
        equals(ConnectivityStatus.online),
      );
      expect(
        ConnectivityServiceImpl.mapResultsToStatus([ConnectivityResult.none]),
        equals(ConnectivityStatus.offline),
      );
      expect(
        ConnectivityServiceImpl.mapResultsToStatus([]),
        equals(ConnectivityStatus.offline),
      );
      expect(
        ConnectivityServiceImpl.mapResultsToStatus([ConnectivityResult.none, ConnectivityResult.wifi]),
        equals(ConnectivityStatus.online),
      );
    });

    test('I. Manual toggleSimulation changes state appropriately', () async {
      final fakeService = FakeConnectivityService(initialStatus: ConnectivityStatus.online);
      final provider = ConnectivityProvider(connectivityService: fakeService);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(provider.isOnline, isTrue);

      provider.toggleSimulation();
      expect(provider.isOffline, isTrue);

      provider.toggleSimulation();
      expect(provider.isOnline, isTrue);

      provider.dispose();
      fakeService.dispose();
    });
  });
}
