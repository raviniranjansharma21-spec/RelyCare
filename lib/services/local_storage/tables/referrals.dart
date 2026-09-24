import 'package:drift/drift.dart';
import 'patients.dart';

@DataClassName('ReferralData')
class Referrals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get referralId => text().unique()();
  IntColumn get patientId => integer().references(Patients, #id)();
  TextColumn get sourceFacility => text()();
  TextColumn get destinationFacility => text()();
  TextColumn get reason => text()();
  TextColumn get clinicalNotes => text().nullable()();
  TextColumn get urgency => text().withDefault(const Constant('ROUTINE'))();
  TextColumn get status => text().withDefault(const Constant('CREATED'))();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
