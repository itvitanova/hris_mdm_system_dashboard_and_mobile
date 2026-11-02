import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_detail_page.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import 'package:mdm_hris/shared/theme.dart';

class MockApprovalApi extends ApiClient {
  final request = <String, dynamic>{
    'id': 'REQ-APPR-1',
    'employeeId': 'STAFF-123',
    'employeeName': 'Budi Santoso',
    'kind': 'Cuti',
    'title': 'Cuti Tahunan Liburan',
    'description': 'Liburan keluarga akhir tahun',
    'status': 'Menunggu',
    'startDate': '2026-12-20',
    'endDate': '2026-12-24',
    'days': 5,
    'canReview': true,
    'steps': [
      {
        'name': 'Persetujuan Lead',
        'status': 'Menunggu',
        'approvers': [
          {'employeeId': 'LEAD-1', 'name': 'Lead HR'},
        ],
        'decisions': [],
      },
    ],
  };

  @override
  Future<Map<String, dynamic>> workspace() async => {
    'actor': {'employeeId': 'LEAD-1', 'name': 'Lead HR'},
    'employees': [
      {'id': 'LEAD-1', 'name': 'Lead HR'},
      {'id': 'STAFF-123', 'name': 'Budi Santoso'},
    ],
    'requests': [request],
    'approvalAccess': true,
  };
}

void main() {
  testWidgets('ApprovalsScreen displays modern header, segmented tab, and UniversalRequestCard with applicant', (tester) async {
    final api = MockApprovalApi();

    await tester.pumpWidget(
      MaterialApp(
        theme: hrisTheme(),
        home: ApprovalsScreen(api: api),
      ),
    );
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('Persetujuan'), findsOneWidget);
    expect(find.text('Tinjau & Verifikasi Pengajuan Tim'), findsOneWidget);

    // Verify Hero Banner
    expect(find.text('Pusat Persetujuan Tim'), findsOneWidget);
    expect(find.text('Tinjau & Beri Keputusan'), findsOneWidget);

    // Verify Segmented Tab with badge count
    expect(find.textContaining('Menunggu tindakan'), findsOneWidget);
    expect(find.textContaining('Riwayat keputusan'), findsOneWidget);

    // Verify UniversalRequestCard renders the request title and applicant name
    expect(find.text('Cuti Tahunan Liburan'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.byType(UniversalRequestCard), findsOneWidget);

    // Verify Search filter
    await tester.enterText(find.byType(TextField), 'TidakAdaNama');
    await tester.pumpAndSettle();
    expect(find.text('Tidak ada pengajuan yang sesuai.'), findsOneWidget);

    // Clear search
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Cuti Tahunan Liburan'), findsOneWidget);
  });
}
