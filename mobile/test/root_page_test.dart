import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/root/presentation/pages/root_page.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

void main() {
  setUp(() {
    AppLanguageController.reset();
  });

  tearDown(() {
    AppLanguageController.reset();
  });

  group('RootPage 5-Tab Navigation Tests', () {
    testWidgets('renders exactly 5 navigation tabs (Beranda, Pengajuan, Persetujuan, Slip gaji, Profil)', (
      tester,
    ) async {
      final workspace = Workspace({
        'requests': [],
        'employees': [],
        'attendance': [],
        'payroll': [],
        'settings': {},
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            home: RootPage(
              api: ApiClient(),
              workspace: workspace,
              onRefresh: () async {},
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Beranda'), findsWidgets);
      expect(find.text('Pengajuan'), findsWidgets);
      expect(find.text('Persetujuan'), findsWidgets);
      expect(find.text('Slip gaji'), findsWidgets);
      expect(find.text('Profil'), findsWidgets);
    });

    testWidgets('changing language in DashboardTab updates other modules (tabs and screens) to English', (
      tester,
    ) async {
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
        'requests': [],
        'employees': [],
        'attendance': [],
        'payroll': [],
        'settings': {},
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            home: RootPage(
              api: ApiClient(),
              workspace: workspace,
              onRefresh: () async {},
              onLogout: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. LanguageSwapButton is present in Dashboard
      expect(find.byKey(const Key('dashboard_language_swap_button')), findsOneWidget);
      expect(find.text('Selamat Datang 👋'), findsOneWidget);
      expect(find.text('Beranda'), findsWidgets);
      expect(find.text('Pengajuan'), findsWidgets);

      // 2. Switch language to ENG in Dashboard
      await tester.tap(find.byKey(const Key('dashboard_language_swap_button')));
      await tester.pumpAndSettle();

      expect(find.text('ENG'), findsWidgets);
      await tester.tap(find.text('ENG').last);
      await tester.pumpAndSettle();

      // 3. Dashboard immediately reflects English
      expect(find.text('Welcome 👋'), findsOneWidget);

      // 4. Bottom nav tabs immediately reflect English
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Requests'), findsWidgets);

      // 5. Navigate to RequestsTab (tab index 1)
      await tester.tap(find.text('Requests').first);
      await tester.pumpAndSettle();

      // 6. Requests tab is in English, and does NOT have LanguageSwapButton
      expect(find.text('Submissions'), findsOneWidget);
      expect(find.text('Self-Service & Employee Requests'), findsOneWidget);
      expect(find.text('Self-Service Hub'), findsOneWidget);
      expect(find.text('Approval Center'), findsOneWidget);
      expect(find.text('Submission Catalog'), findsOneWidget);
      expect(find.text('Leave'), findsOneWidget);
      expect(find.byKey(const Key('dashboard_language_swap_button')), findsNothing);
    });
  });
}
