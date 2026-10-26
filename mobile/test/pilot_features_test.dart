import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/home/leave_calendar_screen.dart';
import 'package:mdm_hris/features/requests/receipt_preview.dart';
import 'package:mdm_hris/features/requests/request_detail.dart';
import 'package:mdm_hris/features/requests/request_form.dart';
import 'package:mdm_hris/shared/theme.dart';
import 'approvals_test.dart' show fonts, preview;

class PilotApi extends ApiClient {
  String? seen;
  @override
  Future<List<Map<String, dynamic>>> getList(String path) async {
    expect(path, '/leave-calendar?month=2026-10');
    return [
      {
        'requestId': 'CUTI',
        'name': 'Rekan kantor contoh',
        'department': 'IT',
        'startDate': '2026-10-26',
        'endDate': '2026-10-27',
      },
    ];
  }

  @override
  Future<({Uint8List bytes, String contentType})> requestFile(
    String path,
  ) async => (
    bytes: base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+aE1sAAAAASUVORK5CYII=',
    ),
    contentType: 'image/png',
  );
  @override
  Future<void> post(String path, Map<String, dynamic> body) async {
    seen = body['token'] as String?;
  }
}

void main() {
  testWidgets(
    'unknown request search keeps the selected kind and does not crash',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: hrisTheme(),
          home: RequestForm(api: PilotApi()),
        ),
      );
      await tester.pumpAndSettle();
      final input = find.descendant(
        of: find.byType(DropdownMenu<String>),
        matching: find.byType(TextField),
      );
      await tester.enterText(input, 'Jenis tidak tersedia');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.widget<TextField>(input).controller!.text, 'Cuti');
    },
  );
  testWidgets('calendar month layout is readable on a phone', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await fonts(tester);
    final boundary = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: boundary,
        child: MaterialApp(
          theme: hrisTheme(),
          debugShowCheckedModeBanner: false,
          home: LeaveCalendarScreen(
            api: PilotApi(),
            workspace: Workspace({
              'attendanceDate': '2026-10-25',
              'settings': {'locationName': 'HQ contoh'},
            }),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Oktober 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await preview(tester, boundary, 'leave-calendar');
  });
  testWidgets(
    'calendar marks approved leave and lists colleagues on selection with large text',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final api = PilotApi();
      await tester.pumpWidget(
        MaterialApp(
          theme: hrisTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(3.2)),
            child: child!,
          ),
          home: LeaveCalendarScreen(
            api: api,
            workspace: Workspace({
              'attendanceDate': '2026-10-25',
              'settings': {'locationName': 'HQ contoh'},
            }),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.scrollUntilVisible(
        find.text('26'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('26'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Rekan kantor contoh'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Rekan kantor contoh'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'receipt image is visible and supports zoom without a download first',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: hrisTheme(),
          home: ReceiptPreview(
            api: PilotApi(),
            path: '/requests/OWN/receipts/PROOF',
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.text('Simpan / bagikan foto'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'opening own updated request acknowledges exactly the displayed event',
    (tester) async {
      final api = PilotApi();
      final token = List.filled(64, 'a').join();
      await tester.pumpWidget(
        MaterialApp(
          theme: hrisTheme(),
          home: RequestDetailScreen(
            api: api,
            own: true,
            request: {
              'id': 'OWN',
              'title': 'Pengajuan contoh',
              'kind': 'Cuti',
              'status': 'Perlu revisi',
              'unread': true,
              'updateToken': token,
              'reviewNote': 'Lengkapi tanggal',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(api.seen, token);
      expect(find.text('Perlu diperbaiki'), findsOneWidget);
    },
  );
}
