// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_calendar/main.dart';
import 'package:flutter_calendar/src/common/enum.dart';
import 'package:flutter_calendar/src/routes/app_routes.dart';
import 'package:flutter_calendar/src/services/local/app_database.dart';
import 'package:flutter_calendar/src/utils/custom_calendar_builders.dart';
import 'package:flutter_calendar/src/views/provider.dart';
import 'package:flutter_calendar/src/views/widget/calendar_header.dart';
import 'package:flutter_calendar/src/views/widget/date_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

class MyHomePage extends ConsumerWidget {
  MyHomePage({super.key});

  final CustomCalendarBuilders customCalendarBuilders =
      CustomCalendarBuilders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localRepo = ref.read(localRepoProvider);
    final eventRepo = localRepo.eventRepo;

    List<Event> getEventsForDay(DateTime day) {
      return ref.watch(allEventsListLinkedHashMapProvider)[day] ?? [];
    }

    void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
      if (!isSameDay(ref.read(selectedDayProvider), selectedDay)) {
        ref.read(selectedDayProvider.notifier).state = selectedDay;
        ref.read(focusedDayProvider.notifier).state.value = focusedDay;
      } else {
        Navigator.pushNamed(context, AppRoutes.daily,
            arguments: ref.read(selectedDayProvider));
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('カレンダー'),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<DateTime>(
              valueListenable: ref.watch(focusedDayProvider),
              builder: (context, value, _) {
                return CalendarHeader(
                  focusedDay: value,
                  locale: 'ja_JP',
                  onTodayButtonTap: () {
                    ref.read(focusedDayProvider.notifier).state.value =
                        DateTime.now();
                    ref.read(selectedDayProvider.notifier).state =
                        DateTime.now();
                  },
                  onDatePicked: () async {
                    final DateTime? datePicked = await DatePicker.show(
                        context, ref.read(focusedDayProvider).value);
                    if (datePicked != null &&
                        datePicked != ref.read(focusedDayProvider).value) {
                      ref.read(focusedDayProvider.notifier).state.value =
                          datePicked;
                      ref.read(selectedDayProvider.notifier).state = datePicked;
                    }
                  },
                );
              }),
          StreamBuilder(
            stream: eventRepo.watchAllEvents(),
            builder: (context, snapshot) {
              for (int i = -70; i < 70; i++) {
                DateTime selectedDate =
                    ref.watch(focusedDayProvider).value.add(Duration(days: i));
                List<Event> dailyEventsList = [];
                if (snapshot.data != null) {
                  for (int j = 0; j < snapshot.data!.length; j++) {
                    if (snapshot.data![j].start.isBefore(DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            24,
                            00,
                            00)) &&
                        snapshot.data![j].end.isAfter(DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day - 1,
                            23,
                            59,
                            59))) {
                      dailyEventsList.add(Event(
                        id: snapshot.data![j].id,
                        title: snapshot.data![j].title,
                        isAllDay: snapshot.data![j].isAllDay,
                        start: snapshot.data![j].start,
                        end: snapshot.data![j].end,
                        comment: snapshot.data![j].comment,
                      ));
                    }
                  }
                }
                ref.read(allEventsMapProvider.notifier).state[DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day)] = dailyEventsList;
              }

              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(allEventsListLinkedHashMapProvider.notifier).state =
                    LinkedHashMap<DateTime, List<Event>>(
                  equals: isSameDay,
                  hashCode: getHashCode,
                )..addAll(ref.watch(allEventsMapProvider));
              });

              return TableCalendar<Event>(
                locale: 'ja_JP',
                headerVisible: false,
                firstDay: kFirstDay,
                lastDay: kLastDay,
                focusedDay: ref.watch(focusedDayProvider).value,
                selectedDayPredicate: (day) =>
                    isSameDay(ref.watch(selectedDayProvider), day),
                calendarFormat: CalendarFormat.month,
                eventLoader: getEventsForDay,
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: onDaySelected,
                onPageChanged: (focusedDay) {
                  ref.read(focusedDayProvider.notifier).state.value =
                      focusedDay;
                },
                calendarBuilders: CalendarBuilders(
                  dowBuilder: customCalendarBuilders.daysOfWeekBuilder,
                  defaultBuilder: customCalendarBuilders.defaultBuilder,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
