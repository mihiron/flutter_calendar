import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/routes/app_routes.dart';
import 'package:flutter_calendar/src/views/widget/daily_event_list.dart';
import 'package:intl/intl.dart';

class DailyCard extends StatelessWidget {
  const DailyCard({Key? key, required this.date}) : super(key: key);

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final cardTitle = DateFormat.yMd('ja_JP').format(date);
    final dayOfWeek = DateFormat.E('ja_JP').format(date);

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32), color: Colors.white),
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey, width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    text: cardTitle,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    children: [
                      TextSpan(
                        text: '（$dayOfWeek）',
                        style: TextStyle(
                          color: (date.weekday == 6)
                              ? Colors.blue
                              : (date.weekday == 7)
                                  ? Colors.red
                                  : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.blue),
                  onPressed: () =>
                      Navigator.pushNamed(context, AppRoutes.addEvent),
                )
              ],
            ),
          ),
          Expanded(
            child: DailyEventList(date: date),
          ),
        ],
      ),
    );
  }
}
