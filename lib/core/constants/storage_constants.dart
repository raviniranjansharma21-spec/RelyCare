/// Local Storage & Database Table / Key Constants for SQLite & SharedPreferences.
class StorageConstants {
  // Database Info
  static const String databaseName = 'relycare.db';
  static const int databaseVersion = 1;

  // SQLite Table Names
  static const String tablePatients = 'patients';
  static const String tableReferrals = 'referrals';
  static const String tableReferralEvents = 'referral_events';
  static const String tableFacilities = 'facilities';
  static const String tableSyncQueue = 'sync_queue';

  // Key-Value Storage Keys
  static const String keyAuthToken = 'auth_token';
  static const String keyCurrentFacilityId = 'current_facility_id';
  static const String keyLastSyncTimestamp = 'last_sync_timestamp';
  static const String keyIsFirstLaunch = 'is_first_launch';

  // TODO: Add database column name constants or migration version keys.
}
