import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

import 'package:relycare/models/patient.dart';
import 'package:relycare/models/referral.dart';
import 'package:relycare/models/referral_status.dart';
import 'package:relycare/services/api/api_service.dart';
import 'package:relycare/services/local_storage/app_database.dart';
import 'package:relycare/services/local_storage/local_storage_service.dart';

void main() {
  late AppDatabase db;
  late LocalStorageService localStorage;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    localStorage = LocalStorageServiceImpl(db);
  });

  tearDown(() async {
    await localStorage.close();
  });

  group('Phase 2 Pre-Pull Data Model & Identity Resolution Tests', () {
    // 1. Server referral with referral_id "RC-TEST-001" must NOT create Patient ID "RC-TEST-001".
    test('1. ApiServiceImpl._referralFromJson does NOT assign referral_id as patientId/patient.id', () async {
      final mockJson = {
        'id': 99,
        'referral_id': 'RC-TEST-001',
        'patient_name': 'Meera Patel',
        'age': 29,
        'gender': 'Female',
        'village_or_location': 'Village Rampur',
        'contact_number': '+91 9876543210',
        'source_facility': 'PHC-01',
        'destination_facility': 'DH-01',
        'urgency': 'URGENT',
        'reason': 'High fever and convulsions',
        'clinical_notes_summary': 'IV fluids administered',
        'status': 'CREATED',
        'created_at': '2026-09-22T10:00:00Z',
        'updated_at': '2026-09-22T10:00:00Z',
      };

      final client = MockClient((request) async {
        return http.Response(jsonEncode(mockJson), 200, headers: {'content-type': 'application/json'});
      });

      final apiService = ApiServiceImpl(baseUrl: 'http://localhost:8000/api/v1', client: client);
      final referral = await apiService.getReferral('RC-TEST-001');

      // Globally stable identifier
      expect(referral.referralToken, equals('RC-TEST-001'));
      expect(referral.id, equals('RC-TEST-001')); // Not server integer row PK "99"

      // Patient identity is blank until resolved locally
      expect(referral.patientId, isNot(equals('RC-TEST-001')));
      expect(referral.patient?.id, isNot(equals('RC-TEST-001')));
      expect(referral.patient?.fullName, equals('Meera Patel'));
    });

    // 2. Server referral must resolve to an existing local patient when exact normalized phone matches.
    test('2. Server referral resolves to existing local patient when normalized phone matches', () async {
      // Create local patient first
      final localPatient = await localStorage.createPatient(
        name: 'Meera Patel',
        age: 29,
        gender: 'Female',
        phone: '+91 9876543210',
        location: 'Village Rampur',
      );

      final serverReferral = Referral(
        id: 'RC-TEST-002',
        referralToken: 'RC-TEST-002',
        patientId: '',
        patient: Patient(
          id: '',
          fullName: 'Meera Patel',
          age: 29,
          gender: 'Female',
          contactNumber: '9876543210', // slightly different formatting (missing +91)
          villageOrLocation: 'Village Rampur',
          createdAt: DateTime.now(),
        ),
        sourceFacilityId: 'PHC-01',
        destinationFacilityId: 'DH-01',
        referralReason: 'Routine checkup',
        urgency: ReferralUrgency.routine,
        status: ReferralStatus.created,
        syncState: SyncState.synced,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await localStorage.upsertReferralFromSync(serverReferral);

      // Must link to existing local patient ID
      expect(saved.patientId, equals(localPatient.id.toString()));
      expect(saved.patient?.fullName, equals('Meera Patel'));

      // Total patient count in SQLite must still be 1 (no duplicate patient created)
      final allPatients = await localStorage.getAllPatients();
      expect(allPatients.length, equals(1));
    });

    // 3. Server referral with no matching patient creates exactly one local patient.
    test('3. Server referral with no matching patient creates exactly one local patient', () async {
      final serverReferral = Referral(
        id: 'RC-TEST-003',
        referralToken: 'RC-TEST-003',
        patientId: '',
        patient: Patient(
          id: '',
          fullName: 'Vikram Singh',
          age: 50,
          gender: 'Male',
          contactNumber: '+91 9111222333',
          villageOrLocation: 'Kalyanpur',
          createdAt: DateTime.now(),
        ),
        sourceFacilityId: 'PHC-02',
        destinationFacilityId: 'DH-02',
        referralReason: 'Fracture right arm',
        urgency: ReferralUrgency.urgent,
        status: ReferralStatus.created,
        syncState: SyncState.synced,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await localStorage.upsertReferralFromSync(serverReferral);

      final allPatients = await localStorage.getAllPatients();
      expect(allPatients.length, equals(1));
      expect(allPatients.first.name, equals('Vikram Singh'));
      expect(saved.patientId, equals(allPatients.first.id.toString()));
    });

    // 4. Pulling the same referral twice does not create duplicate referrals.
    test('4. Pulling the same referral twice does not create duplicate referrals', () async {
      final serverReferral = Referral(
        id: 'RC-TEST-004',
        referralToken: 'RC-TEST-004',
        patientId: '',
        patient: Patient(
          id: '',
          fullName: 'Anjali Gupta',
          age: 24,
          gender: 'Female',
          contactNumber: '+91 9998887776',
          villageOrLocation: 'Rampur',
          createdAt: DateTime.now(),
        ),
        sourceFacilityId: 'PHC-01',
        destinationFacilityId: 'DH-01',
        referralReason: 'Fever',
        urgency: ReferralUrgency.routine,
        status: ReferralStatus.created,
        syncState: SyncState.synced,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await localStorage.upsertReferralFromSync(serverReferral);
      // Pull same referral a second time (e.g. updated status)
      final updatedServerReferral = Referral(
        id: 'RC-TEST-004',
        referralToken: 'RC-TEST-004',
        patientId: '',
        patient: serverReferral.patient,
        sourceFacilityId: 'PHC-01',
        destinationFacilityId: 'DH-01',
        referralReason: 'Fever',
        urgency: ReferralUrgency.routine,
        status: ReferralStatus.received,
        syncState: SyncState.synced,
        createdAt: serverReferral.createdAt,
        updatedAt: DateTime.now(),
      );
      final secondSave = await localStorage.upsertReferralFromSync(updatedServerReferral);

      final allReferrals = await localStorage.getAllReferrals();
      expect(allReferrals.length, equals(1));
      expect(secondSave.status, equals(ReferralStatus.received));
    });

    // 5. Two different referrals for the same patient reuse the same local Patient.id when the identity fields match.
    test('5. Two different referrals for the same patient reuse the same local Patient.id', () async {
      final patientDemographics = Patient(
        id: '',
        fullName: 'Rajesh Verma',
        age: 38,
        gender: 'Male',
        contactNumber: '+91 9887766554',
        villageOrLocation: 'Sundarnagar',
        createdAt: DateTime.now(),
      );

      final referral1 = Referral(
        id: 'RC-REF-101',
        referralToken: 'RC-REF-101',
        patientId: '',
        patient: patientDemographics,
        sourceFacilityId: 'PHC-01',
        destinationFacilityId: 'DH-01',
        referralReason: 'Initial consult',
        urgency: ReferralUrgency.routine,
        status: ReferralStatus.completed,
        syncState: SyncState.synced,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now().subtract(const Duration(days: 9)),
      );

      final referral2 = Referral(
        id: 'RC-REF-102',
        referralToken: 'RC-REF-102',
        patientId: '',
        patient: patientDemographics,
        sourceFacilityId: 'PHC-01',
        destinationFacilityId: 'DH-01',
        referralReason: 'Follow-up consult',
        urgency: ReferralUrgency.routine,
        status: ReferralStatus.created,
        syncState: SyncState.synced,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved1 = await localStorage.upsertReferralFromSync(referral1);
      final saved2 = await localStorage.upsertReferralFromSync(referral2);

      // Must share the exact same patientId
      expect(saved1.patientId, equals(saved2.patientId));

      // Local Patients table must contain exactly 1 patient
      final allPatients = await localStorage.getAllPatients();
      expect(allPatients.length, equals(1));
      expect(allPatients.first.name, equals('Rajesh Verma'));

      // Local Referrals table must contain 2 referrals
      final allReferrals = await localStorage.getAllReferrals();
      expect(allReferrals.length, equals(2));
    });

    // 6. A server referral must NEVER silently use Patient ID 1 as a fallback.
    test('6. Server referral never silently falls back to Patient ID 1', () async {
      // Create an existing patient with ID 1
      final patient1 = await localStorage.createPatient(
        name: 'First Registered Patient',
        age: 60,
        gender: 'Female',
        phone: '+91 9000000001',
        location: 'Zone A',
      );
      expect(patient1.id, equals(1));

      // Server referral for a DIFFERENT patient
      final serverReferral = Referral(
        id: 'RC-TEST-006',
        referralToken: 'RC-TEST-006',
        patientId: '',
        patient: Patient(
          id: '',
          fullName: 'Different Patient',
          age: 22,
          gender: 'Male',
          contactNumber: '+91 9000000002',
          villageOrLocation: 'Zone B',
          createdAt: DateTime.now(),
        ),
        sourceFacilityId: 'PHC-02',
        destinationFacilityId: 'DH-02',
        referralReason: 'Allergic reaction',
        urgency: ReferralUrgency.urgent,
        status: ReferralStatus.created,
        syncState: SyncState.synced,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final saved = await localStorage.upsertReferralFromSync(serverReferral);

      // Must NOT be attached to patient ID 1
      expect(saved.patientId, isNot(equals('1')));
      expect(saved.patient?.fullName, equals('Different Patient'));

      final allPatients = await localStorage.getAllPatients();
      expect(allPatients.length, equals(2));
    });

    // 7. URGENT persists as URGENT after writing and reading SQLite.
    test('7. URGENT persists as URGENT in SQLite', () async {
      final ref = await localStorage.createReferralTransaction(
        patientName: 'Urgent Patient',
        patientAge: 40,
        patientGender: 'Male',
        sourceFacility: 'PHC-01',
        destinationFacility: 'DH-01',
        reason: 'Severe infection',
        urgency: ReferralUrgency.urgent,
        customReferralId: 'RC-URG-001',
      );

      expect(ref.urgency, equals('URGENT'));

      final domain = await localStorage.getDomainReferralById('RC-URG-001');
      expect(domain, isNotNull);
      expect(domain!.urgency, equals(ReferralUrgency.urgent));
    });

    // 8. EMERGENCY persists as EMERGENCY after writing and reading SQLite.
    test('8. EMERGENCY persists as EMERGENCY in SQLite', () async {
      final ref = await localStorage.createReferralTransaction(
        patientName: 'Emergency Patient',
        patientAge: 65,
        patientGender: 'Female',
        sourceFacility: 'PHC-01',
        destinationFacility: 'DH-01',
        reason: 'Acute stroke symptoms',
        urgency: ReferralUrgency.emergency,
        customReferralId: 'RC-EMG-001',
      );

      expect(ref.urgency, equals('EMERGENCY'));

      final domain = await localStorage.getDomainReferralById('RC-EMG-001');
      expect(domain, isNotNull);
      expect(domain!.urgency, equals(ReferralUrgency.emergency));
    });

    // 9. ROUTINE persists as ROUTINE.
    test('9. ROUTINE persists as ROUTINE in SQLite', () async {
      final ref = await localStorage.createReferralTransaction(
        patientName: 'Routine Patient',
        patientAge: 30,
        patientGender: 'Female',
        sourceFacility: 'PHC-01',
        destinationFacility: 'DH-01',
        reason: 'Annual health check',
        urgency: ReferralUrgency.routine,
        customReferralId: 'RC-ROUT-001',
      );

      expect(ref.urgency, equals('ROUTINE'));

      final domain = await localStorage.getDomainReferralById('RC-ROUT-001');
      expect(domain, isNotNull);
      expect(domain!.urgency, equals(ReferralUrgency.routine));
    });

    // 10. Existing offline referral creation still works.
    test('10. Existing offline referral creation still works seamlessly', () async {
      final ref = await localStorage.createReferralTransaction(
        patientName: 'Offline Created Patient',
        patientAge: 33,
        patientGender: 'Male',
        patientPhone: '+91 9876543211',
        patientLocation: 'Village Offline',
        sourceFacility: 'PHC-01',
        destinationFacility: 'DH-01',
        reason: 'Routine visit',
        clinicalNotes: 'Clear lungs',
        customReferralId: 'RC-OFFLINE-001',
      );

      expect(ref.referralId, equals('RC-OFFLINE-001'));
      expect(ref.status, equals('CREATED'));
      expect(ref.syncStatus, equals('PENDING'));
      expect(ref.urgency, equals('ROUTINE'));

      final domain = await localStorage.getDomainReferralById('RC-OFFLINE-001');
      expect(domain, isNotNull);
      expect(domain!.syncState, equals(SyncState.pendingSync));
      expect(domain.patient?.fullName, equals('Offline Created Patient'));
    });

    // 11. Existing sync queue behavior remains unchanged.
    test('11. Existing sync queue behavior remains unchanged', () async {
      await localStorage.createReferralTransaction(
        patientName: 'Queue Test Patient',
        patientAge: 25,
        patientGender: 'Female',
        sourceFacility: 'PHC-01',
        destinationFacility: 'DH-01',
        reason: 'Lab tests',
        urgency: ReferralUrgency.urgent,
        customReferralId: 'RC-QUEUE-001',
      );

      final queue = await localStorage.getPendingSyncItems();
      expect(queue.length, equals(1));
      expect(queue.first.entityId, equals('RC-QUEUE-001'));
      expect(queue.first.status, equals('PENDING'));

      final payload = jsonDecode(queue.first.payload) as Map<String, dynamic>;
      expect(payload['referralId'], equals('RC-QUEUE-001'));
      expect(payload['urgency'], equals('URGENT'));
      expect(payload['status'], equals('CREATED'));
    });
  });
}
