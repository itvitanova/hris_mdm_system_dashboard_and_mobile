import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/features/requests/request_form.dart';

class CaptureApi extends ApiClient {
  Map<String, dynamic>? payload;
  @override
  Future<void> post(String path, Map<String, dynamic> body) async {
    expect(path, '/requests');
    payload = body;
    throw ApiException('Test: keep screen open after capturing request');
  }
}

void main() {
  for (final kind in requestKinds) {
    testWidgets('$kind validates and sends the existing API contract', (
      tester,
    ) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(api: api, initialKind: kind),
        ),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Judul'),
        'Keperluan karyawan',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Keperluan / rincian'),
        'Rincian pengajuan',
      );
      if (['Reimbursement', 'Petty Cash', 'General Affair'].contains(kind)) {
        final field = find.widgetWithText(TextFormField, 'Nominal (Rp)');
        await tester.ensureVisible(field);
        await tester.enterText(field, '150000');
      }
      if (kind == 'Lembur') {
        final field = find.widgetWithText(TextFormField, 'Durasi lembur (jam)');
        await tester.ensureVisible(field);
        await tester.enterText(field, '1,5');
      }
      final send = find.text('Kirim pengajuan');
      await tester.scrollUntilVisible(
        send,
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(api.payload?['kind'], kind);
      expect(api.payload?.containsKey('employeeId'), isFalse);
      if (kind == 'Lembur') {
        expect(api.payload?['hours'], 1.5);
        expect(api.payload?['startDate'], api.payload?['endDate']);
      }
      if (kind == 'Cuti') expect(api.payload?['amount'], 0);
      expect(tester.takeException(), isNull);
    });
  }
}
