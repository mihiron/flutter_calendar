import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/routes/app_routes.dart';
import 'package:flutter_calendar/src/services/local/app_database.dart';
import 'package:flutter_calendar/src/views/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// validation
final isEnableSaveProvider = StateProvider((ref) => false);

// タイトル
final titleControllerProvider = StateProvider<TextEditingController>((ref) {
  return TextEditingController(
    text: (ref.watch(eventProvider) == null)
        ? ''
        : ref.watch(eventProvider)!.title,
  );
});

// 終日
final isAllDayProvider = StateProvider<bool>((ref) =>
    (ref.watch(eventProvider) == null)
        ? false
        : ref.watch(eventProvider)!.isAllDay);

// 開始日
final StateProvider<DateTime> startDateProvider = StateProvider((ref) {
  if (ref.watch(eventProvider) == null) {
    return ref.watch(selectedDayProvider);
  } else {
    return ref.watch(eventProvider)!.start;
  }
});

// 終了日
final StateProvider<DateTime> endDateProvider = StateProvider((ref) {
  if (ref.watch(eventProvider) == null) {
    return ref.watch(selectedDayProvider);
  } else {
    return ref.watch(eventProvider)!.end;
  }
});

// 開始日時
final StateProvider<DateTime> startDateTimeProvider = StateProvider((ref) {
  if (ref.watch(eventProvider) == null) {
    return DateTime(
      ref.watch(selectedDayProvider).year,
      ref.watch(selectedDayProvider).month,
      ref.watch(selectedDayProvider).day,
      DateTime.now().hour,
      DateTime.now().minute,
    ).add(Duration(minutes: 15 - DateTime.now().minute % 15));
  } else {
    return DateTime(
      ref.watch(eventProvider)!.start.year,
      ref.watch(eventProvider)!.start.month,
      ref.watch(eventProvider)!.start.day,
      DateTime.now().hour,
      DateTime.now().minute,
    ).add(Duration(minutes: 15 - DateTime.now().minute % 15));
  }
});

// 修了日時
final StateProvider<DateTime> endDateTimeProvider = StateProvider((ref) {
  if (ref.watch(eventProvider) == null) {
    return DateTime(
      ref.watch(selectedDayProvider).year,
      ref.watch(selectedDayProvider).month,
      ref.watch(selectedDayProvider).day,
      DateTime.now().hour,
      DateTime.now().minute,
    )
        .add(Duration(minutes: 15 - DateTime.now().minute % 15))
        .add(const Duration(hours: 1));
  } else {
    return DateTime(
      ref.watch(eventProvider)!.end.year,
      ref.watch(eventProvider)!.end.month,
      ref.watch(eventProvider)!.end.day,
      DateTime.now().hour,
      DateTime.now().minute,
    )
        .add(Duration(minutes: 15 - DateTime.now().minute % 15))
        .add(const Duration(hours: 1));
  }
});

