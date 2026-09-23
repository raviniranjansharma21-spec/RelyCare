import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/referral.dart';
import '../../models/patient.dart';
import '../../models/referral_status.dart';
import '../../models/identity_match.dart';
import '../../models/user_model.dart';

/// Abstract REST API interface for FastAPI backend communication.
abstract class ApiService {
  // Auth Endpoints
  void setAuthToken(String? token) {}
  Future<Map<String, dynamic>> login(String username, String password) async => {};
  Future<UserModel> getMe() async => throw UnimplementedError('getMe not implemented');


  // Referral Endpoints
  Future<List<Referral>> fetchReferrals({int skip = 0, int limit = 100, String? status});
  Future<Referral> getReferral(String referralId);
  Future<Referral> createReferral(Referral referral);
  Future<void> updateReferralStatus(String referralId, String status);

  // Sync Endpoints
  Future<List<Referral>> syncBatch(List<Referral> queuedReferrals);

  // Patient & Matching Endpoints
  Future<List<IdentityMatch>> requestIdentityMatches(Patient incomingPatient);
}

/// Real HTTP Client Implementation for RelyCare FastAPI Backend.
class ApiServiceImpl implements ApiService {
  final String baseUrl;
  final http.Client _client;
  final Duration timeout;

  String? _authToken;

  ApiServiceImpl({
    required this.baseUrl,
    http.Client? client,
    this.timeout = const Duration(milliseconds: AppConstants.connectTimeoutMs),
    String? initialToken,
  })  : _client = client ?? http.Client(),
        _authToken = initialToken;

