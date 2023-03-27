import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarHeader extends StatelessWidget {
  final DateTime focusedDay;
  final dynamic locale;
  final VoidCallback onTodayButtonTap;
  final VoidCallback onDatePicked;

  const CalendarHeader({
    Key? key,
    required this.focusedDay,
    required this.locale,
    required this.onTodayButtonTap,
    required this.onDatePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final headerText = DateFormat.yMMM(locale).format(focusedDay);

    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OutlinedButton(
            onPressed: onTodayButtonTap,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('今日', style: TextStyle(color: Colors.black)),
          ),
          Row(
            children: [
              SizedBox(
                width: 120.0,
                child: Text(
                  headerText,
                  style: const TextStyle(fontSize: 22.0),
                ),
              ),
              IconButton(
                onPressed: onDatePicked,
                icon: const Icon(Icons.arrow_drop_down),
              ),
            ],
          ),
          const SizedBox(width: 60.0),
        ],
      ),
    );
  }
}
