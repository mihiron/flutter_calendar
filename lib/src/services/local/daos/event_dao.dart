import 'package:drift/drift.dart';
import 'package:flutter_calendar/src/services/local/datebase.dart';

part 'event_dao.g.dart';

@DriftAccessor(tables: [Event])
class EventDao extends DatabaseAccessor<AppDatabase> with _$EventDaoMixin {
  EventDao(AppDatabase db) : super(db);

  //TODO: メソッド作成
}
