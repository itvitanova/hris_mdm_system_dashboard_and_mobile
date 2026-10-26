import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/features/requests/request_detail.dart';
import 'package:mdm_hris/features/requests/request_form.dart';
import 'package:mdm_hris/shared/theme.dart';

class ApprovalApi extends ApiClient {
  Map<String, dynamic>? decision;
  final request = <String, dynamic>{
    'id': 'REQ-TEST',
    'revision': 4,
    'version': 2,
    'employeeId': 'STAFF',
    'employeeName': 'Anggota IT contoh',
    'kind': 'Reimbursement',
    'title': 'Parkir kunjungan kantor',
    'description': 'Keperluan kunjungan tim IT',
    'status': 'Menunggu',
    'createdAt': '2026-10-23T09:00:00+07:00',
    'amount': 50000,
    'startDate': '2026-10-23',
    'endDate': '2026-10-23',
    'currentStep': 0,
    'canReview': true,
    'canDownload': false,
    'snapshot': {
      'name': 'Anggota IT contoh',
      'employeeId': 'STAFF',
      'position': 'Staf IT',
      'department': 'IT',
      'phone': '080000000',
      'bankName': 'Bank contoh',
      'bankAccountName': 'Anggota IT contoh',
      'bankAccountNumber': '0012345678',
    },
    'items': [
      {
        'date': '2026-10-23',
        'description': 'Parkir kunjungan kantor',
        'category': 'Transportasi',
        'amount': 50000,
        'receiptId': 'RCPT',
      },
    ],
    'steps': [
      {
        'name': 'Persetujuan Lead IT',
        'source': 'manager',
        'mode': 'all',
        'status': 'Menunggu',
        'approvers': [
          {'employeeId': 'LEAD', 'name': 'Lead IT contoh'},
        ],
        'decisions': [],
      },
      {
        'name': 'Verifikasi finance',
        'source': 'finance',
        'mode': 'any',
        'status': 'Menunggu',
        'approvers': [
          {'employeeId': 'FINANCE', 'name': 'Finance contoh'},
        ],
        'decisions': [],
      },
    ],
    'history': [],
  };
  @override
  Future<Map<String, dynamic>> workspace() async => {
    'actor': {'employeeId': 'LEAD', 'name': 'Lead IT contoh'},
    'employees': [
      {'id': 'LEAD', 'faceEnrolled': true},
    ],
    'requests': [request],
    'approvalAccess': true,
  };
  @override
  Future<void> post(String path, Map<String, dynamic> body) async {
    expect(path, '/requests/REQ-TEST/review');
    decision = body;
    request['canReview'] = false;
    request['currentStep'] = 1;
  }
}

Future<void> fonts(WidgetTester tester) async {
  if (!const bool.fromEnvironment('WRITE_APPROVAL_PREVIEW')) return;
  await tester.runAsync(() async {
    const root = 'C:/flutter/flutter/bin/cache/artifacts/material_fonts';
    final loader = FontLoader('Roboto');
    for (final name in [
      'roboto-regular.ttf',
      'roboto-medium.ttf',
      'roboto-bold.ttf',
    ]) {
      loader.addFont(
        File('$root/$name').readAsBytes().then(ByteData.sublistView),
      );
    }
    await loader.load();
    await (FontLoader('MaterialIcons')..addFont(
          File(
            '$root/materialicons-regular.otf',
          ).readAsBytes().then(ByteData.sublistView),
        ))
        .load();
  });
}

Future<void> preview(WidgetTester tester, GlobalKey key, String name) async {
  if (!const bool.fromEnvironment('WRITE_APPROVAL_PREVIEW')) return;
  await tester.runAsync(() async {
    final image =
        await (key.currentContext!.findRenderObject() as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('../tmp/mobile-$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  for (final surface in ['inbox', 'form']) {
    testWidgets('$surface reflows at 360dp and font scale 3.2', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 3.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final api = ApprovalApi();
      await tester.pumpWidget(
        MaterialApp(
          theme: hrisTheme(),
          home: surface == 'inbox'
              ? ApprovalsScreen(api: api)
              : RequestForm(api: api, initialRequest: api.request),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final scroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      for (var pass = 0; pass < 80 && scroll.position.extentAfter > 1; pass++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
  testWidgets(
    'lead inbox opens detail and sends the current revision with decision',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await fonts(tester);
      final api = ApprovalApi();
      final key = GlobalKey();
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            theme: hrisTheme(),
            debugShowCheckedModeBanner: false,
            home: ApprovalsScreen(api: api),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Parkir kunjungan kantor'), findsOneWidget);
      await preview(tester, key, 'approval-inbox');
      await tester.tap(find.text('Parkir kunjungan kantor'));
      await tester.pumpAndSettle();
      await preview(tester, key, 'approval-detail');
      await tester.scrollUntilVisible(
        find.text('Menunggu persetujuan Lead IT contoh'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Semua wajib menyetujui'), findsNothing);
      expect(find.text('Cukup salah satu'), findsNothing);
      await tester.pumpAndSettle();
      await preview(tester, key, 'approval-flow');
      await tester.scrollUntilVisible(
        find.text('Menunggu tahap sebelumnya'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await preview(tester, key, 'approval-flow-finance');
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Setujui'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.widgetWithText(FilledButton, 'Setujui'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Bukti lengkap');
      await tester.tap(find.text('Simpan keputusan'));
      await tester.pumpAndSettle();
      expect(api.decision, {
        'status': 'Disetujui',
        'note': 'Bukti lengkap',
        'revision': 4,
      });
      expect(find.text('Tidak ada pengajuan yang sesuai.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'reimbursement rejects missing receipt and supports multiple expense rows',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = ApprovalApi();
      final key = GlobalKey();
      await fonts(tester);
      final input = {
        ...api.request,
        'title': 'Transportasi kantor',
        'items': [
          {
            'date': '2026-10-23',
            'description': 'Parkir',
            'category': 'Transportasi',
            'amount': 15000,
            'receiptId': '',
          },
        ],
      };
      await tester.pumpWidget(
        RepaintBoundary(
          key: key,
          child: MaterialApp(
            theme: hrisTheme(),
            debugShowCheckedModeBanner: false,
            home: RequestForm(api: api, initialRequest: input),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await preview(tester, key, 'reimbursement-form');
      await tester.scrollUntilVisible(
        find.text('Tambah rincian'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Tambah rincian'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Tambah rincian'));
      await tester.pumpAndSettle();
      expect(find.text('Pengeluaran 2'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Hapus rincian 2'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.ensureVisible(find.text('Hapus rincian 2'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus rincian 2'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Kirim pengajuan'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Kirim pengajuan'));
      await tester.pumpAndSettle();
      expect(
        find.text('Unggah bukti untuk setiap rincian pengeluaran.'),
        findsOneWidget,
      );
      expect(api.decision, isNull);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'approval detail reflows on small screen with largest tested text',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 3.2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final api = ApprovalApi();
      final steps = api.request['steps'] as List;
      final stage = steps.first as Map<String, dynamic>;
      (stage['approvers'] as List).add({
        'employeeId': 'SECOND-LEAD',
        'name': 'Atasan kedua contoh dengan nama panjang',
      });
      stage['source'] = 'manager';
      await tester.pumpWidget(
        MaterialApp(
          theme: hrisTheme(),
          debugShowCheckedModeBanner: false,
          home: RequestDetailScreen(api: api, request: api.request, own: false),
        ),
      );
      await tester.pumpAndSettle();
      final scroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      for (var pass = 0; pass < 80 && scroll.position.extentAfter > 1; pass++) {
        await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    },
  );
}
