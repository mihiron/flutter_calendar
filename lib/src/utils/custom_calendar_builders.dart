import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CustomCalendarBuilders {
  Color _textColor(DateTime day) {
    const defaultTextColor = Colors.black87;

    if (day.weekday == DateTime.sunday) {
      return Colors.red;
    }
    if (day.weekday == DateTime.saturday) {
      return Colors.blue[600]!;
    }
    return defaultTextColor;
  }

  /// 曜日部分を生成する
  Widget daysOfWeekBuilder(BuildContext context, DateTime day) {
    // <TableCalendarの中身からコピペ>
    // アプリの言語設定読み込み
    const locale = 'ja_JP';

    // アプリの言語設定に曜日の文字を対応させる
    final dowText =
        const DaysOfWeekStyle().dowTextFormatter?.call(day, locale) ??
            DateFormat.E(locale).format(day);
    // </ TableCalendarの中身からコピペ>

    return Center(
      child: Text(
        dowText,
        style: TextStyle(
          color: _textColor(day),
        ),
      ),
    );
  }

  /// 通常の日付部分を生成する
  Widget defaultBuilder(
      BuildContext context, DateTime day, DateTime focusedDay) {
    return _CalendarCellTemplate(
      dayText: day.day.toString(),
      dayTextColor: _textColor(day),
    );
  }
}

class _CalendarCellTemplate extends StatelessWidget {
  const _CalendarCellTemplate({
    Key? key,
    String? dayText,
    Duration? duration,
    Alignment? textAlign,
    Color? dayTextColor,
    Color? borderColor,
    double? borderWidth,
  })  : dayText = dayText ?? '',
        duration = duration ?? const Duration(milliseconds: 250),
        textAlign = textAlign ?? Alignment.center,
        dayTextColor = dayTextColor ?? Colors.black87,
        borderColor = borderColor ?? Colors.black87,
        borderWidth = borderWidth ?? 0.5,
        super(key: key);

  final String dayText;
  final Color? dayTextColor;
  final Duration duration;
  final Alignment? textAlign;
  final Color? borderColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      margin: EdgeInsets.zero,
      alignment: textAlign,
      child: Text(
        dayText,
        style: TextStyle(
          color: dayTextColor,
        ),
      ),
    );
  }
}
