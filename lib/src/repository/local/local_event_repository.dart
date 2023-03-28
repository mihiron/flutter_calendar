import 'package:flutter_calendar/src/services/local/daos/event_dao.dart';
import 'package:flutter_calendar/src/services/local/datebase.dart';

class LocalEventRepository {
  final EventDao eventsDao;

  LocalEventRepository(AppDatabase appDatabase)
      : eventsDao = appDatabase.eventDao;

  //TODO: メソッド作成
}
