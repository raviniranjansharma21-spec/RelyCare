import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:relycare/services/local_storage/app_database.dart';
import 'package:relycare/services/local_storage/local_storage_service.dart';

void main() {
  late AppDatabase db;
  late LocalStorageService localStorage;

  setUp(() {
    // Instantiate in-memory SQLite database for test isolation
    db = AppDatabase(NativeDatabase.memory());
    localStorage = LocalStorageServiceImpl(db);
  });

  tearDown(() async {
    await localStorage.close();
  });

  group('Patient Database Operations', () {
    test('Can insert and retrieve a patient', () async {
      final patient = await localStorage.createPatient(
        name: 'Asha Devi',
        age: 34,
        gender: 'Female',
        phone: '+91 9876543210',
        location: 'Rampur Village',
      );

      expect(patient.id, isPositive);
      expect(patient.name, equals('Asha Devi'));
      expect(patient.age, equals(34));
      expect(patient.gender, equals('Female'));

      final retrieved = await localStorage.getPatientById(patient.id);
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Asha Devi'));
      expect(retrieved.location, equals('Rampur Village'));
    });

    test('Can retrieve all patients ordered by newest', () async {
      await localStorage.createPatient(name: 'Patient One', age: 20, gender: 'Male');
      await localStorage.createPatient(name: 'Patient Two', age: 30, gender: 'Female');

      final allPatients = await localStorage.getAllPatients();
      expect(allPatients.length, equals(2));
    });
  });

  group('Referral Database Operations & Transaction (Step 8)', () {
    test('createReferralTransaction creates patient, referral, event, and sync queue item atomically', () async {
      final referral = await localStorage.createReferralTransaction(
        patientName: 'Ramesh Kumar',
        patientAge: 45,
        patientGender: 'Male',
        patientLocation: 'Sundarpur',
        patientPhone: '+91 9123456789',
        sourceFacility: 'PHC Rampur',
        destinationFacility: 'District Hospital East',
        reason: 'Severe chest pain, suspected ACS',
        clinicalNotes: 'ECG abnormal, BP 150/95',
        customReferralId: 'RC-TEST-001',
      );

      expect(referral.referralId, equals('RC-TEST-001'));
      expect(referral.status, equals('CREATED'));
      expect(referral.syncStatus, equals('PENDING'));
      expect(referral.reason, equals('Severe chest pain, suspected ACS'));

      // 1. Verify Patient was created
      final patient = await localStorage.getPatientById(referral.patientId);
      expect(patient, isNotNull);
      expect(patient!.name, equals('Ramesh Kumar'));

      // 2. Verify Referral can be retrieved by referralId token
      final retrievedReferral = await localStorage.getReferral('RC-TEST-001');
      expect(retrievedReferral, isNotNull);
      expect(retrievedReferral!.sourceFacility, equals('PHC Rampur'));

      // 3. Verify Referral Event was recorded
      final events = await localStorage.getReferralEvents('RC-TEST-001');
      expect(events.length, equals(1));
      expect(events.first.eventType, equals('CREATED'));
      expect(events.first.referralId, equals('RC-TEST-001'));

      // 4. Verify Sync Queue item was created
      final pendingQueue = await localStorage.getPendingSyncItems();
      expect(pendingQueue.length, equals(1));
      expect(pendingQueue.first.entityType, equals('referral'));
      expect(pendingQueue.first.entityId, equals('RC-TEST-001'));
      expect(pendingQueue.first.status, equals('PENDING'));
    });

    test('Can update referral status and sync status', () async {
      await localStorage.createReferralTransaction(
        patientName: 'Sunita Sharma',
        patientAge: 28,
        patientGender: 'Female',
        sourceFacility: 'PHC Rampur',
        destinationFacility: 'District Hospital',
        reason: 'High risk pregnancy',
        customReferralId: 'RC-TEST-002',
      );

      // Update status
      await localStorage.updateReferralStatus('RC-TEST-002', 'RECEIVED');
      final updated = await localStorage.getReferral('RC-TEST-002');
      expect(updated!.status, equals('RECEIVED'));

      // Update sync status
      await localStorage.updateReferralSyncStatus('RC-TEST-002', 'SYNCED');
      final synced = await localStorage.getReferral('RC-TEST-002');
      expect(synced!.syncStatus, equals('SYNCED'));
    });

    test('Sync queue state transitions (PENDING -> SYNCING -> SUCCESS / FAILED)', () async {
      final queueItem = await localStorage.queueForSync(
        entityType: 'referral',
        entityId: 'RC-SYNC-01',
        operation: 'UPDATE',
        payload: '{"status":"RECEIVED"}',
      );

      expect(queueItem.status, equals('PENDING'));

      // Mark syncing
      await localStorage.markSyncing(queueItem.id);
      var items = await localStorage.getPendingSyncItems();
      expect(items.isEmpty, isTrue); // No longer PENDING

      // Mark failed with retry reset
      await localStorage.markSyncFailed(queueItem.id, resetToPending: true);
      items = await localStorage.getPendingSyncItems();
      expect(items.length, equals(1));
      expect(items.first.retryCount, equals(1));

      // Mark success
      await localStorage.markSyncSuccess(queueItem.id);
      items = await localStorage.getPendingSyncItems();
      expect(items.isEmpty, isTrue);
    });
  });
}
