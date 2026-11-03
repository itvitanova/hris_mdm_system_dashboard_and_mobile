import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/payroll/presentation/pages/payslip_page.dart';
import 'package:mdm_hris/features/root/presentation/widgets/payroll_tab.dart';

void main() {
  Widget wrapWithScreenUtil(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        home: child,
      ),
    );
  }

  group('PayrollTab & PayslipScreen Tests', () {
    testWidgets('renders PayrollTab header, hero banner, and payslip card, and opens PayslipScreen on tap', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final workspace = Workspace({
        'payroll': [
          {
            'id': 'PAY-1',
            'employeeId': 'EMP-01',
            'employeeName': 'Budi Santoso',
            'companyName': 'PT MDM Human Resource',
            'department': 'Teknologi Informasi',
            'period': 'Oktober 2026',
            'status': 'Final',
            'version': 2,
            'baseSalary': 10000000,
            'allowance': 2000000,
            'overtime': 500000,
            'bonus': 1000000,
            'grossSalary': 13500000,
            'pph21': 450000,
            'taxReady': true,
            'bpjsHealth': 100000,
            'jht': 200000,
            'jp': 100000,
            'deductions': 850000,
            'netSalary': 12650000,
            'ptkp': 'K/1',
          },
        ],
        'employees': [
          {'id': 'EMP-01', 'name': 'Budi Santoso'},
        ],
        'actor': {'employeeId': 'EMP-01', 'name': 'Budi Santoso'},
      });

      Widget? openedScreen;

      await tester.pumpWidget(
        wrapWithScreenUtil(
          PayrollTab(
            api: ApiClient(),
            workspace: workspace,
            onRefresh: () async {},
            open: (screen) async => openedScreen = screen,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify AppBar
      expect(find.text('Slip Gaji'), findsOneWidget);
      expect(find.text('Rincian & Riwayat Pembayaran Gaji'), findsOneWidget);

      // 2. Verify Hero Banner with latest period and net salary
      expect(find.textContaining('Periode Terkini: Oktober 2026'), findsOneWidget);
      expect(find.text('Riwayat Pembayaran'), findsOneWidget);
      expect(find.text('1 Periode'), findsOneWidget);

      // 3. Verify Payslip Card
      expect(find.text('Oktober 2026'), findsWidgets);
      expect(find.text('Final'), findsOneWidget);
      expect(find.text('Gaji Bersih (Take Home Pay)'), findsOneWidget);
      expect(find.text('Rincian'), findsOneWidget);

      // 4. Tap Card -> opens PayslipScreen
      await tester.tap(find.text('Rincian'));
      await tester.pumpAndSettle();

      expect(openedScreen, isA<PayslipScreen>());
    });

    testWidgets('Period filter bar allows switching between periods', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final workspace = Workspace({
        'payroll': [
          {
            'id': 'PAY-1',
            'employeeId': 'EMP-01',
            'employeeName': 'Budi Santoso',
            'companyName': 'PT MDM Human Resource',
            'period': '2026-10',
            'status': 'Final',
            'version': 2,
            'baseSalary': 10000000,
            'deductions': 500000,
            'netSalary': 9500000,
          },
          {
            'id': 'PAY-2',
            'employeeId': 'EMP-01',
            'employeeName': 'Budi Santoso',
            'companyName': 'PT MDM Human Resource',
            'period': '2026-09',
            'status': 'Final',
            'version': 2,
            'baseSalary': 9000000,
            'deductions': 400000,
            'netSalary': 8600000,
          },
        ],
        'employees': [
          {'id': 'EMP-01', 'name': 'Budi Santoso'},
        ],
        'actor': {'employeeId': 'EMP-01', 'name': 'Budi Santoso'},
      });

      await tester.pumpWidget(
        wrapWithScreenUtil(
          PayrollTab(
            api: ApiClient(),
            workspace: workspace,
            onRefresh: () async {},
            open: (_) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Filter chips should exist
      expect(find.byKey(const ValueKey('payroll_period_filter_Semua Periode')), findsOneWidget);
      expect(find.byKey(const ValueKey('payroll_period_filter_2026-10')), findsOneWidget);
      expect(find.byKey(const ValueKey('payroll_period_filter_2026-09')), findsOneWidget);

      // Both cards visible in 'Semua Periode'
      expect(find.text('2026-10'), findsWidgets);
      expect(find.text('2026-09'), findsWidgets);
      expect(find.text('2 Periode'), findsOneWidget);

      // Tap '2026-09' filter chip
      await tester.tap(find.byKey(const ValueKey('payroll_period_filter_2026-09')));
      await tester.pumpAndSettle();

      // Only 2026-09 card is visible
      expect(find.text('1 Periode'), findsOneWidget);
      expect(find.text('Filter: 2026-09'), findsOneWidget);

      // Tap 'Semua Periode'
      await tester.tap(find.byKey(const ValueKey('payroll_period_filter_Semua Periode')));
      await tester.pumpAndSettle();

      expect(find.text('2 Periode'), findsOneWidget);
    });

    testWidgets('renders empty state when there are no payroll records', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final workspace = Workspace({
        'payroll': [],
        'employees': [],
      });

      await tester.pumpWidget(
        wrapWithScreenUtil(
          PayrollTab(
            api: ApiClient(),
            workspace: workspace,
            onRefresh: () async {},
            open: (_) async {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Slip Gaji Belum Tersedia'), findsOneWidget);
      expect(find.text('Muat Ulang Data'), findsOneWidget);
    });

    testWidgets('PayslipScreen renders detailed earnings, deductions, and meta info', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final slipData = <String, dynamic>{
        'id': 'PAY-1',
        'employeeId': 'EMP-01',
        'employeeName': 'Budi Santoso',
        'companyName': 'PT MDM Human Resource',
        'companyAddress': 'Gedung Wisma MDM, Lt. 5, Jakarta Selatan',
        'department': 'Engineering',
        'period': 'Oktober 2026',
        'status': 'Final',
        'version': 2,
        'baseSalary': 10000000,
        'allowance': 2000000,
        'overtime': 500000,
        'bonus': 0,
        'grossSalary': 12500000,
        'pph21': 350000,
        'taxReady': true,
        'bpjsHealth': 100000,
        'jht': 200000,
        'jp': 100000,
        'deductions': 750000,
        'netSalary': 11750000,
        'ptkp': 'TK/0',
      };

      await tester.pumpWidget(
        wrapWithScreenUtil(
          PayslipScreen(
            api: ApiClient(),
            slip: slipData,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Rincian Slip Gaji'), findsOneWidget);
      expect(find.text('Oktober 2026 • Budi Santoso'), findsOneWidget);

      // Verify Hero card
      expect(find.text('GAJI BERSIH (TAKE HOME PAY)'), findsOneWidget);
      expect(find.textContaining('Pembayaran final telah diverifikasi'), findsOneWidget);

      // Verify Meta Card
      expect(find.text('PT MDM Human Resource'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsWidgets);
      expect(find.text('Engineering'), findsOneWidget);
      expect(find.text('TK/0'), findsOneWidget);

      // Verify Earnings
      expect(find.text('Komponen Pendapatan'), findsOneWidget);
      expect(find.text('Total Pendapatan Kotor'), findsOneWidget);

      // Verify Deductions
      expect(find.text('Komponen Potongan'), findsOneWidget);
      expect(find.text('Total Potongan'), findsOneWidget);

      // Verify Action Button
      expect(find.byKey(const Key('payslip_share_btn')), findsOneWidget);
      expect(find.text('Unduh / Bagikan Slip Gaji (PDF)'), findsOneWidget);
    });
  });
}
