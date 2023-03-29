import 'package:flutter_calendar/src/services/local/database.dart';

import 'local_repository.dart';

class LocalRepositoryProvider {
  final AppDatabase appDatabase;

  late final LocalEventRepository eventRepo;

  LocalRepositoryProvider(this.appDatabase) {
    eventRepo = LocalEventRepository(appDatabase);
  }
}
