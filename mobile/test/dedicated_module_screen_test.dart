import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_kind.dart';
import 'package:mdm_hris/features/requests/presentation/pages/modules/dedicated_module_screen.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/submission_status_filter_dropdown.dart';
import 'package:mdm_hris/features/requests/request_form.dart';

void main() {
  group('DedicatedModuleScreen Tests', () {
    testWidgets(
      'renders dedicated cuti module with 2x2 stats, dropdown filter, and header (+) action',
      (tester) async {
        final workspace = Workspace({
          'requests': [
            {
              'id': 'cuti-fixture-1',
              'type': 'Cuti',
              'title': 'Cuti tahunan',
              'status': 'menunggu',
              'start_date': '2026-11-02',
              'end_date': '2026-11-03',
            },
          ],
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
                moduleTitle: 'Pengajuan Cuti & Izin',
                keyMetricLabel: 'SISA KUOTA',
                keyMetricValue: '10 Hari',
                keyMetricIcon: Icons.event_available_outlined,
                api: ApiClient(),
                workspace: workspace,
                open: (w) async => openedWidget = w,
                onRefresh: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Check title & 2x2 stat cards
        expect(find.text('Pengajuan Cuti & Izin'), findsOneWidget);
        expect(find.text('DISETUJUI'), findsOneWidget);
        expect(find.text('MENUNGGU'), findsWidgets);
        expect(find.text('DITOLAK / REVISI'), findsOneWidget);
        expect(find.text('SISA KUOTA'), findsOneWidget);
        expect(find.text('10 Hari'), findsOneWidget);

        // 2. Check dropdown filter exists
        expect(find.byType(SubmissionStatusFilterDropdown), findsOneWidget);
        expect(find.text('Semua Status Pengajuan'), findsOneWidget);

        // 3. Verify strict isolation: Only cuti items appear
        await tester.scrollUntilVisible(
          find.text('Cuti tahunan'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Cuti tahunan'), findsOneWidget);
        expect(find.text('Biaya Transport & Akomodasi Klien'), findsNothing);
        expect(find.text('Lembur Maintenance & Backup Server'), findsNothing);

        // 4. Tap (+) hero button -> opens RequestForm locked to Cuti
        await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
        await tester.pumpAndSettle();
        expect(find.text('Buat Pengajuan Cuti'), findsOneWidget);
        await tester.tap(find.text('Buat Pengajuan Cuti'));
        await tester.pumpAndSettle();
        expect(openedWidget, isA<RequestForm>());
        final form = openedWidget as RequestForm;
        expect(form.initialKind, 'Cuti');
        expect(form.lockKindSelection, true);
      },
    );

    testWidgets(
      'filters requests by dropdown filter and stat card taps',
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
                moduleTitle: 'Pengajuan Cuti & Izin',
                keyMetricLabel: 'SISA KUOTA',
                keyMetricValue: '10 Hari',
                keyMetricIcon: Icons.event_available_outlined,
                api: ApiClient(),
                workspace: workspace,
                open: (w) async {},
                onRefresh: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Initial state: both items appear
        await tester.scrollUntilVisible(
          find.text('Cuti Sakit Rawat Inap'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Cuti Sakit Rawat Inap'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Cuti Menikah'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Cuti Menikah'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('DISETUJUI'),
          -100,
          scrollable: find.byType(Scrollable).first,
        );

        // Tap stat card 'DISETUJUI'
        await tester.tap(find.text('DISETUJUI'));
        await tester.pumpAndSettle();

        await tester.scrollUntilVisible(
          find.text('Cuti Sakit Rawat Inap'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Cuti Sakit Rawat Inap'), findsOneWidget);
        expect(find.text('Cuti Menikah'), findsNothing);
        await tester.scrollUntilVisible(
          find.text('MENUNGGU'),
          -100,
          scrollable: find.byType(Scrollable).first,
        );

        // Tap stat card 'MENUNGGU'
        await tester.tap(find.text('MENUNGGU'));
        await tester.pumpAndSettle();

        expect(find.text('Cuti Sakit Rawat Inap'), findsNothing);
        await tester.scrollUntilVisible(
          find.text('Cuti Menikah'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Cuti Menikah'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.byType(SubmissionStatusFilterDropdown),
          -100,
          scrollable: find.byType(Scrollable).first,
        );

        // Open dropdown trigger to select 'Semua Status Pengajuan'
        await tester.tap(find.byType(SubmissionStatusFilterDropdown));
        await tester.pumpAndSettle();

        expect(find.text('Semua Status Pengajuan'), findsWidgets);
        await tester.tap(find.text('Semua Status Pengajuan').last);
        await tester.pumpAndSettle();

        // Both items appear again
        await tester.scrollUntilVisible(
          find.text('Cuti Sakit Rawat Inap'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Cuti Sakit Rawat Inap'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Cuti Menikah'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Cuti Menikah'), findsOneWidget);
      },
    );

    testWidgets(
      'renders dedicated petty cash module and calculates real accumulated total on card 4',
      (tester) async {
        final workspace = Workspace({
          'requests': [
            {
              'id': 'petty-fixture-1',
              'kind': 'Petty Cash',
              'title': 'Beli ATK darurat',
              'status': 'disetujui',
              'startDate': '2026-11-01',
              'amount': 150000,
            },
            {
              'id': 'petty-fixture-2',
              'kind': 'Petty Cash',
              'title': 'Konsumsi rapat klien',
              'status': 'menunggu',
              'startDate': '2026-11-03',
              'amount': 225000,
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
                kind: SubmissionKind.pettyCash,
                moduleTitle: 'Pengajuan Petty Cash',
                keyMetricLabel: 'KAS KECIL',
                keyMetricValue: 'Rp 0',
                keyMetricIcon: Icons.payments_outlined,
                api: ApiClient(),
                workspace: workspace,
                open: (w) async {},
                onRefresh: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Pengajuan Petty Cash'), findsOneWidget);
        expect(find.text('KAS KECIL'), findsOneWidget);
        expect(find.text(rupiah(375000)), findsOneWidget);
      },
    );

    testWidgets(
      'renders dedicated general affair module and computes real requests from workspace on card 4',
      (tester) async {
        final workspace = Workspace({
          'requests': [
            {
              'id': 'ga-1',
              'kind': 'General Affair',
              'title': 'Pengadaan Kursi Kerja',
              'status': 'disetujui',
              'startDate': '2026-11-01',
              'endDate': '2026-11-01',
            },
            {
              'id': 'ga-2',
              'kind': 'General Affair',
              'title': 'Perbaikan AC Ruang Meeting',
              'status': 'menunggu',
              'startDate': '2026-11-05',
              'endDate': '2026-11-05',
            },
            {
              'id': 'cuti-1',
              'kind': 'Cuti',
              'title': 'Cuti Tahunan',
              'status': 'disetujui',
              'startDate': '2026-11-10',
              'endDate': '2026-11-12',
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
                kind: SubmissionKind.generalAffair,
                moduleTitle: 'General Affair',
                keyMetricLabel: 'PERMOHONAN GA',
                keyMetricValue: '1 Aktif',
                keyMetricIcon: Icons.inventory_2_outlined,
                api: ApiClient(),
                workspace: workspace,
                open: (w) async {},
                onRefresh: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Check card 4 calculates real GA requests (2 items, excluding cuti-1)
        expect(find.text('Total Permohonan'), findsOneWidget);
        expect(find.text('2 Permohonan'), findsOneWidget);
        expect(find.text('PERMOHONAN GA'), findsOneWidget);
      },
    );
  });
}
