import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/di/injection_container.dart';
import 'package:mdm_hris/core/services/network_connectivity_service.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/root/presentation/widgets/dashboard/dashboard_avatar.dart';
import 'package:mdm_hris/features/root/presentation/widgets/dashboard_tab.dart';
import 'package:mdm_hris/features/root/presentation/widgets/profile/profile_avatar.dart';
import 'package:mdm_hris/features/root/presentation/widgets/profile_tab.dart';

void main() {
  late NetworkConnectivityService connectivityService;

  setUp(() {
    if (sl.isRegistered<NetworkConnectivityService>()) {
      sl.unregister<NetworkConnectivityService>();
    }
    connectivityService = NetworkConnectivityService();
    sl.registerSingleton<NetworkConnectivityService>(connectivityService);
  });

  tearDown(() {
    if (sl.isRegistered<NetworkConnectivityService>()) {
      sl.unregister<NetworkConnectivityService>();
    }
  });

  final workspace = Workspace({
    'actor': {
      'id': 'user-1',
      'employeeId': 'EMP-001',
      'name': 'Malik Ibrahim',
      'email': 'malik@example.test',
    },
    'employee': {
      'id': 'EMP-001',
      'department': 'General Affair',
      'position': 'Staff GA',
      'phone': '0812345678',
    },
    'attendance': [],
    'employees': [],
    'requests': [],
  });

  group('Avatar Network Status Dot Only Tests', () {
    testWidgets('DashboardAvatar renders green dot when online and red dot when offline', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => const MaterialApp(
            home: Scaffold(
              body: DashboardAvatar(name: 'Malik Ibrahim', isOnline: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final greenDot = tester.widget<Container>(find.byKey(const Key('dashboard_avatar_online_dot')));
      expect((greenDot.decoration as BoxDecoration).color, const Color(0xFF00AA13));

      // Re-pump with offline
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => const MaterialApp(
            home: Scaffold(
              body: DashboardAvatar(name: 'Malik Ibrahim', isOnline: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final redDot = tester.widget<Container>(find.byKey(const Key('dashboard_avatar_online_dot')));
      expect((redDot.decoration as BoxDecoration).color, const Color(0xFFEF4444));
    });

    testWidgets('ProfileAvatar renders green dot when online and red dot when offline', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => const MaterialApp(
            home: Scaffold(
              body: ProfileAvatar(initials: 'MI', isOnline: true),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final greenDot = tester.widget<Container>(find.byKey(const Key('profile_avatar_online_dot')));
      expect((greenDot.decoration as BoxDecoration).color, const Color(0xFF00AA13));

      // Re-pump with offline
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => const MaterialApp(
            home: Scaffold(
              body: ProfileAvatar(initials: 'MI', isOnline: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final redDot = tester.widget<Container>(find.byKey(const Key('profile_avatar_online_dot')));
      expect((redDot.decoration as BoxDecoration).color, const Color(0xFFEF4444));
    });

    testWidgets('DashboardTab updates dot to red on offline without extra tags or banners', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.setOnline(true);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: DashboardTab(
              api: ApiClient(),
              workspace: workspace,
              onRefresh: () async {},
              open: (w) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Online initially: dot is green
      final greenDot = tester.widget<Container>(find.byKey(const Key('dashboard_avatar_online_dot')));
      expect((greenDot.decoration as BoxDecoration).color, const Color(0xFF00AA13));
      expect(find.byKey(const Key('dashboard_header_offline_badge')), findsNothing);
      expect(find.text('Mode Offline • Koneksi Internet Mati'), findsNothing);

      // Now set offline:
      connectivityService.setOnline(false);
      await tester.pumpAndSettle();

      // Offline state: dot is red, NO extra badge tags or banners anywhere
      final redDot = tester.widget<Container>(find.byKey(const Key('dashboard_avatar_online_dot')));
      expect((redDot.decoration as BoxDecoration).color, const Color(0xFFEF4444));
      expect(find.byKey(const Key('dashboard_header_offline_badge')), findsNothing);
      expect(find.text('Mode Offline • Koneksi Internet Mati'), findsNothing);

      // Tapping avatar triggers SnackBar with offline info
      await tester.tap(find.byKey(const Key('dashboard_avatar_online_dot')));
      await tester.pumpAndSettle();
      expect(find.text('Koneksi internet mati. Anda sedang dalam mode offline.'), findsOneWidget);
    });

    testWidgets('ProfileTab updates dot to red on offline without extra tags or banners', (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      connectivityService.setOnline(true);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: ProfileTab(
              api: ApiClient(),
              workspace: workspace,
              onRefresh: () async {},
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Online initially: dot is green
      final greenDot = tester.widget<Container>(find.byKey(const Key('profile_avatar_online_dot')));
      expect((greenDot.decoration as BoxDecoration).color, const Color(0xFF00AA13));
      expect(find.byKey(const Key('profile_header_offline_badge')), findsNothing);
      expect(find.text('Mode Offline • Koneksi Internet Mati'), findsNothing);

      // Now set offline:
      connectivityService.setOnline(false);
      await tester.pumpAndSettle();

      // Offline state: dot is red, NO extra badge tags or banners
      final redDot = tester.widget<Container>(find.byKey(const Key('profile_avatar_online_dot')));
      expect((redDot.decoration as BoxDecoration).color, const Color(0xFFEF4444));
      expect(find.byKey(const Key('profile_header_offline_badge')), findsNothing);
      expect(find.text('Mode Offline • Koneksi Internet Mati'), findsNothing);

      // Tapping avatar triggers SnackBar with offline info
      await tester.tap(find.byKey(const Key('profile_avatar_online_dot')));
      await tester.pumpAndSettle();
      expect(find.text('Koneksi internet mati. Anda sedang dalam mode offline.'), findsOneWidget);
    });
  });
}
