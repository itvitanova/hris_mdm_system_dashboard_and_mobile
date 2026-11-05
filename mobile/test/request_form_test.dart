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
          home: RequestForm(
            api: api,
            initialKind: kind,
            initialRequest: kind == 'Reimbursement'
                ? {
                    'kind': kind,
                    'items': [
                      {
                        'date': '2026-01-02',
                        'description': 'Parkir',
                        'category': 'Transportasi',
                        'amount': 150000,
                        'receiptId': 'receipt-fixture',
                      },
                    ],
                  }
                : null,
          ),
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
      if (['Petty Cash', 'General Affair'].contains(kind)) {
        final field = find.widgetWithText(TextFormField, 'Nominal (Rp)');
        await tester.scrollUntilVisible(
          field,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(field, '150000');
      }
      if (kind == 'Lembur') {
        final field = find.widgetWithText(TextFormField, 'Durasi lembur (jam)');
        await tester.scrollUntilVisible(
          field,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(field, '2');
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
        expect(api.payload?['hours'], 2);
        expect(api.payload?['startDate'], api.payload?['endDate']);
      }
      if (kind == 'Cuti') expect(api.payload?['amount'], 0);
      if (kind == 'Reimbursement') {
        expect(api.payload?['amount'], 150000);
        expect(
          (api.payload?['items'] as List).single['receiptId'],
          'receipt-fixture',
        );
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'General Affair renders category selector, priority, date card, optional amount, attachment, and summary box',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'General Affair',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Check Category selector
      expect(find.text('Kategori Kebutuhan GA *'), findsOneWidget);
      expect(find.text('Pengadaan Barang'), findsWidgets);
      expect(find.text('Perbaikan & Servis'), findsOneWidget);
      expect(find.text('Kebutuhan ATK'), findsOneWidget);
      expect(find.text('Pemeliharaan Fasilitas'), findsOneWidget);

      // 2. Check Priority selector
      expect(find.text('Tingkat Prioritas *'), findsOneWidget);
      expect(find.text('Normal'), findsWidgets);
      expect(find.text('Mendesak'), findsOneWidget);

      // 3. Check Structured Date Picker
      expect(find.text('Tanggal Kebutuhan Sarana *'), findsOneWidget);
      expect(find.text('Tanggal Kebutuhan'), findsWidgets);

      // 4. Check Optional Amount
      expect(find.text('Estimasi Biaya / Anggaran (Rp)'), findsOneWidget);

      // 5. Check Attachment card
      expect(find.text('Lampiran Dokumen / Foto Kondisi'), findsOneWidget);

      // 6. Check Summary box
      expect(find.text('Ringkasan Kebutuhan GA'), findsOneWidget);
    },
  );
}
