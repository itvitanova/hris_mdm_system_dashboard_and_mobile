import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../features/auth/presentation/pages/login_page.dart';

class AppRoutes {
  static const String root = '/';
  static const String login = '/login';
  static const String leaveCalendar = '/leave-calendar';
  static const String approvals = '/approvals';

  Route onRoute(RouteSettings settings, {required ApiClient api}) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (context) => LoginPage(
            api: api,
            onLogin: () {},
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const Scaffold(
            body: Center(child: Text('Halaman tidak ditemukan')),
          ),
        );
    }
  }
}
