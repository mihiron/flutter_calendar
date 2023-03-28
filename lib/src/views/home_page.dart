// Copyright 2019 Aleksander Woźniak
// SPDX-License-Identifier: Apache-2.0
import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/utils/custom_calendar_builders.dart';
import 'package:flutter_calendar/src/utils/table_calendar.dart';
import 'package:flutter_calendar/src/views/widget/calendar_header.dart';
import 'package:flutter_calendar/src/views/widget/date_picker.dart';
import 'package:table_calendar/table_calendar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final ValueNotifier<List<Event>> _selectedEvents;
  final ValueNotifier<DateTime> _focusedDay = ValueNotifier(DateTime.now());
  DateTime? _selectedDay;
  final CustomCalendarBuilders customCalendarBuilders =
      CustomCalendarBuilders();

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay.value;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    // Implementation example
    return kEvents[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay.value = focusedDay;
      });
      _selectedEvents.value = _getEventsForDay(selectedDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('カレンダー'),
      ),
      body: Column(
        children: [
          ValueListenableBuilder<DateTime>(
              valueListenable: _focusedDay,
              builder: (context, value, _) {
                return CalendarHeader(
                  focusedDay: value,
                  locale: 'ja_JP',
                  onTodayButtonTap: () {
                    setState(() {
                      _focusedDay.value = DateTime.now();
                      _selectedDay = DateTime.now();
                    });
                  },
                  onDatePicked: () async {
                    final DateTime? datePicked =
                        await DatePicker.show(context, _focusedDay.value);
                    if (datePicked != null && datePicked != _focusedDay.value) {
                      setState(() {
                        _focusedDay.value = datePicked;
                        _selectedDay = datePicked;
                      });
                    }
                  },
                );
              }),
          TableCalendar<Event>(
            locale: 'ja_JP',
            headerVisible: false,
            firstDay: kFirstDay,
            lastDay: kLastDay,
            focusedDay: _focusedDay.value,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.monday,
            onDaySelected: _onDaySelected,
            onPageChanged: (focusedDay) {
              _focusedDay.value = focusedDay;
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
