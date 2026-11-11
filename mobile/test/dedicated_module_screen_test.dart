import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/domain/entities/submission_kind.dart';
import 'package:mdm_hris/features/requests/presentation/pages/modules/dedicated_module_screen.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/services_hub/submission_status_filter_dropdown.dart';
import 'package:mdm_hris/features/requests/request_form.dart';
import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

void main() {
  setUp(() {
    AppLanguageController.reset();
  });

  tearDown(() {
    AppLanguageController.reset();
  });

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
        expect(find.text('DITOLAK'), findsOneWidget);
        expect(find.text('PERLU REVISI'), findsOneWidget);

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
        await tester.scrollUntilVisible(
          find.text('Buat Pengajuan Cuti'),
          -150,
          scrollable: find.byType(Scrollable).first,
        );
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
                keyMetricLabel: 'TOTAL PENGAJUAN',
                keyMetricValue: '0 Pengajuan',
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
        expect(find.text('DITOLAK'), findsOneWidget);
        expect(find.text('PERLU REVISI'), findsOneWidget);
      },
    );

    testWidgets(
      'renders dedicated general affair module with separated Ditolak and Perlu Revisi cards',
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
              'id': 'ga-3',
              'kind': 'General Affair',
              'title': 'Sewa Proyektor',
              'status': 'ditolak',
              'startDate': '2026-11-06',
              'endDate': '2026-11-06',
            },
            {
              'id': 'ga-4',
              'kind': 'General Affair',
              'title': 'Renovasi Pantry',
              'status': 'perlu revisi',
              'startDate': '2026-11-07',
              'endDate': '2026-11-07',
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

        // 4 Bento Cards
        expect(find.text('Disetujui'), findsWidgets);
        expect(find.text('Menunggu'), findsWidgets);
        expect(find.text('Ditolak'), findsWidgets);
        expect(find.text('Perlu Revisi'), findsWidgets);

        // Ensure "Total Permohonan" card is removed
        expect(find.text('Total Permohonan'), findsNothing);
      },
    );

    testWidgets(
      'DedicatedModuleScreen Tests renders dedicated lembur module with separated Ditolak and Perlu Revisi cards and no Total Jam Lembur card',
      (tester) async {
        final workspace = Workspace({
          'requests': [
            {
              'id': 'lembur-1',
              'kind': 'Lembur',
              'title': 'Lembur Deployment Server',
              'status': 'disetujui',
              'hours': 3,
              'startDate': '2026-11-01',
              'endDate': '2026-11-01',
            },
            {
              'id': 'lembur-2',
              'kind': 'Lembur',
              'title': 'Lembur Migrasi Database',
              'status': 'menunggu',
              'hours': 2,
              'startDate': '2026-11-02',
              'endDate': '2026-11-02',
            },
            {
              'id': 'lembur-3',
              'kind': 'Lembur',
              'title': 'Lembur Testing',
              'status': 'ditolak',
              'hours': 1,
              'startDate': '2026-11-03',
              'endDate': '2026-11-03',
            },
            {
              'id': 'lembur-4',
              'kind': 'Lembur',
              'title': 'Lembur Dokumentasi',
              'status': 'perlu revisi',
              'hours': 2,
              'startDate': '2026-11-04',
              'endDate': '2026-11-04',
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
                kind: SubmissionKind.lembur,
                moduleTitle: 'Lembur',
                keyMetricLabel: 'TOTAL JAM LEMBUR',
                keyMetricValue: '3 Jam',
                keyMetricIcon: Icons.schedule_rounded,
                api: ApiClient(),
                workspace: workspace,
                open: (w) async {},
                onRefresh: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 4 Bento Cards
        expect(find.text('Disetujui'), findsWidgets);
        expect(find.text('Menunggu'), findsWidgets);
        expect(find.text('Ditolak'), findsWidgets);
        expect(find.text('Perlu Revisi'), findsWidgets);

        // Ensure "Total Jam Lembur" card is removed
        expect(find.text('Total Jam Lembur'), findsNothing);
      },
    );

    testWidgets(
      'paginates history list at 5 items per page and navigates pages',
      (tester) async {
        final items = List.generate(
          8,
          (i) => {
            'id': 'cuti-$i',
            'kind': 'Cuti',
            'title': 'Pengajuan Cuti Nomor $i',
            'status': 'disetujui',
            'startDate': '2026-11-0$i',
            'endDate': '2026-11-0$i',
          },
        );

        final workspace = Workspace({
          'requests': items,
          'employees': [],
        });

        await tester.pumpWidget(
          ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            builder: (context, child) => MaterialApp(
              home: DedicatedModuleScreen(
                kind: SubmissionKind.cuti,
                moduleTitle: 'Cuti',
                keyMetricLabel: 'SISA KUOTA',
                keyMetricValue: '12 Hari',
                keyMetricIcon: Icons.calendar_today_outlined,
                api: ApiClient(),
                workspace: workspace,
                open: (w) async {},
                onRefresh: () async {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Page 1: shows first 5 items (0..4)
        await tester.scrollUntilVisible(
          find.text('Pengajuan Cuti Nomor 0'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Pengajuan Cuti Nomor 0'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Pengajuan Cuti Nomor 4'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Pengajuan Cuti Nomor 4'), findsOneWidget);
        expect(find.text('Pengajuan Cuti Nomor 5'), findsNothing);

        // Pagination bar visible
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('pagination_bar')),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.byKey(const ValueKey('pagination_bar')), findsOneWidget);
        expect(find.text('Halaman 1 dari 2'), findsOneWidget);
        expect(find.text('Menampilkan 1–5 dari 8 pengajuan'), findsOneWidget);

        // Tap Selanjutnya
        await tester.tap(find.byKey(const ValueKey('pagination_next_btn')));
        await tester.pumpAndSettle();

        // Page 2: shows remaining 3 items (5..7)
        expect(find.text('Pengajuan Cuti Nomor 0'), findsNothing);
        await tester.scrollUntilVisible(
          find.text('Pengajuan Cuti Nomor 5'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Pengajuan Cuti Nomor 5'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Pengajuan Cuti Nomor 7'),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Pengajuan Cuti Nomor 7'), findsOneWidget);

        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('pagination_bar')),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Halaman 2 dari 2'), findsOneWidget);
        expect(find.text('Menampilkan 6–8 dari 8 pengajuan'), findsOneWidget);

        // Tap Sebelumnya
        await tester.tap(find.byKey(const ValueKey('pagination_prev_btn')));
        await tester.pumpAndSettle();

        // Back to Page 1
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('pagination_bar')),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Halaman 1 dari 2'), findsOneWidget);
        await tester.scrollUntilVisible(
          find.text('Pengajuan Cuti Nomor 0'),
          -100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Pengajuan Cuti Nomor 0'), findsOneWidget);
      },
    );

    testWidgets(
      'empty state displays info message without Buat Pengajuan Baru button in empty state',
      (tester) async {
        final workspace = Workspace({
          'requests': [],
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

        // Top action button exists
        expect(find.text('Buat Pengajuan Cuti'), findsOneWidget);

        // Scroll to empty state
        await tester.scrollUntilVisible(
          find.text('Belum ada riwayat pengajuan cuti'),
          100,
          scrollable: find.byType(Scrollable).first,
        );

        // Empty state message exists
        expect(
          find.text('Belum ada riwayat pengajuan cuti'),
          findsOneWidget,
        );

        // Empty state button 'Buat Pengajuan Baru' does NOT exist
        expect(find.text('Buat Pengajuan Baru'), findsNothing);
      },
    );

    testWidgets(
      'switches language to English and updates all texts in DedicatedModuleScreen',
      (tester) async {
        final workspace = Workspace({
          'requests': [
            {
              'id': 'cuti-1',
              'kind': 'Cuti',
              'title': 'Cuti Tahunan Pribadi',
              'status': 'disetujui',
              'days': 2,
              'startDate': '2026-11-01',
              'endDate': '2026-11-02',
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
                moduleTitle: 'Pengajuan Cuti',
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

        // 1. Initially ID
        expect(find.text('Pengajuan Cuti'), findsOneWidget);
        expect(find.text('Layanan Cuti Tahunan'), findsOneWidget);
        expect(find.text('Buat Pengajuan Cuti'), findsOneWidget);

        // 2. LanguageSwapButton must NOT exist in DedicatedModuleScreen (only in Dashboard)
        expect(find.byKey(const Key('dashboard_language_swap_button')), findsNothing);

        // 3. Switch global language to ENG
        AppLanguageController.setLanguage(AppLanguage.en);
        await tester.pumpAndSettle();

        // 4. Verify texts switched to English automatically
        expect(find.text('Leave Request'), findsOneWidget);
        expect(find.text('Manage leave quota & requests'), findsOneWidget);
        expect(find.text('Annual Leave Service'), findsOneWidget);
        expect(find.text('Need Time Off?'), findsOneWidget);
        expect(find.text('Create Leave Request'), findsOneWidget);

        // Stat cards
        expect(find.text('APPROVED'), findsOneWidget);
        expect(find.text('PENDING'), findsOneWidget);
        expect(find.text('REJECTED'), findsOneWidget);
        expect(find.text('NEEDS REVISION'), findsOneWidget);

        // Filter Dropdown trigger
        expect(find.text('All Submission Statuses'), findsOneWidget);

        // Subtitle banner & count
        expect(find.text('Leave History'), findsOneWidget);
        expect(find.text('1 Submissions'), findsOneWidget);

        // Pagination Bar
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('pagination_bar')),
          100,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text('Page 1 of 1'), findsOneWidget);
        expect(find.text('Showing 1–1 of 1 submissions'), findsOneWidget);
      },
    );
  });
}
