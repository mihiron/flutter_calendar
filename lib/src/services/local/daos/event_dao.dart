import 'package:drift/drift.dart';
import 'package:flutter_calendar/src/services/local/database.dart';

part 'event_dao.g.dart';

@DriftAccessor(tables: [Events])
class EventsDao extends DatabaseAccessor<AppDatabase> with _$EventsDaoMixin {
  EventsDao(AppDatabase db) : super(db);

  Future<List<Event>> getAllEvents() {
    return select(events).get();
  }

  Stream<List<Event>> watchAllEvents() {
    return select(events).watch();
  }

  Future<int> createEvent(EventsCompanion event) {
    return into(events).insert(event);
  }

  Future updateEvent(Event event) {
    return update(events).replace(event);
  }

  Future deleteEventById(int id) {
    return (delete(events)..where((tbl) => tbl.id.equals(id))).go();
  }
}
