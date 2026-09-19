import '../../models/referral.dart';
import '../../models/patient.dart';

/// Abstract contract for local SQLite / Drift persistence.
/// Ensures clean separation between storage logic and repositories.
abstract class LocalStorageService {
  /// Initializes the local database, creates tables, and handles migrations.
  Future<void> init();

  // Patient Operations
  Future<void> savePatient(Patient patient);
  Future<Patient?> getPatientById(String id);
  Future<List<Patient>> getAllPatients();

  // Referral Operations
  Future<void> saveReferral(Referral referral);
  Future<Referral?> getReferralById(String id);
  Future<List<Referral>> getAllReferrals();
  Future<List<Referral>> getPendingSyncReferrals();
  Future<void> updateReferralSyncState(String referralId, SyncState syncState);

  // Clear / Reset
  Future<void> clearAll();
}

/// Placeholder Implementation for Local Storage.
/// TODO (Database Specialist): Implement actual SQLite/Drift database calls here.
class LocalStorageServiceImpl implements LocalStorageService {
  @override
  Future<void> init() async {
    // TODO: Open database and execute CREATE TABLE queries.
  }

  @override
  Future<void> savePatient(Patient patient) async {
    // TODO: Insert or replace patient record into local SQLite database.
  }

  @override
  Future<Patient?> getPatientById(String id) async {
    // TODO: Query patient table by id.
    return null;
  }

  @override
  Future<List<Patient>> getAllPatients() async {
    // TODO: Query all patients from local table.
    return [];
  }

  @override
  Future<void> saveReferral(Referral referral) async {
    // TODO: Insert or replace referral record into local SQLite database.
  }

  @override
  Future<Referral?> getReferralById(String id) async {
    // TODO: Query referral table by id.
    return null;
  }

  @override
  Future<List<Referral>> getAllReferrals() async {
    // TODO: Query all referrals ordered by creation date DESC.
    return [];
  }

  @override
  Future<List<Referral>> getPendingSyncReferrals() async {
    // TODO: Query referrals where syncState == SyncState.pendingSync.
    return [];
  }

  @override
  Future<void> updateReferralSyncState(String referralId, SyncState syncState) async {
    // TODO: Update sync state in SQLite table.
  }

  @override
  Future<void> clearAll() async {
    // TODO: Truncate local tables for test reset.
  }
}
