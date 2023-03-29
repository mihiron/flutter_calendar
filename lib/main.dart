import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/repository/local/local_repository_provider.dart';
import 'package:flutter_calendar/src/routes/app_router.dart';
import 'package:flutter_calendar/src/services/local/app_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

final databaseProvider = Provider<AppDatabase>(
  (ref) {
    final appDatabase = AppDatabase();
    return appDatabase;
  },
);

final localRepoProvider = Provider<LocalRepositoryProvider>(
  (ref) => LocalRepositoryProvider(ref.watch(databaseProvider)),
);

void main() {
  initializeDateFormatting()
      .then((_) => runApp(const ProviderScope(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
