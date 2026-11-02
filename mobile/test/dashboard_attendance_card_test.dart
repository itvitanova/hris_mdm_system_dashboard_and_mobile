import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