  @override
  void setAuthToken(String? token) {
    _authToken = token;
  }

  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };
    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  String _normalizeUrl(String path) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cleanBase$cleanPath';
  }

  Map<String, dynamic>? _tryParseJson(String body) {
    try {
      return jsonDecode(body) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  void _checkAuthError(http.Response response) {
    if (response.statusCode == 401) {
      final body = _tryParseJson(response.body);
      final detail = body?['detail'] ?? 'Authentication required or token expired';
      throw UnauthenticatedException(detail.toString());
    } else if (response.statusCode == 403) {
      final body = _tryParseJson(response.body);
      final detail = body?['detail'] ?? 'Access denied for this resource';
      throw UnauthorizedException(detail.toString());
    }
  }

  Referral _referralFromJson(Map<String, dynamic> json) {
    final referralToken = (json['referral_id'] ?? '').toString();
    final patient = Patient(
      id: '',
      fullName: (json['patient_name'] ?? 'Unknown Patient').toString(),
      age: (json['age'] as num?)?.toInt() ?? 0,
      gender: (json['gender'] ?? 'Other').toString(),
      villageOrLocation: (json['village_or_location'] ?? '').toString(),
      contactNumber: json['contact_number']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );

    return Referral(
      id: referralToken,
      referralToken: referralToken,
      patientId: '',
      patient: patient,
      sourceFacilityId: (json['source_facility'] ?? '').toString(),
      destinationFacilityId: (json['destination_facility'] ?? '').toString(),
      referralReason: (json['reason'] ?? '').toString(),
      urgency: ReferralUrgencyExtension.fromString((json['urgency'] ?? 'ROUTINE').toString()),
      clinicalNotesSummary: json['clinical_notes_summary']?.toString(),
      status: ReferralStatusExtension.fromString((json['status'] ?? 'CREATED').toString()),
      syncState: SyncState.synced,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  @override
  Future<Map<String, dynamic>> login(String username, String password) async {
    final payload = jsonEncode({
      'username': username.trim(),
      'password': password,
    });

    try {
      final response = await _client
          .post(
            Uri.parse(_normalizeUrl('/auth/login')),
            headers: _headers,
            body: payload,
          )
          .timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final token = data['access_token']?.toString();
        if (token != null) {
          setAuthToken(token);
        }
        return data;
      } else if (response.statusCode == 401) {
        final body = _tryParseJson(response.body);
        final detail = body?['detail'] ?? 'Invalid username or password';
        throw UnauthenticatedException(detail.toString());
      } else if (response.statusCode == 403) {
        final body = _tryParseJson(response.body);
        final detail = body?['detail'] ?? 'User account is inactive';
        throw UnauthorizedException(detail.toString());
      } else {
        throw NetworkException(
          'Login failed (HTTP ${response.statusCode}): ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: $e');
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out after ${timeout.inSeconds}s: $e');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unexpected error during login: $e');
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await _client
          .get(
            Uri.parse(_normalizeUrl('/auth/me')),
            headers: _headers,
          )
          .timeout(timeout);

      _checkAuthError(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return UserModel.fromJson(data);
      } else {
        throw NetworkException(
          'Failed to fetch user profile (HTTP ${response.statusCode}): ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: $e');
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out after ${timeout.inSeconds}s: $e');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unexpected error fetching user profile: $e');
    }
  }

  @override
  Future<Referral> createReferral(Referral referral) async {
    final payload = jsonEncode({
      'referral_id': referral.referralToken,
      'patient_name': referral.patient?.fullName ?? 'Unknown Patient',
      'age': referral.patient?.age ?? 0,
      'gender': referral.patient?.gender ?? 'Other',
      'village_or_location': referral.patient?.villageOrLocation,
      'contact_number': referral.patient?.contactNumber,
      'source_facility': referral.sourceFacilityId,
      'destination_facility': referral.destinationFacilityId,
      'urgency': referral.urgency.code,
      'reason': referral.referralReason,
      'clinical_notes_summary': referral.clinicalNotesSummary,
      'status': referral.status.code,
    });

    try {
      final response = await _client
          .post(
            Uri.parse(_normalizeUrl('/referrals')),
            headers: _headers,
            body: payload,
          )
          .timeout(timeout);

      _checkAuthError(response);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return _referralFromJson(data);
      } else if (response.statusCode == 409) {
        final body = _tryParseJson(response.body);
        final detail = body?['detail'] ?? 'Duplicate referral ${referral.referralToken} already exists';
        throw DuplicateReferralException(referral.referralToken, message: detail.toString());
      } else if (response.statusCode == 422 || response.statusCode == 400) {
        final body = _tryParseJson(response.body);
        final detail = body?['detail'] ?? response.body;
        throw NetworkException('Validation error on referral creation: $detail', statusCode: response.statusCode);
      } else {
        throw NetworkException(
          'Failed to create referral on server (HTTP ${response.statusCode}): ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on DuplicateReferralException {
      rethrow;
    } on NetworkException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: $e');
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out after ${timeout.inSeconds}s: $e');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unexpected error during referral creation: $e');
    }
  }

  @override
  Future<Referral> getReferral(String referralId) async {
    try {
      final response = await _client
          .get(
            Uri.parse(_normalizeUrl('/referrals/$referralId')),
            headers: _headers,
          )
          .timeout(timeout);

      _checkAuthError(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        return _referralFromJson(data);
      } else if (response.statusCode == 404) {
        throw NetworkException('Referral $referralId not found on server', statusCode: 404);
      } else {
        throw NetworkException(
          'Server error fetching referral $referralId (HTTP ${response.statusCode}): ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: $e');
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out after ${timeout.inSeconds}s: $e');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unexpected error fetching referral: $e');
    }
  }

  @override
  Future<void> updateReferralStatus(String referralId, String status) async {
    final payload = jsonEncode({'status': status.toUpperCase()});

    try {
      final response = await _client
          .patch(
            Uri.parse(_normalizeUrl('/referrals/$referralId/status')),
            headers: _headers,
            body: payload,
          )
          .timeout(timeout);

      _checkAuthError(response);

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw NetworkException('Referral $referralId not found on server', statusCode: 404);
      } else {
        throw NetworkException(
          'Failed to update referral status (HTTP ${response.statusCode}): ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: $e');
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out after ${timeout.inSeconds}s: $e');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unexpected error updating referral status: $e');
    }
  }

  @override
  Future<List<Referral>> fetchReferrals({int skip = 0, int limit = 100, String? status}) async {
    try {
      final queryParams = <String, String>{
        'skip': skip.toString(),
        'limit': limit.toString(),
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status.toUpperCase();
      }

      final baseUri = Uri.parse(_normalizeUrl('/referrals'));
      final uri = baseUri.replace(queryParameters: queryParams);

      final response = await _client.get(uri, headers: _headers).timeout(timeout);

      _checkAuthError(response);

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items
            .map((item) => _referralFromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw NetworkException(
          'Failed to fetch referrals (HTTP ${response.statusCode}): ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on NetworkException {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkException('Network connection failed: $e');
    } on TimeoutException catch (e) {
      throw NetworkException('Request timed out after ${timeout.inSeconds}s: $e');
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException('Unexpected error fetching referrals: $e');
    }
  }

  @override
  Future<List<Referral>> syncBatch(List<Referral> queuedReferrals) async {
    final synced = <Referral>[];
    for (final referral in queuedReferrals) {
      final res = await createReferral(referral);
      synced.add(res);
    }
    return synced;
  }

  @override
  Future<List<IdentityMatch>> requestIdentityMatches(Patient incomingPatient) async {
    return [];
  }
}