// タイトル
final commentControllerProvider = StateProvider<TextEditingController>((ref) {
  return TextEditingController(
    text: (ref.watch(eventProvider) == null)
        ? ''
        : ref.watch(eventProvider)!.comment,
  );
});

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
    void validateSave() {
      if ((ref.watch(eventProvider) == null &&
              ref.watch(titleControllerProvider).text != '' &&
              ref.watch(commentControllerProvider).text != '') ||
          (ref.watch(eventProvider) != null &&
              (ref.watch(titleControllerProvider).text !=
                      ref.watch(eventProvider)!.title ||
                  ref.watch(commentControllerProvider).text !=
                      ref.watch(eventProvider)!.comment ||
                  ref.watch(isAllDayProvider) !=
                      ref.watch(eventProvider)!.isAllDay ||
                  (ref.watch(eventProvider)!.isAllDay == true &&
                      ref.watch(startDateProvider) !=
                          ref.watch(eventProvider)!.start) ||
                  (ref.watch(eventProvider)!.isAllDay == true &&
                      ref.watch(endDateProvider) !=
                          ref.watch(eventProvider)!.end) ||
                  (ref.watch(eventProvider)!.isAllDay == false &&
                      ref.watch(startDateTimeProvider) !=
                          ref.watch(eventProvider)!.start) ||
                  (ref.watch(eventProvider)!.isAllDay == false &&
                      ref.watch(endDateTimeProvider) !=
                          ref.watch(eventProvider)!.end)))) {
        ref.read(isEnableSaveProvider.notifier).state = true;
      } else {
        ref.read(isEnableSaveProvider.notifier).state = false;
      }
    }

    void showDatePicker(context, ifStart) {
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        CupertinoButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
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
                              if (ref
                                      .watch(startDateProvider)
                                      .isAfter(ref.watch(endDateProvider)) ==
                                  true) {
                                ref.read(endDateProvider.notifier).state =
                                    ref.watch(startDateProvider);
                                // ref.read(endDateProvider.notifier) = ref.watch(startDateProvider);
                              }
                            } else {
                              ref.read(endDateProvider.notifier).state =
                                  newEndDate!;
                              if (ref
                                      .watch(startDateProvider)
                                      .isAfter(ref.watch(endDateProvider)) ==
                                  true) {
                                ref.read(startDateProvider.notifier).state =
                                    ref.watch(endDateProvider);
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
                      initialDateTime: (ifStart == true)
                          ? ref.watch(startDateTimeProvider)
                          : ref.watch(endDateTimeProvider),
                      onDateTimeChanged: (DateTime newDateTime) {
                        if (ifStart == true) {
                          newStartDate = newDateTime;
                        } else {
                          newEndDate = newDateTime;
                        }
                      },
                    ),
                  )
                ]);
          });
    }

    void showDateTimePicker(context, ifStart) {
      showCupertinoModalPopup<void>(
          context: context,
          builder: (BuildContext context) {
            return Column(mainAxisAlignment: MainAxisAlignment.end, children: <
                Widget>[
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    CupertinoButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
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
                          if (ref
                                  .watch(startDateTimeProvider)
                                  .isAfter(ref.watch(endDateTimeProvider)) ==
                              true) {
                            ref.read(endDateTimeProvider.notifier).state = ref
                                .watch(startDateTimeProvider)
                                .add(const Duration(hours: 1));
                          }
                        } else {
                          ref.read(endDateTimeProvider.notifier).state =
                              newEndDateTime!;
                          if (ref
                                  .watch(startDateTimeProvider)
                                  .isAfter(ref.watch(endDateTimeProvider)) ==
                              true) {
                            ref.read(startDateTimeProvider.notifier).state = ref
                                .watch(endDateTimeProvider)
                                .add(const Duration(hours: -1));
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
                  initialDateTime: (ifStart == true)
                      ? ref.watch(startDateTimeProvider)
                      : ref.watch(endDateTimeProvider),
                  minuteInterval: 15,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newDateTime) {
                    if (ifStart == true) {
                      newStartDateTime = newDateTime;
                    } else {
                      newEndDateTime = newDateTime;
                    }
                  },
                ),
              )
            ]);
          });
    }

    final localRepo = ref.read(localRepoProvider);
    final eventRepo = localRepo.eventRepo;

    final navigatorKey = GlobalKey<NavigatorState>();

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
        title: Text((ref.watch(eventProvider) == null) ? '予定の追加' : '予定の編集'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () async {
                if (ref.watch(isEnableSaveProvider) == true) {
                  if (ref.watch(eventProvider) == null) {
                    await eventRepo.createEvent(
                      title: ref.watch(titleControllerProvider).text,
                      comment: ref.watch(commentControllerProvider).text,
                      isAllDay: ref.watch(isAllDayProvider),
                      start: (ref.watch(isAllDayProvider) == true)
                          ? ref.watch(startDateProvider)
                          : ref.watch(startDateTimeProvider),
                      end: (ref.watch(isAllDayProvider) == true)
                          ? ref.watch(endDateProvider)
                          : ref.watch(endDateTimeProvider),
                    );
                  } else {
                    await eventRepo.updateEvent(
                      ref.watch(eventProvider)!.copyWith(
                            id: ref.watch(eventProvider)!.id,
                            title: ref.watch(titleControllerProvider).text,
                            comment: ref.watch(commentControllerProvider).text,
                            isAllDay: ref.watch(isAllDayProvider),
                            start: (ref.watch(isAllDayProvider) == true)
                                ? ref.watch(startDateProvider)
                                : ref.watch(startDateTimeProvider),
                            end: (ref.watch(isAllDayProvider) == true)
                                ? ref.watch(endDateProvider)
                                : ref.watch(endDateTimeProvider),
                          ),
                    );
                  }
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
                foregroundColor: (ref.watch(isEnableSaveProvider) == true)
                    ? Colors.black
                    : Colors.grey,
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
                  controller: ref.watch(titleControllerProvider),
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
                        value: ref.watch(isAllDayProvider),
                        onChanged: (_) {
                          ref.read(isAllDayProvider.notifier).state =
                              !ref.watch(isAllDayProvider);
                          validateSave();
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListTile(
                      onTap: () async {
                        if (ref.watch(isAllDayProvider) == true) {
                          showDatePicker(context, true);
                        } else {
                          showDateTimePicker(context, true);
                        }
                      },
                      leading: const Text('開始'),
                      trailing: Text(
                        (ref.watch(isAllDayProvider) == true)
                            ? dateFormat.format(ref.watch(startDateProvider))
                            : dateTimeFormat
                                .format(ref.watch(startDateTimeProvider)),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListTile(
                      onTap: () async {
                        if (ref.watch(isAllDayProvider) == true) {
                          showDatePicker(context, false);
                        } else {
                          showDateTimePicker(context, false);
                        }
                      },
                      leading: const Text('修了'),
                      trailing: Text(
                        (ref.watch(isAllDayProvider) == true)
                            ? dateFormat.format(ref.watch(endDateProvider))
                            : dateTimeFormat
                                .format(ref.watch(endDateTimeProvider)),
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
                  controller: ref.watch(commentControllerProvider),
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
            (ref.watch(eventProvider) == null)
                ? Container()
                : const SizedBox(height: 30),
            (ref.watch(eventProvider) == null)
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
                                  await eventRepo.deleteEvent(
                                      ref.watch(eventProvider)!.id);
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
