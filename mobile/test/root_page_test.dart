import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/root/presentation/pages/root_page.dart';

void main() {
  group('RootPage 4-Tab Navigation Tests', () {
    testWidgets('renders exactly 4 navigation tabs (Beranda, Layanan, Persetujuan, Profil)', (
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
      expect(find.text('Layanan'), findsWidgets);
      expect(find.text('Persetujuan'), findsWidgets);
      expect(find.text('Profil'), findsWidgets);
      // 'Slip gaji' should no longer be a bottom navigation tab
      expect(find.text('Slip gaji'), findsNothing);
    });
  });
}
