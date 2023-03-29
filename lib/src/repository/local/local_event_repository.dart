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

  Future<List<Event>> getEventsForDay(DateTime day) {
    return eventsDao.getEventsForDay(day);
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

  // Future<Map<DateTime, List<Event>>> getEventsByDate() async {
  //   final events = await eventsDao.getAllEvents();
  //   final Map<DateTime, List<Event>> eventsByDate = {};
  //   for (final event in events) {
  //     final date = DateTime.parse(event.start.toString());
  //     final eventsOnDate = eventsByDate[date] ?? [];
  //     eventsByDate[date] = eventsOnDate;
  //   }
  //   return eventsByDate;
  // }
}

// bool isSameDay(DateTime? a, DateTime? b) {
//   if (a == null || b == null) {
//     return false;
//   }

//   return a.year == b.year && a.month == b.month && a.day == b.day;
// }
