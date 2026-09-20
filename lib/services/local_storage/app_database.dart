import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'tables/patients.dart';
import 'tables/referrals.dart';
import 'tables/referral_events.dart';
import 'tables/sync_queue.dart';
import 'daos/patient_dao.dart';
import 'daos/referral_dao.dart';
import 'daos/sync_queue_dao.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [Patients, Referrals, ReferralEvents, SyncQueue],
  daos: [PatientDao, ReferralDao, SyncQueueDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static LazyDatabase _openConnection() {
    return LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'relycare.sqlite'));
      return NativeDatabase.createInBackground(file);
    });
  }
}
