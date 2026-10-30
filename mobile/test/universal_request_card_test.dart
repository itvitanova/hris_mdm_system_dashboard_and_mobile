import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/presentation/models/mock_universal_requests.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/universal_request_card/universal_request_card.dart';
import 'package:mdm_hris/features/root/presentation/widgets/requests_tab.dart';

void main() {
  group('UniversalRequestCard Tests', () {
    testWidgets('renders all 5 mock submission kinds without errors', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: mockUniversalRequests
                    .map((data) => UniversalRequestCard(data: data))
                    .toList(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cuti tahunan'), findsOneWidget);
      expect(find.text('Biaya Transport & Akomodasi Klien'), findsOneWidget);
      expect(find.text('Konsumsi Rapat Bulanan Divisi'), findsOneWidget);
      expect(find.text('Lembur Maintenance & Backup Server'), findsOneWidget);
      expect(find.text('Pengadaan Kursi Kerja Ergonomis'), findsOneWidget);

      expect(find.text('PENGAJUAN CUTI'), findsOneWidget);
      expect(find.text('KLAIM REIMBURSEMENT'), findsOneWidget);
      expect(find.text('PENGAJUAN PETTY CASH'), findsOneWidget);
      expect(find.text('PENGAJUAN LEMBUR'), findsOneWidget);
      expect(find.text('PENGAJUAN GENERAL AFFAIR'), findsOneWidget);
    });

    testWidgets('renders revision box when status is perluRevisi', (
      tester,
    ) async {
      final revisionItem = mockUniversalRequests.firstWhere(
        (m) => m.status == SubmissionStatus.perluRevisi,
      );

      bool reviseClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalRequestCard(
              data: revisionItem,
              onRevisePressed: () => reviseClicked = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.text(
          '"Mohon lampirkan struk kasir asli dengan cap toko dan rincian menu."',
        ),
        findsOneWidget,
      );
      expect(find.text('Perbaiki pengajuan'), findsOneWidget);

      final buttonFinder = find.text('Perbaiki pengajuan');
      final containerFinder = find.ancestor(
        of: buttonFinder,
        matching: find.byType(Container),
      );
      final containerWidget = tester.widget<Container>(containerFinder.first);
      final decoration = containerWidget.decoration as BoxDecoration?;
      expect(decoration?.gradient, isA<LinearGradient>());
      final gradient = decoration!.gradient as LinearGradient;
      expect(gradient.colors, [
        const Color(0xFFE11D48),
        const Color(0xFFBE123C),
      ]);

      await tester.tap(find.text('Perbaiki pengajuan'));
      await tester.pumpAndSettle();
      expect(reviseClicked, isTrue);
    });

    testWidgets('renders 2-stage stepper for reimbursement', (tester) async {
      final reimbursementItem = mockUniversalRequests.firstWhere(
        (m) => m.kind == SubmissionKind.reimbursement,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalRequestCard(data: reimbursementItem),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Atasan (Aries M.)'), findsOneWidget);
      expect(find.text('Finance (Alicia)'), findsOneWidget);
      expect(find.text('Tahap 2 dari 2'), findsOneWidget);
    });

    testWidgets(
      'renders solid teal button for "Rincian dan dokumen" when not in revision',
      (tester) async {
        final standardItem = mockUniversalRequests.firstWhere(
          (m) => m.status != SubmissionStatus.perluRevisi,
        );

        bool detailClicked = false;
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: UniversalRequestCard(
                data: standardItem,
                onDetailPressed: () => detailClicked = true,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final buttonFinder = find.text('Rincian dan dokumen');
        expect(buttonFinder, findsOneWidget);

        final containerFinder = find.ancestor(
          of: buttonFinder,
          matching: find.byType(Container),
        );
        final containerWidget = tester.widget<Container>(containerFinder.first);
        final decoration = containerWidget.decoration as BoxDecoration?;
        expect(decoration?.gradient, isA<LinearGradient>());
        final gradient = decoration!.gradient as LinearGradient;
        expect(gradient.colors, [
          const Color(0xFF0F766E),
          const Color(0xFF14B8A6),
        ]);

        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();
        expect(detailClicked, isTrue);
      },
    );

    testWidgets('RequestsTab displays catalog service cards and recent requests', (
      tester,
    ) async {
      final workspace = Workspace({
        'requests': [],
        'employees': [],
        'attendancePolicy': {},
      });

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            home: RequestsTab(
              api: ApiClient(),
              workspace: workspace,
              onRefresh: () async {},
              open: (w) async {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 5 Service Cards
      expect(find.text('Katalog Pengajuan'), findsOneWidget);
      expect(find.text('Cuti & Izin'), findsOneWidget);
      expect(find.text('Lembur'), findsOneWidget);
      expect(find.text('Reimbursement'), findsOneWidget);
      expect(find.text('Petty Cash'), findsOneWidget);
      expect(find.text('General Affair'), findsOneWidget);

      // Recent Requests section
      expect(find.text('Pengajuan Terkini'), findsOneWidget);

      // Scroll to reveal recent request cards
      await tester.scrollUntilVisible(
        find.text('Cuti tahunan'),
        200,
        scrollable: find.byType(Scrollable),
      );

      expect(find.byType(UniversalRequestCard), findsWidgets);
      expect(find.text('Cuti tahunan'), findsOneWidget);
    });
  });
}
