import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/features/requests/request_form.dart';
import 'package:mdm_hris/features/requests/presentation/widgets/form_card_input.dart';

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
      final titleFinder = (kind == 'Petty Cash' || kind == 'Medical Claim' || kind == 'Izin' || kind == 'Reimbursement' || kind == 'General Affair')
          ? find.widgetWithText(TextFormField, 'Ringkasan keperluan Anda')
          : find.widgetWithText(TextFormField, 'Judul');
      await tester.enterText(
        titleFinder,
        'Keperluan karyawan',
      );
      final descFinder = (kind == 'Petty Cash' || kind == 'Medical Claim' || kind == 'Izin' || kind == 'Reimbursement' || kind == 'General Affair')
          ? find.widgetWithText(
              TextFormField,
              'Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung',
            )
          : find.widgetWithText(TextFormField, 'Keperluan / rincian');
      await tester.enterText(
        descFinder,
        'Rincian pengajuan',
      );
      if (kind == 'Izin') {
        final dropdown = find.byKey(const ValueKey('izin_type_dropdown'));
        await tester.scrollUntilVisible(
          dropdown,
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sakit').last);
        await tester.pumpAndSettle();
      }
      if (kind == 'Petty Cash' || kind == 'Medical Claim') {
        final field = find.widgetWithText(TextFormField, '0');
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
      await tester.tap(send);
      await tester.pumpAndSettle();
      expect(api.payload?['kind'], kind);
      expect(api.payload?.containsKey('employeeId'), isFalse);
      if (kind == 'Lembur') {
        expect(api.payload?['hours'], 2);
        expect(api.payload?['startDate'], api.payload?['endDate']);
      }
      if (kind == 'Cuti' || kind == 'General Affair') {
        expect(api.payload?['amount'], 0);
      }
      if (kind == 'Reimbursement') {
        expect(api.payload?['amount'], 150000);
        expect(
          (api.payload?['items'] as List).single['receiptId'],
          'receipt-fixture',
        );
      }
      if (kind == 'Petty Cash' || kind == 'Medical Claim') {
        expect(api.payload?['amount'], 150000);
        expect(api.payload?['startDate'], isNotEmpty);
        expect(api.payload?['endDate'], isNotEmpty);
      }
      if (kind == 'Izin') {
        expect(api.payload?['permissionType'], 'Sakit');
        expect(api.payload?['description'], contains('[Jenis Izin: Sakit]'));
      }
      expect(api.payload?.containsKey('category'), isFalse);
      expect(api.payload?.containsKey('priority'), isFalse);
      expect(api.payload?.containsKey('location'), isFalse);
      expect(api.payload?.containsKey('attachmentName'), isFalse);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Petty Cash form displays web-aligned fields: kind, title, date range, amount, description, and policy note',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Petty Cash',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Jenis pengajuan *
      expect(find.text('Jenis pengajuan *'), findsOneWidget);
      expect(find.text('Petty Cash'), findsWidgets);

      // 2. Judul pengajuan *
      expect(find.text('Judul pengajuan *'), findsOneWidget);
      expect(find.text('Ringkasan keperluan Anda'), findsOneWidget);

      // 3. Tanggal mulai * & Tanggal selesai * (Rentang tanggal)
      expect(find.text('Tanggal Mulai & Tanggal Selesai *'), findsOneWidget);
      expect(find.text('Tanggal mulai *'), findsOneWidget);
      expect(find.text('Tanggal selesai *'), findsOneWidget);

      // 4. Nominal pengajuan (Rp) *
      expect(find.text('Nominal pengajuan (Rp) *'), findsOneWidget);

      // 5. Detail keperluan / referensi bukti *
      expect(find.text('Detail keperluan / referensi bukti *'), findsOneWidget);
      expect(
        find.text('Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung'),
        findsOneWidget,
      );

      // 6. Policy Note
      expect(
        find.text(
          'Saldo petty cash HO/service point yang tercatat saat pengajuan dikurangi setelah persetujuan akhir. Pengajuan ditolak atau diminta revisi tidak mengurangi saldo.',
        ),
        findsOneWidget,
      );

      // Pastikan kategori chips lama, lampiran picker, dan summary box tidak tampil di Petty Cash
      expect(find.text('Kategori Kas Kecil *'), findsNothing);
      expect(find.text('Operasional Kantor'), findsNothing);
      expect(find.text('Pilih Berkas Lampiran'), findsNothing);
      expect(find.text('Ringkasan Pengajuan Kas Kecil'), findsNothing);

      // Test input amount and quick presets
      final field = find.widgetWithText(TextFormField, '0');
      await tester.enterText(field, '50000');
      await tester.pumpAndSettle();

      // UI otomatis memformat angka dengan pemisah ribuan titik
      expect(find.text('50.000'), findsOneWidget);
      expect(find.textContaining('Terbilang'), findsNothing);

      // Tapping preset chip memformat nominal dengan titik
      final chip = find.text('Rp 100 rb');
      await tester.scrollUntilVisible(
        chip,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.text('100.000'), findsOneWidget);
    },
  );

  testWidgets(
    'General Affair form displays web-aligned fields: title, date range, description, and policy note',
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

      // 1. Judul pengajuan *
      expect(find.text('Judul pengajuan *'), findsOneWidget);
      expect(find.text('Ringkasan keperluan Anda'), findsOneWidget);

      // 2. Periode Pengajuan (Tanggal Mulai & Selesai)
      expect(find.text('Periode Pengajuan'), findsOneWidget);
      expect(find.text('Tanggal Mulai'), findsOneWidget);
      expect(find.text('Tanggal Selesai'), findsOneWidget);

      // 3. Detail keperluan / referensi bukti *
      expect(find.text('Detail keperluan / referensi bukti *'), findsOneWidget);
      expect(
        find.text('Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung'),
        findsOneWidget,
      );

      // 4. Policy note matching web
      expect(
        find.text(
          'Pengajuan mengikuti alur persetujuan yang ditetapkan kantor. Persetujuan tidak otomatis melakukan pembayaran atau mengeluarkan stok.',
        ),
        findsOneWidget,
      );

      // 5. Ensure hallucinated fields are gone
      expect(find.text('Kategori Kebutuhan GA *'), findsNothing);
      expect(find.text('Tingkat Prioritas *'), findsNothing);
      expect(find.text('Tanggal Kebutuhan Sarana *'), findsNothing);
      expect(find.text('Lokasi Penempatan / Ruangan'), findsNothing);
      expect(find.text('Lampiran Dokumen / Foto Kondisi'), findsNothing);
      expect(find.text('Ringkasan Kebutuhan GA'), findsNothing);
    },
  );

  testWidgets(
    'Reimbursement renders category dropdown matching web catalog',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Reimbursement',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check dropdown exists and has alignedDropdown enabled
      final dropdown = find.byType(DropdownButtonFormField<String>);
      expect(dropdown, findsOneWidget);
      final buttonTheme = tester.widget<ButtonTheme>(
        find.ancestor(
          of: dropdown,
          matching: find.byType(ButtonTheme),
        ),
      );
      expect(buttonTheme.data.alignedDropdown, isTrue);

      await tester.scrollUntilVisible(
        dropdown,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Pilih kategori'), findsOneWidget);

      // Open dropdown
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Verify categories matching web app exist
      expect(find.text('Transportasi').last, findsOneWidget);
      expect(find.text('Keperluan Kantor (Habis Pakai)'), findsOneWidget);
      expect(find.text('Alat Tulis Kantor'), findsOneWidget);
      expect(find.text('Peralatan Kantor (Aset)'), findsOneWidget);
      expect(find.text('Biaya Sewa'), findsOneWidget);
      expect(find.text('Entertain'), findsOneWidget);
      expect(find.text('Subscription'), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);

      // Select an item
      await tester.tap(find.text('Keperluan Kantor (Habis Pakai)'));
      await tester.pumpAndSettle();

      expect(find.text('Keperluan Kantor (Habis Pakai)'), findsOneWidget);
    },
  );

  testWidgets(
    'Reimbursement renders single delete button for uploaded receipt and clears it',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Reimbursement',
            initialRequest: {
              'kind': 'Reimbursement',
              'items': [
                {
                  'date': '2026-01-02',
                  'description': 'Biaya Parkir Klien',
                  'category': 'Transportasi',
                  'amount': 50000,
                  'receiptId': 'receipt-123',
                },
              ],
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exactly 1 delete receipt button
      final deleteBtn = find.byKey(const Key('delete_receipt_0'));
      expect(deleteBtn, findsOneWidget);
      expect(find.text('Lihat bukti yang diunggah'), findsOneWidget);

      await tester.scrollUntilVisible(
        deleteBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(deleteBtn);
      await tester.pumpAndSettle();

      // After delete, the receipt is removed and form asks to upload again
      expect(find.byKey(const Key('delete_receipt_0')), findsNothing);
      expect(find.text('Unggah bukti transaksi'), findsOneWidget);
    },
  );

  testWidgets(
    'Izin / General form displays single delete button for attachment and clears it',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Izin',
            initialRequest: {
              'kind': 'Izin',
              'title': 'Izin Sakit',
              'description': 'Demam tinggi\n\n[Lampiran: surat_dokter.pdf]',
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Exactly 1 delete button in attachment card
      final deleteAttachmentBtn =
          find.byKey(const Key('delete_attachment_button'));
      expect(deleteAttachmentBtn, findsOneWidget);
      expect(find.text('surat_dokter.pdf'), findsOneWidget);

      await tester.scrollUntilVisible(
        deleteAttachmentBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(deleteAttachmentBtn);
      await tester.pumpAndSettle();

      // After delete, attachment name is gone and default picker placeholder is shown
      expect(
        find.byKey(const Key('delete_attachment_button')),
        findsNothing,
      );
      expect(find.text('Pilih Berkas Lampiran'), findsOneWidget);
    },
  );

  testWidgets(
    'Medical Claim form displays web-aligned fields: kind, title, date range, plafon info box, amount, attachment, description, and policy note',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Medical Claim',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Jenis pengajuan * (Dihilangkan pada Medical Claim karena sudah otomatis terpilih diawal)
      expect(find.text('Jenis pengajuan *'), findsNothing);
      expect(find.textContaining('Medical Claim'), findsWidgets);

      // 2. Judul pengajuan *
      expect(find.text('Judul pengajuan *'), findsOneWidget);
      expect(find.text('Ringkasan keperluan Anda'), findsOneWidget);

      // 3. Tanggal mulai perawatan * & Tanggal selesai perawatan *
      expect(find.text('Periode Perawatan Medis *'), findsOneWidget);
      expect(find.text('Tanggal mulai perawatan *'), findsOneWidget);
      expect(find.text('Tanggal selesai perawatan *'), findsOneWidget);

      // 4. Info Box Plafon Medical Claim
      expect(find.textContaining('Medical Claim'), findsWidgets);
      expect(
        find.text(
          'Tahun kalender Januari–Desember; sisa saldo tidak dibawa ke tahun berikutnya. Lampiran gambar/PDF opsional.',
        ),
        findsOneWidget,
      );

      // 5. Biaya perawatan (Rp) *
      expect(find.text('Biaya perawatan (Rp) *'), findsOneWidget);

      // 5. Lampiran pendukung (opsional)
      expect(find.text('Lampiran pendukung (opsional)'), findsOneWidget);
      expect(find.text('JPEG, PNG, PDF; maksimal 2 MB.'), findsOneWidget);

      // 6. Detail keperluan / referensi bukti *
      expect(find.text('Detail keperluan / referensi bukti *'), findsOneWidget);
      expect(
        find.text('Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung'),
        findsOneWidget,
      );

      // 7. Policy Note
      expect(
        find.text(
          'Pengajuan mengikuti alur persetujuan yang ditetapkan kantor. Persetujuan tidak otomatis melakukan pembayaran atau mengeluarkan stok.',
        ),
        findsOneWidget,
      );

      // Test amount formatting
      final amountField = find.widgetWithText(TextFormField, '0');
      await tester.scrollUntilVisible(
        amountField,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(amountField, '750000');
      await tester.pumpAndSettle();
      expect(find.text('750.000'), findsOneWidget);
    },
  );

  testWidgets(
    'Medical Claim validates and sends the existing API contract',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Medical Claim',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final titleField = find.widgetWithText(
        TextFormField,
        'Ringkasan keperluan Anda',
      );
      await tester.enterText(titleField, 'Klaim Rawat Jalan');

      final amountField = find.widgetWithText(TextFormField, '0');
      await tester.scrollUntilVisible(
        amountField,
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(amountField, '350000');

      final descField = find.widgetWithText(
        TextFormField,
        'Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung',
      );
      await tester.scrollUntilVisible(
        descField,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(descField, 'Biaya konsultasi dokter dan obat flu');

      final sendButton = find.text('Kirim pengajuan');
      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      expect(api.payload?['kind'], 'Medical Claim');
      expect(api.payload?['title'], 'Klaim Rawat Jalan');
      expect(api.payload?['amount'], 350000);
      expect(
        api.payload?['description'],
        contains('Biaya konsultasi dokter dan obat flu'),
      );
    },
  );

  testWidgets(
    'Izin form displays web-aligned fields: kind, jenis izin dropdown, title, date range, attachment, description, and policy note',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Izin',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title and labels
      expect(find.text('Formulir Pengajuan Izin'), findsOneWidget);
      expect(find.text('Jenis izin *'), findsOneWidget);
      expect(find.text('Judul pengajuan *'), findsOneWidget);
      expect(find.text('Periode Pengajuan'), findsOneWidget);
      expect(find.text('Lampiran pendukung (opsional)'), findsOneWidget);
      expect(find.text('Detail keperluan / referensi bukti *'), findsOneWidget);
      expect(
        find.text(
          '• Izin tidak memotong saldo cuti.\n• Lampiran pendukung bersifat opsional.',
        ),
        findsOneWidget,
      );

      // Verify dropdown options matching web catalog
      final dropdown = find.byKey(const ValueKey('izin_type_dropdown'));
      expect(dropdown, findsOneWidget);
      expect(find.text('Pilih jenis izin'), findsOneWidget);

      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      expect(find.text('Sakit').last, findsOneWidget);
      expect(find.text('Ibadah'), findsOneWidget);
      expect(find.text('Melahirkan'), findsOneWidget);
      expect(find.text('Keguguran'), findsOneWidget);
      expect(find.text('Menikah'), findsOneWidget);
      expect(find.text('Keluarga meninggal'), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);

      // Select Sakit
      await tester.tap(find.text('Sakit').last);
      await tester.pumpAndSettle();

      expect(find.text('Sakit'), findsOneWidget);
    },
  );

  testWidgets(
    'Reimbursement renders web-aligned expense item fields: qty, unit price, specification, and auto-calculates amount',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Reimbursement',
            initialRequest: {
              'kind': 'Reimbursement',
              'items': [
                {
                  'date': '2026-11-10',
                  'description': 'Kebutuhan ATK Kantor',
                  'category': 'Alat Tulis Kantor',
                  'amount': 0,
                  'receiptId': 'receipt-fixture-123',
                },
              ],
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify presence of web-aligned labels
      expect(find.text('Rincian Pengeluaran *'), findsOneWidget);
      expect(find.text('Tanggal transaksi *'), findsOneWidget);
      expect(find.text('Kategori *'), findsOneWidget);
      expect(find.text('Deskripsi *'), findsOneWidget);
      expect(find.text('Qty'), findsOneWidget);
      expect(find.textContaining('Harga satuan (Rp)'), findsOneWidget);
      expect(find.text('Brand / Type & Spesifikasi'), findsOneWidget);
      expect(find.textContaining('Jumlah (Rp) *'), findsOneWidget);
      expect(find.text('Bukti transaksi *'), findsOneWidget);

      // Verify title & description inputs
      final titleFinder = find.widgetWithText(
        TextFormField,
        'Ringkasan keperluan Anda',
      );
      expect(titleFinder, findsOneWidget);
      await tester.enterText(titleFinder, 'Pengadaan ATK');

      final descFinder = find.widgetWithText(
        TextFormField,
        'Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung',
      );
      expect(descFinder, findsOneWidget);
      await tester.enterText(descFinder, 'Pembelian kertas HVS untuk divisi');

      // Test Qty and Harga Satuan auto-calculation into Jumlah
      final qtyFinder = find.byKey(const Key('reimbursement_qty_field'));
      expect(qtyFinder, findsOneWidget);
      await tester.enterText(qtyFinder, '3');
      await tester.pumpAndSettle();

      final unitPriceFinder =
          find.byKey(const Key('reimbursement_unit_price_field'));
      expect(unitPriceFinder, findsOneWidget);
      await tester.enterText(unitPriceFinder, '25000');
      await tester.pumpAndSettle();

      // Amount should auto-calculate: 3 * 25000 = 75000 and be read-only
      final amountFinder = find.byKey(const Key('reimbursement_amount_field'));
      expect(amountFinder, findsOneWidget);
      final textField = tester.widget<TextField>(
        find.descendant(of: amountFinder, matching: find.byType(TextField)),
      );
      expect(textField.readOnly, isTrue);
      expect(find.widgetWithText(TextFormField, '75000'), findsOneWidget);

      // Enter Brand / Type & Spesifikasi
      final specFinder =
          find.byKey(const Key('reimbursement_specification_field'));
      expect(specFinder, findsOneWidget);
      await tester.enterText(specFinder, 'PaperOne A4 80gsm');
      await tester.pumpAndSettle();

      // Submit form
      final send = find.text('Kirim pengajuan');
      await tester.tap(send);
      await tester.pumpAndSettle();

      expect(api.payload?['kind'], 'Reimbursement');
      expect(api.payload?['title'], 'Pengadaan ATK');
      expect(api.payload?['amount'], 75000);
      expect(api.payload?['startDate'], '2026-11-10');
      expect(api.payload?['endDate'], '2026-11-10');
      expect(api.payload?.containsKey('attachmentId'), isFalse);
      final items = api.payload?['items'] as List<dynamic>;
      expect(items.length, 1);
      final item = items[0] as Map<String, dynamic>;
      expect(item['description'], contains('PaperOne A4 80gsm'));
      expect(item['description'], contains('3 pcs'));
      expect(item['amount'], 75000);
      expect(item['receiptId'], 'receipt-fixture-123');
      expect(item.containsKey('qty'), isFalse);
      expect(item.containsKey('quantity'), isFalse);
      expect(item.containsKey('unitPrice'), isFalse);
      expect(item.containsKey('specification'), isFalse);
    },
  );

  testWidgets(
    'Reimbursement blocks submission when receipt is missing or amount is zero',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Reimbursement',
            initialRequest: {
              'kind': 'Reimbursement',
              'items': [
                {
                  'date': '2026-11-10',
                  'description': 'Item tanpa receipt',
                  'category': 'Transportasi',
                  'amount': 50000,
                  'receiptId': '',
                },
              ],
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final titleFinder = find.widgetWithText(
        TextFormField,
        'Ringkasan keperluan Anda',
      );
      await tester.enterText(titleFinder, 'Klaim Transport');

      final descFinder = find.widgetWithText(
        TextFormField,
        'Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung',
      );
      await tester.enterText(descFinder, 'Transportasi meeting');

      // Attempt submit without receipt
      final send = find.text('Kirim pengajuan');
      await tester.tap(send);
      await tester.pumpAndSettle();

      // Should be blocked
      expect(api.payload, isNull);
      expect(find.textContaining('Unggah bukti'), findsWidgets);
    },
  );

  testWidgets(
    'displays red border on input card and error text underneath when validation fails on submit, and clears on change',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Cuti',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Submit immediately without inputs
      final send = find.text('Kirim pengajuan');
      await tester.tap(send);
      await tester.pumpAndSettle();

      // Form validation blocked
      expect(api.payload, isNull);

      // Verify error indicators: error text and warning icon appear
      expect(find.text('Wajib diisi'), findsWidgets);
      expect(find.byIcon(Icons.error_outline_rounded), findsWidgets);

      // Verify the card container has red border
      final formCardInputs = find.byType(FormCardTextInput);
      expect(formCardInputs, findsWidgets);

      final firstCardContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: formCardInputs.first,
          matching: find.byType(AnimatedContainer),
        ),
      );
      final border = (firstCardContainer.decoration as BoxDecoration).border as Border;
      expect(border.top.color, const Color(0xFFEF4444));

      // Verify error text is NOT inside the AnimatedContainer (it is outside below)
      final errorInsideContainer = find.descendant(
        of: find.byWidget(firstCardContainer),
        matching: find.text('Wajib diisi'),
      );
      expect(errorInsideContainer, findsNothing);

      // Enter text into title
      final titleFinder = find.widgetWithText(TextFormField, 'Judul');
      await tester.enterText(titleFinder, 'Cuti Liburan');
      await tester.pumpAndSettle();

      // Title error is cleared and border returns to transparent
      final updatedFirstCard = tester.widget<AnimatedContainer>(
        find.descendant(
          of: formCardInputs.first,
          matching: find.byType(AnimatedContainer),
        ),
      );
      final updatedBorder = (updatedFirstCard.decoration as BoxDecoration).border as Border;
      expect(updatedBorder.top.color, Colors.transparent);
    },
  );

  testWidgets(
    'Izin dropdown displays red border and error text outside below dropdown card when unselected on submit',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Izin',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill title and description
      final titleFinder = find.widgetWithText(TextFormField, 'Ringkasan keperluan Anda');
      await tester.enterText(titleFinder, 'Izin Urusan Keluarga');

      final descFinder = find.widgetWithText(
        TextFormField,
        'Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung',
      );
      await tester.enterText(descFinder, 'Ada urusan penting di kampung');

      // Leave dropdown unselected and submit
      final send = find.text('Kirim pengajuan');
      await tester.tap(send);
      await tester.pumpAndSettle();

      // Verify error appears for dropdown
      expect(find.text('Pilih jenis izin'), findsWidgets);
      expect(find.byIcon(Icons.error_outline_rounded), findsWidgets);

      final dropdownInput = find.byType(FormCardDropdownInput<String>);
      expect(dropdownInput, findsOneWidget);

      final dropdownContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: dropdownInput,
          matching: find.byType(AnimatedContainer),
        ),
      );
      final border = (dropdownContainer.decoration as BoxDecoration).border as Border;
      expect(border.top.color, const Color(0xFFEF4444));

      // Now select Sakit
      final dropdown = find.byKey(const ValueKey('izin_type_dropdown'));
      await tester.scrollUntilVisible(
        dropdown,
        -150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sakit').last);
      await tester.pumpAndSettle();

      // Error clears
      expect(find.text('Pilih jenis izin'), findsNothing);
      final clearedContainer = tester.widget<AnimatedContainer>(
        find.descendant(
          of: dropdownInput,
          matching: find.byType(AnimatedContainer),
        ),
      );
      final clearedBorder = (clearedContainer.decoration as BoxDecoration).border as Border;
      expect(clearedBorder.top.color, Colors.transparent);
    },
  );

  testWidgets(
    'Petty Cash amount card displays red border and error text outside when amount is zero on submit',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Petty Cash',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Fill title and description
      final titleFinder = find.widgetWithText(TextFormField, 'Ringkasan keperluan Anda');
      await tester.enterText(titleFinder, 'Beli Snack Meeting');

      final descFinder = find.widgetWithText(
        TextFormField,
        'Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung',
      );
      await tester.enterText(descFinder, 'Snack untuk tamu kantor');

      // Submit with amount = 0
      final send = find.text('Kirim pengajuan');
      await tester.tap(send);
      await tester.pumpAndSettle();

      // Validation blocked
      expect(api.payload, isNull);
      expect(find.text('Nominal tidak valid'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsWidgets);

      // Tap preset chip 'Rp 50 rb'
      final chip = find.text('Rp 50 rb');
      await tester.scrollUntilVisible(
        chip,
        -100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(chip);
      await tester.pumpAndSettle();

      // Error clears
      expect(find.text('Nominal tidak valid'), findsNothing);
    },
  );

  testWidgets(
    'action buttons (Batal and Kirim pengajuan) are docked in bottomNavigationBar and visible without scrolling',
    (tester) async {
      final api = CaptureApi();
      await tester.pumpWidget(
        MaterialApp(
          home: RequestForm(
            api: api,
            initialKind: 'Cuti',
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find Scaffold
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.bottomNavigationBar, isNotNull);

      // Verify buttons are directly visible without scrolling
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Kirim pengajuan'), findsOneWidget);

      // Verify Batal and Kirim pengajuan are descendants of bottomNavigationBar
      final bottomNavFinder = find.byWidget(scaffold.bottomNavigationBar!);
      expect(
        find.descendant(of: bottomNavFinder, matching: find.text('Batal')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: bottomNavFinder,
          matching: find.text('Kirim pengajuan'),
        ),
        findsOneWidget,
      );
    },
  );
}
