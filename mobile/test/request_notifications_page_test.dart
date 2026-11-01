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
    testWidgets('renders two-line header, segmented filters, and mock notification cards', (
      tester,
    ) async {
      final workspace = Workspace({
        'requests': [],
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

      // 3. Verify Mock Notification Cards
      expect(find.text('Pengajuan Cuti Disetujui'), findsOneWidget);
      expect(find.text('Perlu Revisi Dokumen Klaim'), findsOneWidget);
      expect(find.text('Menunggu Verifikasi Finance'), findsOneWidget);
      expect(find.text('Tugas Lembur Disetujui'), findsOneWidget);
      expect(find.text('Permohonan Fasilitas Disetujui'), findsOneWidget);

      // 4. Tap 'Belum Dibaca' filter
      await tester.tap(find.byKey(const ValueKey('notif_filter_Belum Dibaca')));
      await tester.pumpAndSettle();

      // Unread items visible: Cuti & Reimbursement
      expect(find.text('Pengajuan Cuti Disetujui'), findsOneWidget);
      expect(find.text('Perlu Revisi Dokumen Klaim'), findsOneWidget);
      // Read items should not be visible in 'Belum Dibaca'
      expect(find.text('Menunggu Verifikasi Finance'), findsNothing);

      // 5. Tap 'Tandai Dibaca' action button in AppBar
      expect(find.byKey(const Key('notif_mark_all_read_btn')), findsOneWidget);
      await tester.tap(find.byKey(const Key('notif_mark_all_read_btn')));
      await tester.pumpAndSettle();

      // Now all items are read -> empty state in 'Belum Dibaca'
      expect(find.text('Tidak ada notifikasi yang belum dibaca.'), findsOneWidget);

      // 6. Switch back to 'Semua'
      await tester.tap(find.byKey(const ValueKey('notif_filter_Semua')));
      await tester.pumpAndSettle();
      expect(find.text('Pengajuan Cuti Disetujui'), findsOneWidget);
      expect(find.text('Menunggu Verifikasi Finance'), findsOneWidget);
    });

    testWidgets('tapping notification card opens RequestDetailScreen', (
      tester,
    ) async {
      final workspace = Workspace({
        'requests': [],
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
