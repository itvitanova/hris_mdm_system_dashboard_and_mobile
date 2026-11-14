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
      'requests': [
        {
          'id': 'req-1',
          'type': 'leave',
          'unread': true,
        },
      ],
    });

    testWidgets('renders Header Card, 2x2 Info Grid, and Account Settings', (
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

      // Profile Header Card
      expect(find.text('Selamat Datang 👋'), findsOneWidget);
      expect(find.text('Nadia Putri'), findsOneWidget);
      expect(find.text('nadia@example.test'), findsOneWidget);
      expect(find.text('NP'), findsOneWidget);

      // 2x2 Grid Info Cards
      expect(find.text('ID Karyawan'), findsOneWidget);
      expect(find.text('EMP-002'), findsOneWidget);
      expect(find.text('Departemen'), findsOneWidget);
      expect(find.text('Product & Design'), findsOneWidget);
      expect(find.text('Jabatan'), findsOneWidget);
      expect(find.text('Product Designer'), findsOneWidget);
      expect(find.text('Nomor Telepon'), findsOneWidget);
      expect(find.text('081234567890'), findsOneWidget);

      // Account Settings Section
      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(find.text('Detail Data & Kepegawaian'), findsOneWidget);
      expect(find.text('Keluar Akun'), findsOneWidget);

      // Tap Detail Data & Kepegawaian to verify bottom sheet
      await tester.tap(find.text('Detail Data & Kepegawaian'));
      await tester.pumpAndSettle();

      expect(find.text('Informasi Lengkap Karyawan'), findsOneWidget);
      expect(find.text('3171012345670001'), findsOneWidget);
      expect(find.text('BCA'), findsOneWidget);
      expect(find.text('5410987654'), findsOneWidget);
      expect(find.text('Terdaftar'), findsOneWidget);

      // Close bottom sheet
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();

      expect(find.text('Informasi Lengkap Karyawan'), findsNothing);
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

      // Scroll until Keluar Akun is visible
      await tester.scrollUntilVisible(find.text('Keluar Akun'), 50);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keluar Akun'));
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Keluar dari Akun?'), findsOneWidget);
      expect(
        find.text('Apakah Anda yakin ingin mengakhiri sesi ini?'),
        findsOneWidget,
      );
      expect(
        find.text('Data sesi dan absensi Anda akan tetap aman.'),
        findsOneWidget,
      );
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Ya, Keluar Akun'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Batal'), findsNothing);
    });
  });
}
