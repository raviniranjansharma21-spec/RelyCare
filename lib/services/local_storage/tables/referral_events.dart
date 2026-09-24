import 'package:drift/drift.dart';

@DataClassName('ReferralEventData')
class ReferralEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get referralId => text()();
  TextColumn get eventType => text()();
  DateTimeColumn get timestamp => dateTime().withDefault(currentDateAndTime)();
  TextColumn get facility => text().nullable()();
  TextColumn get performedBy => text().nullable()();
  TextColumn get metadata => text().nullable()();
}
