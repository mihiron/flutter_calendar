import 'package:drift_db_viewer/drift_db_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar/src/services/local/app_database.dart';
import 'package:flutter_calendar/src/views/add_event_page.dart';
import 'package:flutter_calendar/src/views/daily_page.dart';
import 'package:flutter_calendar/src/views/edit_event_page.dart';
import 'package:flutter_calendar/src/views/home_page.dart';

import 'app_routes.dart';

class AppRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return _buildRoute(MyHomePage());
      case AppRoutes.daily:
        return _buildPageRoute(const DailyPage(), settings: settings);
      case AppRoutes.addEvent:
        return _buildRoute(AddEventPage());
      case AppRoutes.editEvent:
        return _buildRoute(EditEventPage());
      case AppRoutes.driftDbViewer:
        return _buildRoute(DriftDbViewer(settings.arguments as AppDatabase));

      default:
        return null;
    }
  }

  static Route<dynamic>? _buildRoute(
    Widget child, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return MaterialPageRoute<dynamic>(
      builder: (BuildContext context) => child,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }

  static PageRouteBuilder _buildPageRoute(Widget child,
      {RouteSettings? settings}) {
    return PageRouteBuilder(
      settings: settings,
      opaque: false,
      pageBuilder: (context, animation, secondaryAnimation) => child,
    );
  }
}
