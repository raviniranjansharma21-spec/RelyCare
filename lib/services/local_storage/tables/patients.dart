import 'package:drift/drift.dart';

@DataClassName('PatientData')
class Patients extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get age => integer()();
  TextColumn get gender => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
