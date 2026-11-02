import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/attendance_detail_modal.dart';
import 'package:mdm_hris/features/root/presentation/widgets/dashboard_attendance_card.dart';

void main() {
  test(
    'fromAttendanceList only sets isToday true on the first (topmost) item',
    () {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final list = [
        {
          'date': todayStr,
          'checkIn': '${todayStr}T09:00:00+07:00',
          'checkOut': '${todayStr}T17:00:00+07:00',
          'status': 'Hadir',
        },
      ];

      final items = DashboardAttendanceItem.fromAttendanceList(list, limit: 2);
      expect(items.length, 2);
      // Topmost item (Pulang) should be highlighted (isToday = true)
      expect(items[0].isToday, isTrue);
      expect(items[0].type, DashboardAttendanceType.pulang);

      // Second item (Masuk) should NOT be highlighted (isToday = false)
      expect(items[1].isToday, isFalse);
      expect(items[1].type, DashboardAttendanceType.masuk);
    },
  );

  testWidgets(
    'DashboardAttendanceCard renders gradient for topmost and white for second',
    (tester) async {
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final list = [
        {
          'date': todayStr,
          'checkIn': '${todayStr}T09:00:00+07:00',
          'checkOut': '${todayStr}T17:00:00+07:00',
          'status': 'Hadir',
        },
      ];

      final items = DashboardAttendanceItem.fromAttendanceList(list, limit: 2);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  DashboardAttendanceCard(item: items[0]),
                  DashboardAttendanceCard(item: items[1]),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration)
          .toList();

      // Top card has LinearGradient
      final topCardBox = containers.firstWhere(
        (c) => (c.decoration as BoxDecoration).gradient != null,
      );
      expect(
        (topCardBox.decoration as BoxDecoration).gradient,
        isA<LinearGradient>(),
      );

      // Second card does NOT have LinearGradient (is plain white card)
      final secondCardBox = containers.firstWhere(
        (c) =>
            (c.decoration as BoxDecoration).color == const Color(0xFFFFFFFF),
      );
      expect((secondCardBox.decoration as BoxDecoration).gradient, isNull);
    },
  );

  testWidgets(
    'DashboardAttendanceCard triggers onTap callback when tapped',
    (tester) async {
      bool tapped = false;
      const item = DashboardAttendanceItem(
        type: DashboardAttendanceType.masuk,
        title: 'Masuk',
        statusText: 'Tepat Waktu',
        isLate: false,
        dateText: '2 Nov 2026',
        timeText: '08:24 am',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: DashboardAttendanceCard(
                item: item,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    },
  );

  testWidgets(
    'showAttendanceDetailModal renders detail modal sheet with check-in info',
    (tester) async {
      final raw = {
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
      };

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, _) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () => showAttendanceDetailModal(ctx, raw),
                  child: const Text('Open Detail'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Detail'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Kehadiran'), findsOneWidget);
      expect(find.text('JAM MASUK'), findsOneWidget);
      expect(find.text('JAM PULANG'), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);
    },
  );
}