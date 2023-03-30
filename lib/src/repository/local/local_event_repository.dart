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

  Future<void> createEvent(EventsCompanion event) {
    return eventsDao.createEvent(event);
  }

  Future<void> updateEvent(Event event) {
    return eventsDao.updateEvent(event);
  }

  Future<void> deleteEvent(int id) {
    return eventsDao.deleteEventById(id);
  }
}
