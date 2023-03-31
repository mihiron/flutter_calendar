import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/routes/app_routes.dart';
import 'package:flutter_calendar/src/services/local/app_database.dart';
import 'package:flutter_calendar/src/views/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// validation
final isEnableSaveProvider = StateProvider.autoDispose((ref) => false);

// タイトル
final titleControllerProvider =
    StateProvider.autoDispose<TextEditingController>((ref) =>
        TextEditingController(
            text: (ref.read(eventProvider) == null)
                ? ''
                : ref.read(eventProvider)!.title));

// 終日
final isAllDayProvider = StateProvider.autoDispose<bool>((ref) =>
    (ref.read(eventProvider) == null)
        ? false
        : ref.read(eventProvider)!.isAllDay);

// 開始日
final startDateProvider = StateProvider.autoDispose<DateTime>((ref) =>
    (ref.read(eventProvider) == null)
        ? ref.watch(selectedDayProvider)
        : ref.read(eventProvider)!.start);

// 終了日
final endDateProvider = StateProvider.autoDispose<DateTime>((ref) =>
    (ref.read(eventProvider) == null)
        ? ref.watch(selectedDayProvider)
        : ref.read(eventProvider)!.end);

// 開始日時
final startDateTimeProvider = StateProvider.autoDispose<DateTime>(
    (ref) => (ref.read(eventProvider) == null)
        ? DateTime(
            ref.watch(selectedDayProvider).year,
            ref.watch(selectedDayProvider).month,
            ref.watch(selectedDayProvider).day,
            DateTime.now().hour,
            DateTime.now().minute,
          ).add(Duration(minutes: 15 - DateTime.now().minute % 15))
        : DateTime(
            ref.read(eventProvider)!.start.year,
            ref.read(eventProvider)!.start.month,
            ref.read(eventProvider)!.start.day,
            DateTime.now().hour,
            DateTime.now().minute,
          ).add(Duration(minutes: 15 - DateTime.now().minute % 15)));

// 終了日時
final endDateTimeProvider = StateProvider.autoDispose<DateTime>((ref) =>
    (ref.read(eventProvider) == null)
        ? DateTime(
            ref.watch(selectedDayProvider).year,
            ref.watch(selectedDayProvider).month,
            ref.watch(selectedDayProvider).day,
            DateTime.now().hour,
            DateTime.now().minute,
          )
            .add(Duration(minutes: 15 - DateTime.now().minute % 15))
            .add(const Duration(hours: 1))
        : DateTime(
            ref.read(eventProvider)!.end.year,
            ref.read(eventProvider)!.end.month,
            ref.read(eventProvider)!.end.day,
            DateTime.now().hour,
            DateTime.now().minute,
          )
            .add(Duration(minutes: 15 - DateTime.now().minute % 15))
            .add(const Duration(hours: 1)));

// コメント
final commentControllerProvider =
    StateProvider.autoDispose<TextEditingController>((ref) =>
        TextEditingController(
            text: (ref.read(eventProvider) == null)
                ? ''
                : ref.read(eventProvider)!.comment));

class AddEditEventPage extends ConsumerWidget {
  AddEditEventPage({super.key});

  DateTime? newStartDateTime;
  DateTime? newStartDate;
  DateTime? newEndDateTime;
  DateTime? newEndDate;
  DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm');

  final focusNode = FocusNode();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localRepo = ref.read(localRepoProvider);
    final eventRepo = localRepo.eventRepo;

    final navigatorKey = GlobalKey<NavigatorState>();

    final event = ref.read(eventProvider);
    final isEnableSave = ref.watch(isEnableSaveProvider);
    final titleController = ref.watch(titleControllerProvider);
    final isAllDay = ref.watch(isAllDayProvider);
    final startDate = ref.watch(startDateProvider);
    final endDate = ref.watch(endDateProvider);
    final startDateTime = ref.watch(startDateTimeProvider);
    final endDateTime = ref.watch(endDateTimeProvider);
    final commentController = ref.watch(commentControllerProvider);

    void validateSave() {
      ((event == null &&
                  titleController.text != '' &&
                  commentController.text != '') ||
              (event != null &&
                  (titleController.text != event.title ||
                      commentController.text != event.comment ||
                      isAllDay != event.isAllDay ||
                      (event.isAllDay == true && startDate != event.start) ||
                      (event.isAllDay == true && endDate != event.end) ||
                      (event.isAllDay == false &&
                          startDateTime != event.start) ||
                      (event.isAllDay == false && endDateTime != event.end))))
          ? ref.read(isEnableSaveProvider.notifier).state = true
          : ref.read(isEnableSaveProvider.notifier).state = false;
    }

