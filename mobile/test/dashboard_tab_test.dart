import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/root/presentation/widgets/dashboard_tab.dart';

void main() {
  testWidgets(
    'DashboardTab switches all dashboard texts dynamically between ID and EN',
    (tester) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final workspace = Workspace({
        'actor': {
          'id': 'user-1',
          'employeeId': 'EMP-001',
          'name': 'Malik Ibrahim',
        },
        'employee': {
          'position': 'Staff GA',
          'department': 'General Affair',
        },
        'attendance': [],
        'employees': [],
        'requests': [],
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
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

      // 1. Initial State (ID):
      expect(find.text('Selamat Datang 👋'), findsOneWidget);
      expect(find.text('Absensi Masuk'), findsOneWidget);
      expect(find.text('Sudah Absen'), findsOneWidget);
      expect(find.text('Tepat Waktu'), findsOneWidget);
      expect(find.text('Terlambat'), findsOneWidget);
      expect(find.text('Belum Absen'), findsOneWidget);
      expect(find.text('Aktivitas Anda'), findsOneWidget);
      expect(find.text('Lihat semua'), findsOneWidget);
      expect(find.text('Belum ada catatan kehadiran.'), findsOneWidget);

      // 2. Tap Language Swap Button and select English (ENG)
      await tester.tap(find.byKey(const Key('dashboard_language_swap_button')));
      await tester.pumpAndSettle();

      expect(find.text('ENG'), findsWidgets);
      await tester.tap(find.text('ENG').last);
      await tester.pumpAndSettle();

      // 3. Verifikasi State switched to EN:
      expect(find.text('Welcome 👋'), findsOneWidget);
      expect(find.text('Check In'), findsNWidgets(2)); // Tile header + Action button
      expect(find.text('Checked In'), findsOneWidget);
      expect(find.text('On Time'), findsOneWidget);
      expect(find.text('Late'), findsOneWidget);
      expect(find.text('Absent'), findsOneWidget);
      expect(find.text('Your activity'), findsOneWidget);
      expect(find.text('View all'), findsOneWidget);
      expect(find.text('No attendance records yet.'), findsOneWidget);
    },
  );
}
