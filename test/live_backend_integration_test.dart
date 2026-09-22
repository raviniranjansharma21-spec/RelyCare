import 'dart:io';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:relycare/core/errors/app_exceptions.dart';
import 'package:relycare/models/patient.dart';
import 'package:relycare/models/referral.dart';
import 'package:relycare/models/referral_status.dart';
import 'package:relycare/services/api/api_service.dart';
import 'package:relycare/services/connectivity/connectivity_service.dart';
import 'package:relycare/services/local_storage/app_database.dart';
import 'package:relycare/services/local_storage/local_storage_service.dart';
import 'package:relycare/services/sync/sync_service.dart';

class _AlwaysOnlineConnectivityService implements ConnectivityService {
  @override
  ConnectivityStatus get currentStatus => ConnectivityStatus.online;

  @override
  Future<ConnectivityStatus> checkConnectivityStatus() async => ConnectivityStatus.online;

  @override
  Future<bool> checkConnectivity() async => true;

  @override
  Stream<ConnectivityStatus> get onStatusChanged => const Stream.empty();

  @override
  Stream<bool> get onConnectivityChanged => const Stream.empty();

  @override
  void dispose() {}
}

void main() {
  test(
    'LIVE Integration: Flutter ApiServiceImpl -> FastAPI -> PostgreSQL verification',
    () async {
      const baseUrl = 'http://127.0.0.1:8000/api/v1';
      final apiService = ApiServiceImpl(baseUrl: baseUrl);


    final uniqueToken = 'RC-LIVE-${DateTime.now().millisecondsSinceEpoch % 1000000}';

    final syntheticPatient = Patient(
      id: uniqueToken,
      fullName: 'Synthetic Test Patient',
      age: 45,
      gender: 'Female',
      villageOrLocation: 'Test Village, Block A',
      contactNumber: '+91 9999988888',
      createdAt: DateTime.now(),
    );

    final syntheticReferral = Referral(
      id: uniqueToken,
      referralToken: uniqueToken,
      patientId: uniqueToken,
      patient: syntheticPatient,
      sourceFacilityId: 'PHC-TEST',
      destinationFacilityId: 'DH-TEST',
      referralReason: 'Integration test referral validation',
      urgency: ReferralUrgency.urgent,
      clinicalNotesSummary: 'Automated integration check',
      status: ReferralStatus.created,
      syncState: SyncState.pendingSync,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 1. POST /api/v1/referrals -> 201 Created
    final created = await apiService.createReferral(syntheticReferral);
    expect(created.referralToken, equals(uniqueToken));
    expect(created.patient?.fullName, equals('Synthetic Test Patient'));
    expect(created.status, equals(ReferralStatus.created));
    expect(created.syncState, equals(SyncState.synced));

    // 2. GET /api/v1/referrals/{referral_id} -> 200 OK
    final fetched = await apiService.getReferral(uniqueToken);
    expect(fetched.referralToken, equals(uniqueToken));
    expect(fetched.sourceFacilityId, equals('PHC-TEST'));
    expect(fetched.urgency, equals(ReferralUrgency.urgent));

    // 3. POST duplicate -> 409 Conflict -> DuplicateReferralException
    expect(
      () => apiService.createReferral(syntheticReferral),
      throwsA(
        isA<DuplicateReferralException>()
            .having((e) => e.referralId, 'referralId', equals(uniqueToken))
            .having((e) => e.statusCode, 'statusCode', equals(409)),
      ),
    );

    // 4. PATCH /api/v1/referrals/{referral_id}/status -> 200 OK
    await apiService.updateReferralStatus(uniqueToken, 'RECEIVED');
    final updated = await apiService.getReferral(uniqueToken);
    expect(updated.status, equals(ReferralStatus.received));
  },
  skip: Platform.environment['LIVE_BACKEND'] != 'true',
  );

  test(
    'LIVE Integration: End-to-End Pull-Sync (FastAPI/PostgreSQL -> Flutter SyncService -> Drift SQLite)',
    () async {
      const baseUrl = 'http://127.0.0.1:8000/api/v1';
      final apiService = ApiServiceImpl(baseUrl: baseUrl);
      final db = AppDatabase(NativeDatabase.memory());
      final localStorage = LocalStorageServiceImpl(db);
      final syncService = SyncService(
        localStorage: localStorage,
        apiService: apiService,
        connectivityService: _AlwaysOnlineConnectivityService(),
      );



    final uniqueToken = 'RC-PULL-LIVE-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final syntheticPatient = Patient(
      id: uniqueToken,
      fullName: 'Live Pull Patient',
      age: 38,
      gender: 'Male',
      villageOrLocation: 'North Ridge',
      contactNumber: '+91 9123456780',
      createdAt: DateTime.now(),
    );

    final syntheticReferral = Referral(
      id: uniqueToken,
      referralToken: uniqueToken,
      patientId: uniqueToken,
      patient: syntheticPatient,
      sourceFacilityId: 'PHC-RIDGE',
      destinationFacilityId: 'DH-CENTRAL',
      referralReason: 'High grade fever with convulsions',
      urgency: ReferralUrgency.emergency,
      clinicalNotesSummary: 'Requires urgent pediatric consultation',
      status: ReferralStatus.created,
      syncState: SyncState.pendingSync,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 1. Create synthetic referral directly on live backend
    final serverReferral = await apiService.createReferral(syntheticReferral);
    expect(serverReferral.referralToken, equals(uniqueToken));

    // 2. Execute Pull-Sync from live FastAPI / PostgreSQL into Flutter SQLite
    final pulled = await syncService.pullReferralsFromServer();
    expect(pulled.any((r) => r.referralToken == uniqueToken), isTrue);

    // 3. Confirm the referral is in local Drift SQLite
    final localReferrals = await localStorage.getAllDomainReferrals();
    final localMatch = localReferrals.firstWhere((r) => r.referralToken == uniqueToken);
    expect(localMatch.urgency, equals(ReferralUrgency.emergency));
    expect(localMatch.sourceFacilityId, equals('PHC-RIDGE'));
    expect(localMatch.destinationFacilityId, equals('DH-CENTRAL'));
    expect(localMatch.patientId, isNotEmpty);
    expect(localMatch.patientId, isNot(equals(uniqueToken))); // Valid local integer ID, NOT token
    expect(int.tryParse(localMatch.patientId), isNotNull);

    // 4. Confirm the local Patient row was created and resolved
    expect(localMatch.patient, isNotNull);
    expect(localMatch.patient!.fullName, equals('Live Pull Patient'));
    expect(localMatch.patient!.contactNumber, equals('+91 9123456780'));

    final patientCountBefore = (await db.select(db.patients).get()).length;
    final referralCountBefore = (await db.select(db.referrals).get()).length;

    // 5. Pull again
    final secondPull = await syncService.pullReferralsFromServer();
    expect(secondPull.any((r) => r.referralToken == uniqueToken), isTrue);

    // 6. Confirm no duplicate referral or duplicate patient in local SQLite
    final patientCountAfter = (await db.select(db.patients).get()).length;
    final referralCountAfter = (await db.select(db.referrals).get()).length;

    expect(referralCountAfter, equals(referralCountBefore));
    expect(patientCountAfter, equals(patientCountBefore));

    await db.close();
  },
  skip: Platform.environment['LIVE_BACKEND'] != 'true',
  );
}

