import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_detail_page.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_notifications_page.dart';

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

  group('RequestNotificationsScreen Tests', () {
    testWidgets('renders two-line header, segmented filters, and real notification cards', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final workspace = Workspace({
        'requests': [
          {
            'id': 'REQ-NOTIF-1',
            'kind': 'Cuti',
            'title': 'Cuti Tahunan Liburan',
            'status': 'Disetujui',
            'unread': true,
            'reviewNote': 'Disetujui untuk periode akhir tahun',
            'reviewedBy': 'Lead HR',
            'updatedAt': now.toIso8601String(),
          },
          {
            'id': 'REQ-NOTIF-2',
            'kind': 'Reimbursement',
            'title': 'Klaim Transportasi Klien',
            'status': 'Perlu Revisi',
            'unread': true,
            'reviewNote': 'Struk parkir tidak terbaca jelas',
            'reviewedBy': 'Finance',
            'updatedAt': now.subtract(const Duration(days: 1)).toIso8601String(),
          },
          {
            'id': 'REQ-NOTIF-3',
            'kind': 'Lembur',
            'title': 'Tugas Lembur Deployment',
            'status': 'Disetujui',
            'unread': false,
            'reviewedBy': 'Manager IT',
            'updatedAt': now.subtract(const Duration(days: 3)).toIso8601String(),
            'history': [
              {'decision': 'Disetujui'},
            ],
          },
        ],
        'employees': [],
      });

      await tester.pumpWidget(
        wrapWithScreenUtil(
          RequestNotificationsScreen(
            api: ApiClient(),
            workspace: workspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify AppBar
      expect(find.text('Notifikasi Pengajuan'), findsOneWidget);
      expect(find.text('Pembaruan Status & Keputusan'), findsOneWidget);

      // 2. Verify Segmented Filter Bar
      expect(find.byKey(const ValueKey('notif_filter_Semua')), findsOneWidget);
      expect(find.byKey(const ValueKey('notif_filter_Belum Dibaca')), findsOneWidget);

      // 3. Verify Day Grouping Section Headers
      expect(find.text('HARI INI'), findsOneWidget);
      expect(find.text('KEMARIN'), findsOneWidget);
      expect(find.text('TERDAHULU'), findsOneWidget);

      // 4. Verify Real Notification Cards
      expect(find.text('Pengajuan Cuti Disetujui'), findsOneWidget);
      expect(find.text('Perlu Revisi Dokumen Reimbursement'), findsOneWidget);
      expect(find.text('Pengajuan Lembur Disetujui'), findsOneWidget);

      // 5. Verify Reviewer Note & "Perbaiki Sekarang" button
      expect(find.textContaining('Catatan Peninjau'), findsNWidgets(2));
      expect(find.text('Perbaiki Sekarang'), findsOneWidget);

      // 6. Tap 'Belum Dibaca' filter
      await tester.tap(find.byKey(const ValueKey('notif_filter_Belum Dibaca')));
      await tester.pumpAndSettle();

      // Unread items visible: Cuti & Reimbursement
      expect(find.text('Pengajuan Cuti Disetujui'), findsOneWidget);
      expect(find.text('Perlu Revisi Dokumen Reimbursement'), findsOneWidget);
      // Read items should not be visible in 'Belum Dibaca'
      expect(find.text('Pengajuan Lembur Disetujui'), findsNothing);

      // 7. Tap 'Tandai Dibaca' action button in AppBar
      expect(find.byKey(const Key('notif_mark_all_read_btn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('notif_mark_all_read_btn')));
      await tester.pumpAndSettle();

      // Now all items are read -> empty state in 'Belum Dibaca'
      expect(find.text('Tidak ada notifikasi yang belum dibaca.'), findsOneWidget);

      // 8. Switch back to 'Semua'
      await tester.tap(find.byKey(const ValueKey('notif_filter_Semua')));
      await tester.pumpAndSettle();
      expect(find.text('Pengajuan Cuti Disetujui'), findsOneWidget);
      expect(find.text('Pengajuan Lembur Disetujui'), findsOneWidget);
    });

    testWidgets('tapping notification card opens RequestDetailScreen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 3, 1200 * 3);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final workspace = Workspace({
        'requests': [
          {
            'id': 'REQ-NOTIF-1',
            'kind': 'Cuti',
            'title': 'Cuti Tahunan Liburan',
            'status': 'Disetujui',
            'unread': true,
            'updatedAt': DateTime.now().toIso8601String(),
          },
        ],
        'employees': [],
      });

      await tester.pumpWidget(
        wrapWithScreenUtil(
          RequestNotificationsScreen(
            api: ApiClient(),
            workspace: workspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on first card (Cuti)
      await tester.tap(find.text('Pengajuan Cuti Disetujui'));
      await tester.pumpAndSettle();

      // Verified opened RequestDetailScreen
      expect(find.byType(RequestDetailScreen), findsOneWidget);
    });
  });
}
