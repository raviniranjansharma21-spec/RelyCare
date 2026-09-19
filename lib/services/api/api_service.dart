import '../../models/referral.dart';
import '../../models/patient.dart';
import '../../models/identity_match.dart';

/// Abstract REST API interface for FastAPI backend communication.
abstract class ApiService {
  // Referral Endpoints
  Future<List<Referral>> fetchReferrals();
  Future<Referral> createReferral(Referral referral);
  Future<void> updateReferralStatus(String referralId, String status);

  // Sync Endpoints
  Future<List<Referral>> syncBatch(List<Referral> queuedReferrals);

  // Patient & Matching Endpoints
  Future<List<IdentityMatch>> requestIdentityMatches(Patient incomingPatient);
}

/// Placeholder Implementation for API Service.
/// TODO (Backend Developer): Implement HTTP/Dio requests connecting to FastAPI.
class ApiServiceImpl implements ApiService {
  final String baseUrl;

  ApiServiceImpl({required this.baseUrl});

  @override
  Future<List<Referral>> fetchReferrals() async {
    // TODO: Send GET request to /api/v1/referrals.
    return [];
  }

  @override
  Future<Referral> createReferral(Referral referral) async {
    // TODO: Send POST request to /api/v1/referrals with referral JSON payload.
    return referral;
  }

  @override
  Future<void> updateReferralStatus(String referralId, String status) async {
    // TODO: Send PATCH request to /api/v1/referrals/{id}/status.
  }

  @override
  Future<List<Referral>> syncBatch(List<Referral> queuedReferrals) async {
    // TODO: Send POST request to /api/v1/referrals/sync with list of referrals.
    return [];
  }

  @override
  Future<List<IdentityMatch>> requestIdentityMatches(Patient incomingPatient) async {
    // TODO: Send POST request to /api/v1/patients/match to invoke RapidFuzz backend matching.
    return [];
  }
}
