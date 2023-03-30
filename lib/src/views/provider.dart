import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/repository/local/local_repository_provider.dart';
import 'package:flutter_calendar/src/services/local/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

final databaseProvider = Provider<AppDatabase>(
  (ref) {
    final appDatabase = AppDatabase();
    return appDatabase;
  },
);

final localRepoProvider = Provider<LocalRepositoryProvider>(
  (ref) => LocalRepositoryProvider(ref.watch(databaseProvider)),
);

final focusedDayProvider = StateProvider<ValueNotifier<DateTime>>((ref) {
  return ValueNotifier(DateTime.now());
});

final selectedDayProvider = StateProvider<DateTime>((ref) {
  final selectedDay = ref.read(focusedDayProvider).value;
  return selectedDay;
});

final allEventsMapProvider =
    StateProvider<Map<DateTime, List<Event>>>((ref) => {});

int getHashCode(DateTime key) {
  return key.day * 1000000 + key.month * 10000 + key.year;
}

final allEventsListLinkedHashMapProvider =
    StateProvider<LinkedHashMap<DateTime, List<Event>>>(
  (ref) => LinkedHashMap<DateTime, List<Event>>(
    equals: isSameDay,
    hashCode: getHashCode,
  )..addAll(ref.watch(allEventsMapProvider)),
);

final eventProvider = StateProvider<Event?>((ref) => null);
