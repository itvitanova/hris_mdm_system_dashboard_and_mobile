import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_kind.dart';
import 'package:mdm_hris/features/requests/presentation/pages/modules/dedicated_module_screen.dart';
import 'package:mdm_hris/features/requests/request_form.dart';

void main() {
  group('DedicatedModuleScreen Tests', () {
    testWidgets(
      'renders dedicated cuti module with isolation and locked form action',
      (tester) async {
        final workspace = Workspace({
          'requests': [],
          'employees': [],
        });
        Widget? openedWidget;

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => MaterialApp(
              home: DedicatedModuleScreen(
                kind: SubmissionKind.cuti,
                moduleTitle: 'Manajemen Cuti',
                heroTitle: 'Sisa Kuota Cuti Tahunan',
                heroSubtitle:
                    'Gunakan saldo cuti dengan bijak dan rencanakan liburanmu.',
                moduleIcon: Icons.beach_access_rounded,
                actionButtonText: 'Ajukan Cuti Baru',
                api: ApiClient(),
                workspace: workspace,
                open: (w) async => openedWidget = w,
                onRefresh: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Check module header & hero card
        expect(find.text('Manajemen Cuti'), findsOneWidget);
        expect(find.text('Sisa Kuota Cuti Tahunan'), findsOneWidget);
        expect(find.text('Ajukan Cuti Baru'), findsOneWidget);

        // 2. Verify strict isolation: Only cuti items appear, not reimbursement/lembur/petty cash
        expect(find.text('Cuti tahunan'), findsOneWidget);
        expect(find.text('Biaya Transport & Akomodasi Klien'), findsNothing);
        expect(find.text('Lembur Maintenance & Backup Server'), findsNothing);
        expect(find.text('Konsumsi Rapat Bulanan Divisi'), findsNothing);

        // 3. Tap action button to verify it opens RequestForm with locked kind
        await tester.tap(find.text('Ajukan Cuti Baru'));
        await tester.pumpAndSettle();
        expect(openedWidget, isA<RequestForm>());
        final form = openedWidget as RequestForm;
        expect(form.initialKind, 'Cuti');
        expect(form.lockKindSelection, true);
      },
    );

    testWidgets(
      'filters requests by status chips correctly in dedicated module',
      (tester) async {
        final workspace = Workspace({
          'requests': [
            {
              'id': 'cuti-1',
              'type': 'Cuti',
              'title': 'Cuti Sakit Rawat Inap',
              'status': 'disetujui',
              'start_date': '2026-10-01',
              'end_date': '2026-10-03',
            },
            {
              'id': 'cuti-2',
              'type': 'Cuti',
              'title': 'Cuti Menikah',
              'status': 'menunggu',
              'start_date': '2026-11-10',
              'end_date': '2026-11-12',
            },
          ],
          'employees': [],
        });

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => MaterialApp(
              home: DedicatedModuleScreen(
                kind: SubmissionKind.cuti,
                moduleTitle: 'Manajemen Cuti',
                heroTitle: 'Sisa Kuota Cuti Tahunan',
                heroSubtitle: 'Saldo cuti tahunan aktif.',
                moduleIcon: Icons.beach_access_rounded,
                actionButtonText: 'Ajukan Cuti',
                api: ApiClient(),
                workspace: workspace,
                open: (w) async {},
                onRefresh: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial 'Semua' filter: both items appear
        expect(find.text('Cuti Sakit Rawat Inap'), findsOneWidget);
        expect(find.text('Cuti Menikah'), findsOneWidget);

        // Tap 'Disetujui' chip
        await tester.tap(find.text('Disetujui').first);
        await tester.pumpAndSettle();

        expect(find.text('Cuti Sakit Rawat Inap'), findsOneWidget);
        expect(find.text('Cuti Menikah'), findsNothing);

        // Tap 'Menunggu' chip
        await tester.tap(find.text('Menunggu').first);
        await tester.pumpAndSettle();

        expect(find.text('Cuti Sakit Rawat Inap'), findsNothing);
        expect(find.text('Cuti Menikah'), findsOneWidget);
      },
    );
  });
}
