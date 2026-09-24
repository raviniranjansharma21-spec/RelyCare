import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:relycare/core/errors/app_exceptions.dart';
import 'package:relycare/models/patient.dart';
import 'package:relycare/models/referral.dart';
import 'package:relycare/models/referral_status.dart';
import 'package:relycare/services/api/api_service.dart';

void main() {
  group('ApiServiceImpl Unit Tests (MockClient)', () {
    const baseUrl = 'http://localhost:8000/api/v1';

    final samplePatient = Patient(
      id: 'RC-TEST-001',
      fullName: 'Rahul Sharma',
      age: 42,
      gender: 'Male',
      villageOrLocation: 'Village Rampur',
      contactNumber: '+91 9876543210',
      createdAt: DateTime.utc(2026, 9, 22, 10, 0, 0),
    );

    final sampleReferral = Referral(
      id: '1',
      referralToken: 'RC-TEST-001',
      patientId: 'RC-TEST-001',
      patient: samplePatient,
      sourceFacilityId: 'PHC-104',
      destinationFacilityId: 'DH-201',
      referralReason: 'Severe abdominal pain',
      urgency: ReferralUrgency.urgent,
      clinicalNotesSummary: 'Ultrasound advised',
      status: ReferralStatus.created,
      syncState: SyncState.pendingSync,
      createdAt: DateTime.utc(2026, 9, 22, 10, 0, 0),
      updatedAt: DateTime.utc(2026, 9, 22, 10, 0, 0),
    );

    test('createReferral: 201 Created returns parsed Referral domain model', () async {
      final mockResponse = {
        'id': 101,
        'referral_id': 'RC-TEST-001',
        'patient_name': 'Rahul Sharma',
        'age': 42,
        'gender': 'Male',
        'village_or_location': 'Village Rampur',
        'contact_number': '+91 9876543210',
        'source_facility': 'PHC-104',
        'destination_facility': 'DH-201',
        'urgency': 'URGENT',
        'reason': 'Severe abdominal pain',
        'clinical_notes_summary': 'Ultrasound advised',
        'status': 'CREATED',
        'created_at': '2026-09-22T10:00:00Z',
        'updated_at': '2026-09-22T10:00:00Z',
      };

      final client = MockClient((request) async {
        expect(request.method, equals('POST'));
        expect(request.url.toString(), equals('$baseUrl/referrals'));
        expect(request.headers['Content-Type'], contains('application/json'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['referral_id'], equals('RC-TEST-001'));
        expect(body['patient_name'], equals('Rahul Sharma'));
        expect(body['urgency'], equals('URGENT'));

        return http.Response(jsonEncode(mockResponse), 201, headers: {'content-type': 'application/json'});
      });

      final apiService = ApiServiceImpl(baseUrl: baseUrl, client: client);
      final result = await apiService.createReferral(sampleReferral);

      expect(result.referralToken, equals('RC-TEST-001'));
      expect(result.patient?.fullName, equals('Rahul Sharma'));
      expect(result.urgency, equals(ReferralUrgency.urgent));
      expect(result.status, equals(ReferralStatus.created));
      expect(result.syncState, equals(SyncState.synced));
    });

    test('createReferral: 409 Conflict throws DuplicateReferralException', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Referral with referral_id RC-TEST-001 already exists.'}),
          409,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiService = ApiServiceImpl(baseUrl: baseUrl, client: client);

      expect(
        () => apiService.createReferral(sampleReferral),
        throwsA(
          isA<DuplicateReferralException>()
              .having((e) => e.referralId, 'referralId', equals('RC-TEST-001'))
              .having((e) => e.statusCode, 'statusCode', equals(409)),
        ),
      );
    });

    test('createReferral: 422 Unprocessable Entity throws NetworkException with 422', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'Invalid request payload'}),
          422,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiService = ApiServiceImpl(baseUrl: baseUrl, client: client);

      expect(
        () => apiService.createReferral(sampleReferral),
        throwsA(
          isA<NetworkException>()
              .having((e) => e.statusCode, 'statusCode', equals(422)),
        ),
      );
    });

    test('createReferral: 500 Server Error throws NetworkException with 500', () async {
      final client = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final apiService = ApiServiceImpl(baseUrl: baseUrl, client: client);

      expect(
        () => apiService.createReferral(sampleReferral),
        throwsA(
          isA<NetworkException>()
              .having((e) => e.statusCode, 'statusCode', equals(500)),
        ),
      );
    });

    test('getReferral: 200 OK returns parsed Referral', () async {
      final mockResponse = {
        'id': 102,
        'referral_id': 'RC-TEST-002',
        'patient_name': 'Sunita Devi',
        'age': 35,
        'gender': 'Female',
        'village_or_location': 'Village Rampur',
        'contact_number': '+91 9876500000',
        'source_facility': 'PHC-104',
        'destination_facility': 'DH-201',
        'urgency': 'ROUTINE',
        'reason': 'Routine antenatal checkup',
        'clinical_notes_summary': null,
        'status': 'RECEIVED',
        'created_at': '2026-09-22T11:00:00Z',
        'updated_at': '2026-09-22T11:30:00Z',
      };

      final client = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.toString(), equals('$baseUrl/referrals/RC-TEST-002'));
        return http.Response(jsonEncode(mockResponse), 200, headers: {'content-type': 'application/json'});
      });

      final apiService = ApiServiceImpl(baseUrl: baseUrl, client: client);
      final result = await apiService.getReferral('RC-TEST-002');

      expect(result.referralToken, equals('RC-TEST-002'));
      expect(result.patient?.fullName, equals('Sunita Devi'));
      expect(result.status, equals(ReferralStatus.received));
    });

    test('getReferral: 404 Not Found throws NetworkException with 404', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'detail': 'Referral not found'}), 404);
      });

      final apiService = ApiServiceImpl(baseUrl: baseUrl, client: client);

      expect(
        () => apiService.getReferral('RC-NONEXISTENT'),
        throwsA(
          isA<NetworkException>().having((e) => e.statusCode, 'statusCode', equals(404)),
        ),
      );
    });

    test('updateReferralStatus: 200 OK succeeds on PATCH', () async {
      final client = MockClient((request) async {
        expect(request.method, equals('PATCH'));
        expect(request.url.toString(), equals('$baseUrl/referrals/RC-TEST-001/status'));

        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['status'], equals('PATIENT_ARRIVED'));

        return http.Response('{"status": "PATIENT_ARRIVED"}', 200, headers: {'content-type': 'application/json'});
      });

      final apiService = ApiServiceImpl(baseUrl: baseUrl, client: client);
      await expectLater(
        apiService.updateReferralStatus('RC-TEST-001', 'PATIENT_ARRIVED'),
        completes,
      );
    });

    test('fetchReferrals: 200 OK returns paginated referrals and passes query params', () async {
      final mockResponse = {
        'items': [
          {
            'id': 1,
            'referral_id': 'RC-001',
            'patient_name': 'Patient 1',
            'age': 30,
            'gender': 'Male',
            'source_facility': 'PHC-1',
            'destination_facility': 'DH-1',
            'urgency': 'ROUTINE',
            'reason': 'Reason 1',
            'status': 'CREATED',
            'created_at': '2026-09-22T08:00:00Z',
            'updated_at': '2026-09-22T08:00:00Z',
          },
          {
            'id': 2,
            'referral_id': 'RC-002',
            'patient_name': 'Patient 2',
            'age': 40,
            'gender': 'Female',
            'source_facility': 'PHC-2',
            'destination_facility': 'DH-2',
            'urgency': 'URGENT',
            'reason': 'Reason 2',
            'status': 'CREATED',
            'created_at': '2026-09-22T09:00:00Z',
            'updated_at': '2026-09-22T09:00:00Z',
          },
        ],
        'total': 2,
        'skip': 0,
        'limit': 50,
      };

      final client = MockClient((request) async {
        expect(request.method, equals('GET'));
        expect(request.url.queryParameters['skip'], equals('0'));
        expect(request.url.queryParameters['limit'], equals('50'));
        expect(request.url.queryParameters['status'], equals('CREATED'));

        return http.Response(jsonEncode(mockResponse), 200, headers: {'content-type': 'application/json'});
      });

      final apiService = ApiServiceImpl(baseUrl: baseUrl, client: client);
      final items = await apiService.fetchReferrals(skip: 0, limit: 50, status: 'CREATED');

      expect(items.length, equals(2));
      expect(items.first.referralToken, equals('RC-001'));
      expect(items.last.referralToken, equals('RC-002'));
    });
  });
}
