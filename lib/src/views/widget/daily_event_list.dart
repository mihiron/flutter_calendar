import 'package:flutter/material.dart';
import 'package:flutter_calendar/main.dart';
import 'package:flutter_calendar/src/routes/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyEventList extends ConsumerWidget {
  const DailyEventList({Key? key, required this.date}) : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<List> eventList = [
      ['title1', true, '', ''],
      ['title2', false, '10:00', '12:00'],
      ['title3', false, '13:00', '18:30'],
    ];

    final localRepo = ref.read(localRepoProvider);
    final eventRepo = localRepo.eventRepo;

    final events = eventRepo.getEventsForDay(date);

    // return FutureBuilder(builder: ((context, snapshot) {
    //   return ListView.builder(itemBuilder: ((context, index) {
    //     return ListTile();
    //   }));
    // }));

    return eventList.isEmpty
        ? const Center(
            child: Text(
              '予定がありません',
              style: TextStyle(fontSize: 16),
            ),
          )
        : ListView.separated(
            itemCount: eventList.length,
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
                        child: eventList[index][1]
                            ? const Text('終日')
                            : Column(
                                children: [
                                  Text(eventList[index][2]),
                                  Text(eventList[index][3]),
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
                        eventList[index][0],
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
