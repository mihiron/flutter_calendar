import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/common/enum.dart';
import 'package:flutter_calendar/src/views/provider.dart';
import 'package:flutter_calendar/src/views/widget/daily_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailyPage extends ConsumerWidget {
  const DailyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    DateTime date = ModalRoute.of(context)?.settings.arguments as DateTime;

    final initPage =
        ref.watch(focusedDayProvider).value.difference(kFirstDay).inDays;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.7),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: Container(
            margin: const EdgeInsets.only(top: 120),
            height: 600,
            child: PageView.builder(
              controller: PageController(
                initialPage: initPage,
                viewportFraction: 0.9,
              ),
              onPageChanged: (index) {
                ref.read(focusedDayProvider.notifier).state =
                    ValueNotifier(kFirstDay.add(Duration(days: index)));
                ref.read(selectedDayProvider.notifier).state =
                    kFirstDay.add(Duration(days: index));
              },
              itemBuilder: (context, index) {
                return DailyCard(
                  date: DateTime(
                      date.year, date.month, date.day + index - initPage),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
