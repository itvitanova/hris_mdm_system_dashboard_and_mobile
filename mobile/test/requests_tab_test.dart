import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/request_form.dart';
import 'package:mdm_hris/features/root/presentation/widgets/requests_tab.dart';

void main() {
  group('RequestsTab Unified Single-Page Tests', () {
    testWidgets(
      'renders 5 category tabs and dynamically updates FAB and card list on tab change',
      (tester) async {
        final workspace = Workspace({
          'requests': [],
          'employees': [],
          'attendancePolicy': {},
        });
        Widget? openedWidget;

        await tester.pumpWidget(
          MaterialApp(
            home: RequestsTab(
              api: ApiClient(),
              workspace: workspace,
              onRefresh: () async {},
              open: (w) async => openedWidget = w,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Initial State: Cuti tab is active
        expect(find.text('Cuti & Izin'), findsOneWidget);
        expect(find.text('Ajukan Cuti'), findsOneWidget);
        expect(find.text('Cuti tahunan'), findsOneWidget);
        expect(find.text('Lembur Maintenance & Backup Server'), findsNothing);

        // 2. Tap FAB on Cuti tab -> opens locked RequestForm with kind 'Cuti'
        await tester.tap(find.text('Ajukan Cuti'));
        await tester.pumpAndSettle();
        expect(openedWidget, isA<RequestForm>());
        expect((openedWidget as RequestForm).initialKind, 'Cuti');
        expect((openedWidget as RequestForm).lockKindSelection, isTrue);

        // 3. Switch to Lembur tab
        await tester.tap(find.text('Lembur'));
        await tester.pumpAndSettle();

        expect(find.text('Ajukan Lembur'), findsOneWidget);
        expect(find.text('Lembur Maintenance & Backup Server'), findsOneWidget);
        expect(find.text('Cuti tahunan'), findsNothing);

        // 4. Switch to Reimbursement tab
        await tester.tap(find.text('Reimbursement'));
        await tester.pumpAndSettle();

        expect(find.text('Buat Klaim'), findsOneWidget);
        expect(find.text('Biaya Transport & Akomodasi Klien'), findsOneWidget);

        // 5. Switch to Petty Cash tab
        await tester.tap(find.text('Petty Cash'));
        await tester.pumpAndSettle();

        expect(find.text('Ajukan Kas Kecil'), findsOneWidget);
        expect(find.text('Konsumsi Rapat Bulanan Divisi'), findsOneWidget);

        // 6. Switch to General Affair tab
        await tester.tap(find.text('General Affair'));
        await tester.pumpAndSettle();

        expect(find.text('Permintaan GA'), findsOneWidget);
        expect(find.text('Pengadaan Kursi Kerja Ergonomis'), findsOneWidget);
      },
    );
  });
}
