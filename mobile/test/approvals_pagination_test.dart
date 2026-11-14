import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_detail_page.dart';
import 'package:mdm_hris/core/api_client.dart';

class MockTestApiClient extends ApiClient {
  MockTestApiClient() : super();

  @override
  Future<Map<String, dynamic>> workspace() async {
    // Generate 25 mock requests for testing 10 items per page pagination
    final requests = List.generate(25, (i) => {
      'id': 'req-$i',
      'title': 'Pengajuan Cuti #$i',
      'kind': 'Cuti / Izin',
      'employeeId': 'emp-$i',
      'employeeName': 'Employee $i',
      'canReview': true,
      'status': 'menunggu',
      'createdAt': '2026-11-13T08:00:00Z',
    });

    return {
      'approvalAccess': true,
      'actor': {'employeeId': 'current-user'},
      'requests': requests,
    };
  }
}

void main() {
  testWidgets('ApprovalsScreen displays 10 items per page and renders pagination bar', (tester) async {
    final mockApi = MockTestApiClient();

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (context, _) => MaterialApp(
          home: ApprovalsScreen(api: mockApi),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Scroll down to pagination bar in ListView
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('pagination_bar')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Verify pagination bar is present
    expect(find.byKey(const ValueKey('pagination_bar')), findsOneWidget);

    // Verify info text indicates 10 items per page (Showing 1-10 of 25)
    expect(find.text('Halaman 1 dari 3'), findsOneWidget);
    expect(find.text('Menampilkan 1\u201310 dari 25 pengajuan'), findsOneWidget);

    // Verify prev button is present
    expect(find.byKey(const ValueKey('pagination_prev_btn')), findsOneWidget);

    // Tap page 2
    await tester.tap(find.text('2'));
    await tester.pumpAndSettle();

    // Because auto-scroll scrolled back to top, scroll down again to verify pagination bar on page 2
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('pagination_bar')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    // Verify page 2 shows items 11-20
    expect(find.text('Halaman 2 dari 3'), findsOneWidget);
    expect(find.text('Menampilkan 11\u201320 dari 25 pengajuan'), findsOneWidget);
  });
}
