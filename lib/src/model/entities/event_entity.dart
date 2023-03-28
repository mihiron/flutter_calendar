import 'package:drift/drift.dart';

class Events extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 0, max: 20)();
  BoolColumn get isAllDay => boolean().withDefault(const Constant(false))();
  DateTimeColumn get start => dateTime()();
  DateTimeColumn get end => dateTime()();
  TextColumn get comment => text().withLength(min: 0, max: 200)();
}
