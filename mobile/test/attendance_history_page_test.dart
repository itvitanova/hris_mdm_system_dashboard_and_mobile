import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/attendance/presentation/pages/attendance_history_page.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/attendance_daily_card.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/attendance_stat_card.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

void main() {
  setUp(() {
    AppLanguageController.reset();
  });

  tearDown(() {
    AppLanguageController.reset();
  });

  Widget wrapWithScreenUtil(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        home: child,
      ),
    );
  }

  group('AttendanceHistoryPage Tests', () {
    final workspace = Workspace({
      'actor': {
        'id': 'user-1',
        'employeeId': 'EMP-001',
        'name': 'Malik Ibrahim',
        'email': 'malik@mdm.local',
      },
      'settings': {
        'company': 'MDM Indonesia',
        'locationName': 'Kantor Pusat MDM Jakarta',
        'latitude': -6.137607,
        'longitude': 106.799707,
      },
      'attendancePolicy': {
        'name': 'Kantor Pusat MDM Jakarta',
        'latitude': -6.137607,
        'longitude': 106.799707,
        'allowAnyLocation': false,
      },
      'attendance': [
        {
          'id': 'att-1',
          'employeeId': 'EMP-001',
          'employeeName': 'Malik Ibrahim',
          'date': '2026-11-02',
          'checkIn': '2026-11-02T08:24:00+07:00',
          'checkOut': '2026-11-02T17:30:00+07:00',
          'status': 'Hadir',
          'lateMinutes': 0,
          'earlyDeparture': false,
          'distance': 15.0,
          'faceVerified': true,
          'checkInLocation': {
            'latitude': -6.137607,
            'longitude': 106.799707,
            'policy': {'name': 'Kantor Pusat MDM Jakarta'},
          },
          'checkOutLocation': {
            'latitude': -6.137607,
            'longitude': 106.799707,
            'policy': {'name': 'Kantor Pusat MDM Jakarta'},
          },
        },
        {
          'id': 'att-2',
          'employeeId': 'EMP-001',
          'employeeName': 'Malik Ibrahim',
          'date': '2026-11-01',
          'checkIn': '2026-11-01T09:15:00+07:00',
          'checkOut': '2026-11-01T18:00:00+07:00',
          'status': 'Terlambat',
          'lateMinutes': 15,
          'earlyDeparture': false,
          'distance': 20.0,
          'faceVerified': true,
          'checkInLocation': {
            'latitude': -6.137607,
            'longitude': 106.799707,
            'policy': {'name': 'Kantor Pusat MDM Jakarta'},
          },
        },
      ],
      'employees': [],
      'requests': [],
    });

    testWidgets('renders Header, Location Banner, 4 Stat Cards, Filter Toolbar, and List', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithScreenUtil(
          AttendanceHistoryPage(
            api: ApiClient(),
            workspace: workspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify AppBar
      expect(find.text('Riwayat Kehadiran'), findsOneWidget);
      expect(find.text('Presensi & Verifikasi Lokasi'), findsOneWidget);

      // 2. Verify Location Banner (Web MDM alignment)
      expect(find.text('Kantor Pusat MDM Jakarta'), findsWidgets);
      expect(find.text('Lokasi & Wajah'), findsOneWidget);

      // 3. Verify Stat Cards (Sudah Absen, Tepat Waktu, Terlambat, Belum Absen)
      expect(find.text('SUDAH ABSEN'), findsOneWidget);
      expect(find.text('TEPAT WAKTU'), findsOneWidget);
      expect(find.text('TERLAMBAT'), findsOneWidget);
      expect(find.text('BELUM ABSEN'), findsOneWidget);

      // Verify Stat Counts
      expect(find.text('2'), findsOneWidget); // 2 Sudah Absen
      expect(
        find.descendant(
          of: find.byType(AttendanceStatCard),
          matching: find.text('1'),
        ),
        findsNWidgets(2),
      ); // 1 Tepat Waktu, 1 Terlambat
      expect(find.text('0'), findsOneWidget); // 0 Belum Absen

      // Verify Pagination Bar is displayed even with 2 attendance entries (2 items, < 5)
      expect(find.byKey(const ValueKey('pagination_bar')), findsOneWidget);
      expect(find.text('Halaman 1 dari 1'), findsOneWidget);
      expect(find.text('Menampilkan 1\u20132 dari 2 catatan kehadiran'), findsOneWidget);

      // 4. Verify Filter Toolbar
      expect(find.text('Semua Bulan'), findsOneWidget);
      expect(find.text('2026'), findsWidgets);
      expect(find.text('Semua Kehadiran'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);

      // 5. Tap on Stat Card (TERLAMBAT) to filter
      await tester.tap(find.text('TERLAMBAT').first);
      await tester.pumpAndSettle();

      // Subtitle reflects the filter
      expect(find.textContaining('TERLAMBAT'), findsWidgets);

      // Tap Reset button
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // After reset, Status dropdown goes back to 'Semua Kehadiran'
      expect(find.text('Semua Kehadiran'), findsOneWidget);
      expect(find.textContaining('Riwayat Absensi 2026'), findsOneWidget);

      // 6. Tap on an Attendance Card to open Detail Modal
      await tester.tap(find.byType(AttendanceDailyCard).first);
      await tester.pumpAndSettle();

      // Verify Detail Modal
      expect(find.text('Detail Kehadiran'), findsOneWidget);
      expect(find.text('JAM MASUK'), findsWidgets);
      expect(find.text('JAM PULANG'), findsWidgets);
      expect(find.text('Peta Masuk'), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Kehadiran'), findsNothing);
    });

    testWidgets('Filter dropdowns interaction: Month, Status, and Reset', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithScreenUtil(
          AttendanceHistoryPage(
            api: ApiClient(),
            workspace: workspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open Month dropdown
      await tester.tap(find.text('Semua Bulan'));
      await tester.pumpAndSettle();

      // Month grid should appear
      expect(find.text('Nov'), findsOneWidget);
      expect(find.text('Des'), findsOneWidget);

      // Select 'Nov'
      await tester.tap(find.text('Nov'));
      await tester.pumpAndSettle();

      // Trigger should now show 'November'
      expect(find.text('November'), findsWidgets);
      expect(find.textContaining('November'), findsWidgets);

      // Open Status dropdown
      await tester.tap(find.text('Semua Kehadiran'));
      await tester.pumpAndSettle();

      // Select 'SUDAH ABSEN' in the status grid
      await tester.tap(find.text('SUDAH ABSEN').last);
      await tester.pumpAndSettle();

      // Trigger should now show 'SUDAH ABSEN'
      expect(find.textContaining('Riwayat Absensi - SUDAH ABSEN - November 2026'), findsOneWidget);

      // Tap Reset button
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Should be reset
      expect(find.text('Semua Bulan'), findsOneWidget);
      expect(find.text('Semua Kehadiran'), findsOneWidget);
      expect(find.textContaining('Riwayat Absensi 2026'), findsOneWidget);
    });

    testWidgets('filtering by month and status updates stat cards and attendance cards correctly', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithScreenUtil(
          AttendanceHistoryPage(
            api: ApiClient(),
            workspace: workspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial stats for 2026: 2 Sudah Absen, 1 Tepat Waktu, 1 Terlambat, 0 Belum Absen
      expect(
        find.descendant(
          of: find.byType(AttendanceStatCard),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );

      // 1. Select Month 'Okt' (has 0 records)
      await tester.tap(find.text('Semua Bulan'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Okt'));
      await tester.pumpAndSettle();

      // Stat cards must update to 0
      expect(
        find.descendant(
          of: find.byType(AttendanceStatCard),
          matching: find.text('0'),
        ),
        findsNWidgets(4),
      );
      expect(find.text('Belum Ada Catatan Kehadiran'), findsOneWidget);

      // 2. Select Month 'Nov' (has 2 records: 1 on-time, 1 late)
      await tester.tap(find.text('Oktober'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Nov'));
      await tester.pumpAndSettle();

      // Stat cards must update to November counts: 2 Sudah Absen, 1 Tepat Waktu, 1 Terlambat, 0 Belum Absen
      expect(
        find.descendant(
          of: find.byType(AttendanceStatCard),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AttendanceStatCard),
          matching: find.text('1'),
        ),
        findsNWidgets(2),
      );
      expect(
        find.descendant(
          of: find.byType(AttendanceStatCard),
          matching: find.text('0'),
        ),
        findsOneWidget,
      );

      // 3. Select Status 'TERLAMBAT' (Stat card tap)
      await tester.tap(find.text('TERLAMBAT').first);
      await tester.pumpAndSettle();

      // Only the late card should be shown, no on-time check-in card
      expect(find.textContaining('Telat'), findsWidgets);
      expect(find.textContaining('Tepat'), findsNothing);
      expect(find.text('Menampilkan 1\u20131 dari 1 catatan kehadiran'), findsOneWidget);

      // 4. Select Status 'TEPAT WAKTU' (Stat card tap)
      await tester.tap(find.text('TEPAT WAKTU').first);
      await tester.pumpAndSettle();

      // Only the on-time check-in card should be shown, no late card
      expect(find.textContaining('Tepat'), findsWidgets);
      expect(find.textContaining('Telat'), findsNothing);
      expect(find.text('Menampilkan 1\u20131 dari 1 catatan kehadiran'), findsOneWidget);

      // 5. Select Status 'SUDAH ABSEN' (Stat card tap)
      await tester.tap(find.text('SUDAH ABSEN').first);
      await tester.pumpAndSettle();

      // Exactly 2 cards representing the 2 attended dates (1 Tepat + 1 Telat)
      expect(find.text('Menampilkan 1\u20132 dari 2 catatan kehadiran'), findsOneWidget);
      expect(find.textContaining('Tepat'), findsWidgets);
      expect(find.textContaining('Telat'), findsWidgets);

      // 6. Reset
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      // Returns to all 2 cards
      expect(find.text('Menampilkan 1\u20132 dari 2 catatan kehadiran'), findsOneWidget);
    });

    testWidgets('Empty state displays clean info without Absen Sekarang button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithScreenUtil(
          AttendanceHistoryPage(
            api: ApiClient(),
            workspace: workspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on 'BELUM ABSEN' (count 0) to trigger empty state
      await tester.tap(find.text('BELUM ABSEN').first);
      await tester.pumpAndSettle();

      // Verify Empty State is shown
      expect(find.text('Belum Ada Catatan Kehadiran'), findsOneWidget);
      expect(
        find.text(
          'Catatan kehadiran akan otomatis tercatat setelah melakukan absensi masuk atau pulang.',
        ),
        findsOneWidget,
      );

      // Verify 'Absen Sekarang' button is NOT present
      expect(find.text('Absen Sekarang'), findsNothing);
    });

    testWidgets('paginates attendance history at 5 items per page and navigates pages', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final attendanceList = List.generate(
        7,
        (i) => {
          'id': 'att-page-$i',
          'employeeId': 'EMP-001',
          'employeeName': 'Malik Ibrahim',
          'date': '2026-11-0${i + 1}',
          'checkIn': '2026-11-0${i + 1}T08:24:00+07:00',
          'status': 'Hadir',
          'lateMinutes': 0,
          'earlyDeparture': false,
          'distance': 15.0,
          'faceVerified': true,
        },
      );

      final pagedWorkspace = Workspace({
        'actor': {
          'id': 'user-1',
          'employeeId': 'EMP-001',
          'name': 'Malik Ibrahim',
        },
        'attendance': attendanceList,
        'employees': [],
        'requests': [],
      });

      await tester.pumpWidget(
        wrapWithScreenUtil(
          AttendanceHistoryPage(
            api: ApiClient(),
            workspace: pagedWorkspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Scroll to bottom so pagination bar and buttons are fully visible
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('pagination_bar')), findsOneWidget);
      expect(find.text('Halaman 1 dari 2'), findsOneWidget);
      expect(find.text('Menampilkan 1\u20135 dari 7 catatan kehadiran'), findsOneWidget);

      // Tap Selanjutnya (>)
      await tester.tap(find.byKey(const ValueKey('pagination_next_btn')));
      await tester.pumpAndSettle();

      // Page 2: shows remaining 2 items
      expect(find.text('Halaman 2 dari 2'), findsOneWidget);
      expect(find.text('Menampilkan 6\u20137 dari 7 catatan kehadiran'), findsOneWidget);

      // Tap Sebelumnya (<)
      await tester.tap(find.byKey(const ValueKey('pagination_prev_btn')));
      await tester.pumpAndSettle();

      // Scroll to pagination bar on page 1
      await tester.drag(find.byType(ListView).first, const Offset(0, -600));
      await tester.pumpAndSettle();

      // Back to Page 1
      expect(find.text('Halaman 1 dari 2'), findsOneWidget);
      expect(find.text('Menampilkan 1\u20135 dari 7 catatan kehadiran'), findsOneWidget);
    });

    testWidgets('renders all UI components in English when initialLanguage is AppLanguage.en', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithScreenUtil(
          AttendanceHistoryPage(
            api: ApiClient(),
            workspace: workspace,
            initialLanguage: AppLanguage.en,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify AppBar English
      expect(find.text('Attendance History'), findsOneWidget);
      expect(find.text('Presence & Location Verification'), findsOneWidget);

      // 2. Verify Location Banner
      expect(find.text('Location & Face'), findsOneWidget);

      // 3. Verify Stat Cards in English
      expect(find.text('CHECKED IN'), findsOneWidget);
      expect(find.text('ON TIME'), findsOneWidget);
      expect(find.text('LATE'), findsOneWidget);
      expect(find.text('ABSENT'), findsOneWidget);

      // 4. Verify Subtitle Banner in English
      expect(find.textContaining('Attendance History 2026'), findsOneWidget);

      // 5. Verify Filter Toolbar in English
      expect(find.text('All Months'), findsOneWidget);
      expect(find.text('All Attendance'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // 6. Verify Attendance Card Labels in English
      expect(find.text('CHECK IN'), findsWidgets);
      expect(find.text('CHECK OUT'), findsWidgets);

      // 7. Verify Pagination Bar in English
      expect(find.byKey(const ValueKey('pagination_bar')), findsOneWidget);
      expect(find.text('Page 1 of 1'), findsOneWidget);
      expect(find.text('Showing 1\u20132 of 2 attendance records'), findsOneWidget);

      // 8. Open Attendance Detail Modal and verify English
      await tester.tap(find.byType(AttendanceDailyCard).first);
      await tester.pumpAndSettle();

      expect(find.text('Attendance Details'), findsOneWidget);
      expect(find.text('CHECK-IN TIME'), findsOneWidget);
      expect(find.text('CHECK-OUT TIME'), findsOneWidget);
      expect(find.text('Check-in Map'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.text('Attendance Details'), findsNothing);
    });

    testWidgets('dynamic language switch via global AppLanguageController toggles EN/ID in AttendanceHistoryPage', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1400 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        wrapWithScreenUtil(
          AttendanceHistoryPage(
            api: ApiClient(),
            workspace: workspace,
            initialLanguage: AppLanguage.id,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially ID
      expect(find.text('Riwayat Kehadiran'), findsOneWidget);
      expect(find.text('SUDAH ABSEN'), findsOneWidget);
      expect(find.text('Semua Bulan'), findsOneWidget);
      expect(find.text('Semua Kehadiran'), findsOneWidget);

      // LanguageSwapButton must NOT exist in AttendanceHistoryPage (only in Dashboard)
      expect(find.byKey(const Key('dashboard_language_swap_button')), findsNothing);

      // Global switch to ENG
      AppLanguageController.setLanguage(AppLanguage.en);
      await tester.pumpAndSettle();

      // Now EN
      expect(find.text('Attendance History'), findsOneWidget);
      expect(find.text('CHECKED IN'), findsOneWidget);
      expect(find.text('All Months'), findsOneWidget);
      expect(find.text('All Attendance'), findsOneWidget);
      expect(find.text('Page 1 of 1'), findsOneWidget);
      expect(find.text('Showing 1\u20132 of 2 attendance records'), findsOneWidget);
    });
  });
}
