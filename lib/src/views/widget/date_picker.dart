import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/utils/table_calendar.dart';

class DatePicker {
  static Future<DateTime?> show(BuildContext context, DateTime dateTime) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: kToday,
      firstDate: kFirstDay,
      lastDate: kLastDay,
    );
    return datePicked;
  }
}
