import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:relycare/services/local_storage/app_database.dart';
import 'package:relycare/services/local_storage/local_storage_service.dart';

void main() {
  late Directory tempDir;
  late File tempDbFile;

  setUp(() {
    // Create an isolated temporary directory and SQLite file for real disk persistence testing
    tempDir = Directory.systemTemp.createTempSync('relycare_persist_test_');
    tempDbFile = File(p.join(tempDir.path, 'relycare_test.sqlite'));
  });

  tearDown(() {
    // Clean up temporary database file and directory after test execution
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Database persistence test: close -> reopen preserves all SQLite data on disk', () async {
    // 1 & 2: Open AppDatabase pointing to real SQLite database file on disk
    final db1 = AppDatabase(NativeDatabase(tempDbFile));
    final storage1 = LocalStorageServiceImpl(db1);

    // 3 - 6: Create patient, referral, event, and sync queue item via atomic transaction
    final referral = await storage1.createReferralTransaction(
      patientName: 'Kavita Singh',
      patientAge: 32,
      patientGender: 'Female',
      patientLocation: 'Gram Panchayat Kalyanpur',
      patientPhone: '+91 9988776655',
      sourceFacility: 'PHC Rampur',
      destinationFacility: 'District Hospital Rampur',
      reason: 'Persistent high fever, severe anemia',
      clinicalNotes: 'Hb 7.2 g/dL, pulse 110 bpm',
      customReferralId: 'RC-PERSIST-101',
      createdByStaff: 'Dr. A. Sharma',
    );

    // 7: Verify all records exist in initial database instance
    expect(referral.referralId, equals('RC-PERSIST-101'));
    final p1 = await storage1.getPatientById(referral.patientId);
    expect(p1, isNotNull);
    expect(p1!.name, equals('Kavita Singh'));

    final events1 = await storage1.getReferralEvents('RC-PERSIST-101');
    expect(events1.length, equals(1));
    expect(events1.first.eventType, equals('CREATED'));

    final queue1 = await storage1.getPendingSyncItems();
    expect(queue1.length, equals(1));
    expect(queue1.first.entityId, equals('RC-PERSIST-101'));

    // 8: Close initial database completely
    await storage1.close();
    expect(tempDbFile.existsSync(), isTrue, reason: 'SQLite database file should exist on disk');

    // 9: Reopen the EXACT SAME SQLite database file from disk in a fresh instance
    final db2 = AppDatabase(NativeDatabase(tempDbFile));
    final storage2 = LocalStorageServiceImpl(db2);

    // 10: Read the patient again & verify persistence
    final p2 = await storage2.getPatientById(referral.patientId);
    expect(p2, isNotNull);
    expect(p2!.id, equals(referral.patientId));
    expect(p2.name, equals('Kavita Singh'));
    expect(p2.age, equals(32));
    expect(p2.gender, equals('Female'));
    expect(p2.phone, equals('+91 9988776655'));
    expect(p2.location, equals('Gram Panchayat Kalyanpur'));

    // 11: Read the referral again & verify persistence
    final ref2 = await storage2.getReferral('RC-PERSIST-101');
    expect(ref2, isNotNull);
    expect(ref2!.referralId, equals('RC-PERSIST-101'));
    expect(ref2.patientId, equals(referral.patientId));
    expect(ref2.sourceFacility, equals('PHC Rampur'));
    expect(ref2.destinationFacility, equals('District Hospital Rampur'));
    expect(ref2.reason, equals('Persistent high fever, severe anemia'));
    expect(ref2.clinicalNotes, equals('Hb 7.2 g/dL, pulse 110 bpm'));
    expect(ref2.status, equals('CREATED'));
    expect(ref2.syncStatus, equals('PENDING'));

    // 12: Read referral events again & verify persistence
    final events2 = await storage2.getReferralEvents('RC-PERSIST-101');
    expect(events2.length, equals(1));
    expect(events2.first.referralId, equals('RC-PERSIST-101'));
    expect(events2.first.eventType, equals('CREATED'));
    expect(events2.first.facility, equals('PHC Rampur'));
    expect(events2.first.performedBy, equals('Dr. A. Sharma'));

    // 13: Read pending sync queue items again & verify persistence
    final queue2 = await storage2.getPendingSyncItems();
    expect(queue2.length, equals(1));
    expect(queue2.first.entityType, equals('referral'));
    expect(queue2.first.entityId, equals('RC-PERSIST-101'));
    expect(queue2.first.operation, equals('CREATE'));
    expect(queue2.first.status, equals('PENDING'));
    expect(queue2.first.retryCount, equals(0));

    // 14 & 15: Close reopened database cleanly
    await storage2.close();
  });
}
