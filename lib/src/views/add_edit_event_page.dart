import 'package:drift/drift.dart' as d;
import 'package:flutter/material.dart';
import 'package:flutter_calendar/main.dart';
import 'package:flutter_calendar/src/routes/app_routes.dart';
import 'package:flutter_calendar/src/services/local/app_database.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final isAllDayProvider = StateProvider<bool>((ref) => false);

class AddEditEventPage extends ConsumerWidget {
  AddEditEventPage({
    super.key,
    this.event,
  });

  final Event? event;

  final List<Widget> listItems = [];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localRepo = ref.read(localRepoProvider);
    final eventRepo = localRepo.eventRepo;

    final titleController = TextEditingController(text: event?.title);
    final isAllDay = ref.watch(isAllDayProvider);
    DateTime start = DateTime.now();
    DateTime end = DateTime.now().add(const Duration(hours: 1));
    final commentController = TextEditingController(text: event?.comment);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('予定の追加'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                EventsCompanion newEvent = EventsCompanion(
                  title: d.Value(titleController.text),
                  isAllDay: d.Value(isAllDay),
                  start: d.Value(start),
                  end: d.Value(end),
                  comment: d.Value(commentController.text),
                );
                eventRepo.createEvent(newEvent);
                Navigator.pop(context);
              },
              onLongPress: () {
                final AppDatabase db = ref.read(databaseProvider);
                Navigator.pushNamed(context, AppRoutes.driftDbViewer,
                    arguments: db);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor:
                    (titleController.text != '' && commentController.text != '')
                        ? Colors.black
                        : Colors.grey,
              ),
              child: const Text('保存'),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(6),
            height: 60,
            width: double.infinity,
            child: Card(
              elevation: 0,
              child: TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: InputBorder.none,
                  hintText: 'タイトルを入力してください',
                ),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            color: Colors.white,
            height: 160,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: ListTile(
                    leading: const Text('終日'),
                    trailing: Switch(
                      value: isAllDay,
                      onChanged: (_) {
                        ref.read(isAllDayProvider.notifier).state = !isAllDay;
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListTile(
                    onTap: () async {
                      final selectedTime = (isAllDay)
                          ? await DatePicker.showDatePicker(context,
                              locale: LocaleType.jp)
                          : await DatePicker.showDateTimePicker(context,
                              locale: LocaleType.jp);

                      start = selectedTime!;
                    },
                    leading: const Text('開始'),
                    trailing: Text(
                      (isAllDay)
                          ? DateFormat('yyyy-MM-dd').format(start)
                          : DateFormat('yyyy-MM-dd').add_Hm().format(start),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                  child: ListTile(
                    onTap: () async {
                      final selectedTime = (isAllDay)
                          ? await DatePicker.showDatePicker(context,
                              locale: LocaleType.jp)
                          : await DatePicker.showDateTimePicker(context,
                              locale: LocaleType.jp);

                      end = selectedTime!;
                    },
                    leading: const Text('修了'),
                    trailing: Text(
                      (isAllDay)
                          ? DateFormat('yyyy-MM-dd').format(end)
                          : DateFormat('yyyy-MM-dd').add_Hm().format(end),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(6),
            height: 144,
            width: double.infinity,
            child: Card(
              elevation: 0,
              child: TextField(
                controller: commentController,
                maxLines: 5,
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  enabledBorder: InputBorder.none,
                  hintText: 'コメントを入力してください',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