    void showDatePicker(context, ifStart) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                      child: const Text('キャンセル'),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        if (ifStart == true) {
                          ref.read(startDateProvider.notifier).state =
                              newStartDate!;
                          if (startDate.isAfter(endDate) == true) {
                            ref.read(endDateProvider.notifier).state =
                                startDate;
                          }
                        } else {
                          ref.read(endDateProvider.notifier).state =
                              newEndDate!;
                          if (startDate.isAfter(endDate) == true) {
                            ref.read(startDateProvider.notifier).state =
                                endDate;
                          }
                        }
                        validateSave();
                        Navigator.pop(context);
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                      child: const Text('完了'),
                    )
                  ],
                ),
              ),
              _bottomPicker(
                CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime:
                      (ifStart == true) ? startDateTime : endDateTime,
                  onDateTimeChanged: (DateTime newDateTime) => (ifStart == true)
                      ? newStartDate = newDateTime
                      : newEndDate = newDateTime,
                ),
              )
            ],
          );
        },
      );
    }

    void showDateTimePicker(context, ifStart) {
      showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                      child: const Text('キャンセル'),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        if (ifStart == true) {
                          ref.read(startDateTimeProvider.notifier).state =
                              newStartDateTime!;
                          if (startDateTime.isAfter(endDateTime) == true) {
                            ref.read(endDateTimeProvider.notifier).state =
                                startDateTime.add(const Duration(hours: 1));
                          }
                        } else {
                          ref.read(endDateTimeProvider.notifier).state =
                              newEndDateTime!;
                          if (startDateTime.isAfter(endDateTime) == true) {
                            ref.read(startDateTimeProvider.notifier).state =
                                endDateTime.add(const Duration(hours: -1));
                          }
                        }
                        validateSave();
                        Navigator.pop(context);
                      },
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 5.0,
                      ),
                      child: const Text('完了'),
                    )
                  ],
                ),
              ),
              _bottomPicker(
                CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.dateAndTime,
                  initialDateTime:
                      (ifStart == true) ? startDateTime : endDateTime,
                  minuteInterval: 15,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDateTime) => (ifStart == true)
                      ? newStartDateTime = newDateTime
                      : newEndDateTime = newDateTime,
                ),
              )
            ],
          );
        },
      );
    }

    return Scaffold(
      key: navigatorKey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_outlined),
          onPressed: () {
            showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('編集を破棄'),
                  ),
                  CupertinoActionSheetAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                ],
              ),
            );
          },
        ),
        title: Text(event == null ? '予定の追加' : '予定の編集'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (isEnableSave == true) {
                  event == null
                      ? await eventRepo.createEvent(
                          title: titleController.text,
                          comment: commentController.text,
                          isAllDay: isAllDay,
                          start: isAllDay == true ? startDate : startDateTime,
                          end: isAllDay == true ? endDate : endDateTime)
                      : await eventRepo.updateEvent(
                          event.copyWith(
                            id: event.id,
                            title: titleController.text,
                            comment: commentController.text,
                            isAllDay: isAllDay,
                            start: isAllDay == true ? startDate : startDateTime,
                            end: isAllDay == true ? endDate : endDateTime,
                          ),
                        );

                  Navigator.of(context).pop();
                }
              },
              onLongPress: () {
                final AppDatabase db = ref.read(databaseProvider);
                Navigator.pushNamed(context, AppRoutes.driftDbViewer,
                    arguments: db);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor:
                    isEnableSave == true ? Colors.black : Colors.grey,
              ),
              child: const Text('保存'),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(6),
              height: 60,
              width: double.infinity,
              child: Card(
                elevation: 0,
                child: TextField(
                  controller: titleController,
                  autofocus: true,
                  focusNode: focusNode,
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
                          validateSave();
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListTile(
                      onTap: () async {
                        isAllDay == true
                            ? showDatePicker(context, true)
                            : showDateTimePicker(context, true);
                      },
                      leading: const Text('開始'),
                      trailing: Text(
                        isAllDay == true
                            ? dateFormat.format(startDate)
                            : dateTimeFormat.format(startDateTime),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListTile(
                      onTap: () async {
                        isAllDay == true
                            ? showDatePicker(context, false)
                            : showDateTimePicker(context, false);
                      },
                      leading: const Text('修了'),
                      trailing: Text(
                        isAllDay == true
                            ? dateFormat.format(endDate)
                            : dateTimeFormat.format(endDateTime),
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
                  onChanged: (_) => validateSave(),
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
            event == null ? Container() : const SizedBox(height: 30),
            event == null
                ? Container()
                : GestureDetector(
                    onTap: () async {
                      showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text('予定の削除'),
                            content: const Text('本当にこの予定を削除しますか？'),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text('キャンセル'),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              CupertinoDialogAction(
                                child: const Text('削除'),
                                onPressed: () async {
                                  await eventRepo.deleteEvent(event.id);
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Container(
                      height: 45,
                      width: 1000,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: const Center(
                        child: Text(
                          'この予定を削除',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _bottomPicker(Widget picker) {
    return Container(
      height: 216,
      padding: const EdgeInsets.only(top: 6.0),
      color: CupertinoColors.white,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: CupertinoColors.black,
          fontSize: 22.0,
        ),
        child: GestureDetector(
          onTap: () {},
          child: SafeArea(
            top: false,
            child: picker,
          ),
        ),
      ),
    );
  }
}
