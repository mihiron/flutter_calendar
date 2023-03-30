import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/routes/app_routes.dart';
import 'package:flutter_calendar/src/views/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class DailyEventList extends ConsumerWidget {
  const DailyEventList({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(
        allEventsListLinkedHashMapProvider)[ref.watch(selectedDayProvider)]!;

    return events.isEmpty
        ? const Center(
            child: Text(
              '予定がありません',
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.separated(
            itemCount: events.length,
            padding: EdgeInsets.zero,
            separatorBuilder: (context, index) =>
                const Divider(color: Colors.black, height: 2),
            itemBuilder: (BuildContext context, int index) {
              return InkWell(
                onTap: () => Navigator.pushNamed(context, AppRoutes.editEvent),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Center(
                        child: events[index].isAllDay
                            ? const Text('終日')
                            : Column(
                                children: [
                                  Text(
                                    DateFormat.Hm().format(events[index].start),
                                  ),
                                  Text(
                                    DateFormat.Hm().format(events[index].end),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(6),
                      width: 6,
                      height: 48,
                      color: Colors.blue,
                    ),
                    Expanded(
                      child: Text(
                        events[index].title.toString(),
                        style: const TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
