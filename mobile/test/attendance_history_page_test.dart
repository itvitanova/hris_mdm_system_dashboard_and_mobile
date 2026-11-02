import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/attendance/presentation/pages/attendance_history_page.dart';

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
      expect(find.text('1'), findsNWidgets(2)); // 1 Tepat Waktu, 1 Terlambat
      expect(find.text('0'), findsOneWidget); // 0 Belum Absen

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
      await tester.tap(find.text('Masuk').first);
      await tester.pumpAndSettle();

      // Verify Detail Modal
      expect(find.text('Detail Kehadiran'), findsOneWidget);
      expect(find.text('JAM MASUK'), findsOneWidget);
      expect(find.text('JAM PULANG'), findsOneWidget);
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
  });
}
