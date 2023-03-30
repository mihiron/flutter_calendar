import 'package:drift/drift.dart';
import 'package:flutter_calendar/src/services/local/daos/event_dao.dart';
import 'package:flutter_calendar/src/services/local/database.dart';

class LocalEventRepository {
  final EventsDao eventsDao;

  LocalEventRepository(AppDatabase appDatabase)
      : eventsDao = appDatabase.eventsDao;

  Future<List<Event>> getAllEvents() {
    return eventsDao.getAllEvents();
  }

  Stream<List<Event>> watchAllEvents() {
    return eventsDao.watchAllEvents();
  }

  Future<void> createEvent({
    required String title,
    required bool isAllDay,
    required DateTime start,
    required DateTime end,
    required String comment,
  }) {
    return eventsDao.createEvent(
      EventsCompanion(
        title: Value(title),
        isAllDay: Value(isAllDay),
        start: Value(start),
        end: Value(end),
        comment: Value(comment),
      ),
    );
  }

  Future<void> updateEvent(Event event) {
    return eventsDao.updateEvent(event);
  }

  Future<void> deleteEvent(int id) {
    return eventsDao.deleteEventById(id);
  }
}
