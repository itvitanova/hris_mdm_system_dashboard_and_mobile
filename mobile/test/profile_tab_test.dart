import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/root/presentation/widgets/profile_tab.dart';

void main() {
  group('ProfileTab Tests', () {
    final workspace = Workspace({
      'actor': {
        'employeeId': 'EMP-002',
        'name': 'Nadia Putri',
        'email': 'nadia@example.test',
      },
      'employees': [
        {
          'id': 'EMP-002',
          'name': 'Nadia Putri',
          'position': 'Product Designer',
          'department': 'Product & Design',
          'employmentType': 'Karyawan Tetap',
          'phone': '081234567890',
          'address': 'Jl. Sudirman No. 45, Jakarta',
          'ptkp': 'TK/0',
          'employeeNumber': '3171012345670001',
          'bankName': 'BCA',
          'bankAccountName': 'Nadia Putri',
          'bankAccountNumber': '5410987654',
          'faceEnrolled': true,
        },
      ],
    });

    testWidgets('renders Hero Header and modular data sections', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
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

      // Hero Header
      expect(find.text('Profil Saya'), findsOneWidget);
      expect(find.text('Nadia Putri'), findsWidgets);
      expect(find.text('nadia@example.test'), findsOneWidget);
      expect(find.text('EMP-002'), findsWidgets);

      // Section Cards
      expect(find.text('Informasi Pekerjaan'), findsOneWidget);
      expect(find.text('Data Pribadi & Kontak'), findsOneWidget);

      // Scroll to view lower sections
      await tester.scrollUntilVisible(find.text('Rekening Payroll'), 50);
      expect(find.text('Rekening Payroll'), findsOneWidget);
      expect(find.text('BCA'), findsOneWidget);
      expect(find.text('5410987654'), findsOneWidget);

      await tester.scrollUntilVisible(find.text('Keamanan & Akun'), 50);
      expect(find.text('Keamanan & Akun'), findsOneWidget);
      expect(find.text('Ganti Password'), findsOneWidget);
    });

    testWidgets('shows confirmation dialog when Keluar Akun is tapped', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 844 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
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

      // Scroll until Keluar Akun is visible, then drag an extra 100px so it's fully on screen
      await tester.scrollUntilVisible(find.text('Keluar Akun'), 50);
      await tester.drag(find.byType(Scrollable), const Offset(0, -120));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar Akun'));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Apakah Anda yakin ingin keluar dari akun ini? Anda harus memasukkan kredensial kembali untuk masuk.'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Ya, Keluar'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Batal'), findsNothing);
    });
  });
}
