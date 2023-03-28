// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/utils/custom_calendar_builders.dart';
import 'package:flutter_calendar/src/utils/table_calendar.dart';
import 'package:flutter_calendar/src/views/widget/calendar_header.dart';
import 'package:flutter_calendar/src/views/widget/date_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

final focusedDayProvider = StateProvider<ValueNotifier<DateTime>>((ref) {
  return ValueNotifier(DateTime.now());
});

final seletedDayProvider = StateProvider<DateTime>((ref) {
  final selectedDay = ref.read(focusedDayProvider).value;
  return selectedDay;
});

class MyHomePage extends ConsumerWidget {
  MyHomePage({super.key});

  final CustomCalendarBuilders customCalendarBuilders =
      CustomCalendarBuilders();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
      if (!isSameDay(ref.read(seletedDayProvider), selectedDay)) {
        ref.read(seletedDayProvider.notifier).state = selectedDay;
        ref.read(focusedDayProvider.notifier).state.value = focusedDay;
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
                    ref.read(seletedDayProvider.notifier).state =
                        DateTime.now();
                  },
                  onDatePicked: () async {
                    final DateTime? datePicked = await DatePicker.show(
                        context, ref.read(focusedDayProvider).value);
                    if (datePicked != null &&
                        datePicked != ref.read(focusedDayProvider).value) {
                      ref.read(focusedDayProvider.notifier).state.value =
                          datePicked;
                      ref.read(seletedDayProvider.notifier).state = datePicked;
                    }
                  },
                );
              }),
          TableCalendar<Event>(
            locale: 'ja_JP',
            headerVisible: false,
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: ref.watch(focusedDayProvider).value,
            selectedDayPredicate: (day) =>
                isSameDay(ref.watch(seletedDayProvider), day),
            calendarFormat: CalendarFormat.month,
            eventLoader: getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: onDaySelected,
            onPageChanged: (focusedDay) {
              ref.read(focusedDayProvider.notifier).state.value = focusedDay;
            },
            calendarBuilders: CalendarBuilders(
              dowBuilder: customCalendarBuilders.daysOfWeekBuilder,
              defaultBuilder: customCalendarBuilders.defaultBuilder,
            ),
          ),
        ],
      ),
    );
  }
}
