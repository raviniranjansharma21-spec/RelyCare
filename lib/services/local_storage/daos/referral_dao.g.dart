// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_dao.dart';

// ignore_for_file: type=lint
mixin _$ReferralDaoMixin on DatabaseAccessor<AppDatabase> {
  $PatientsTable get patients => attachedDatabase.patients;
  $ReferralsTable get referrals => attachedDatabase.referrals;
  $ReferralEventsTable get referralEvents => attachedDatabase.referralEvents;
  ReferralDaoManager get managers => ReferralDaoManager(this);
}

class ReferralDaoManager {
  final _$ReferralDaoMixin _db;
  ReferralDaoManager(this._db);
  $$PatientsTableTableManager get patients =>
      $$PatientsTableTableManager(_db.attachedDatabase, _db.patients);
  $$ReferralsTableTableManager get referrals =>
      $$ReferralsTableTableManager(_db.attachedDatabase, _db.referrals);
  $$ReferralEventsTableTableManager get referralEvents =>
      $$ReferralEventsTableTableManager(
        _db.attachedDatabase,
        _db.referralEvents,
      );
}
