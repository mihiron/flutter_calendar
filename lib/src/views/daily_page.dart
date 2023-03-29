import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/views/widget/daily_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final pageControllerProvider = StateProvider<PageController>((ref) {
  return PageController(
    initialPage: 30,
    viewportFraction: 0.9,
  );
});

class DailyPage extends ConsumerWidget {
  const DailyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = ref.read(pageControllerProvider);

    DateTime date = ModalRoute.of(context)?.settings.arguments as DateTime;

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
              controller: pageController,
              itemBuilder: (context, index) {
                return DailyCard(
                  date: DateTime(date.year, date.month, date.day + index - 30),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
