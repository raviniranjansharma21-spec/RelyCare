import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/referrals.dart';
import '../tables/referral_events.dart';

part 'referral_dao.g.dart';

@DriftAccessor(tables: [Referrals, ReferralEvents])
class ReferralDao extends DatabaseAccessor<AppDatabase> with _$ReferralDaoMixin {
  ReferralDao(super.db);

  /// Inserts a new referral record and returns the row id.
  Future<int> insertReferral(ReferralsCompanion referral) =>
      into(referrals).insert(referral);

  /// Retrieves a referral by its integer auto-increment ID.
  Future<ReferralData?> getReferralById(int id) =>
      (select(referrals)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  /// Retrieves a referral by its business referralId token (e.g. 'RC-A7X92').
  Future<ReferralData?> getReferralByReferralId(String referralId) =>
      (select(referrals)..where((tbl) => tbl.referralId.equals(referralId))).getSingleOrNull();

  /// Retrieves all referrals sorted by creation date descending.
  Future<List<ReferralData>> getAllReferrals() =>
      (select(referrals)..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)])).get();

  /// Updates referral lifecycle status and sets updatedAt to now.
  Future<int> updateReferralStatus(String referralId, String status) {
    return (update(referrals)..where((tbl) => tbl.referralId.equals(referralId))).write(
      ReferralsCompanion(
        status: Value(status),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Updates referral sync status (e.g. PENDING, SYNCING, SYNCED) and sets updatedAt to now.
  Future<int> updateReferralSyncStatus(String referralId, String syncStatus) {
    return (update(referrals)..where((tbl) => tbl.referralId.equals(referralId))).write(
      ReferralsCompanion(
        syncStatus: Value(syncStatus),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a referral by its integer row id.
  Future<int> deleteReferral(int id) =>
      (delete(referrals)..where((tbl) => tbl.id.equals(id))).go();

  /// Inserts a referral event into the timeline.
  Future<int> insertReferralEvent(ReferralEventsCompanion event) =>
      into(referralEvents).insert(event);

  /// Retrieves all events for a given referralId sorted chronologically.
  Future<List<ReferralEventData>> getEventsForReferral(String referralId) =>
      (select(referralEvents)
            ..where((tbl) => tbl.referralId.equals(referralId))
            ..orderBy([(tbl) => OrderingTerm.asc(tbl.timestamp)]))
          .get();
}
