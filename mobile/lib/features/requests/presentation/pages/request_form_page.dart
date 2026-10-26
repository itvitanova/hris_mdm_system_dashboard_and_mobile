import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../widgets/receipt_preview.dart';

const requestKinds = [
  'Cuti',
  'Reimbursement',
  'Petty Cash',
  'General Affair',
  'Lembur',
];

class RequestForm extends StatefulWidget {
  const RequestForm({
    super.key,
    required this.api,
    this.initialKind = 'Cuti',
    this.initialRequest,
    this.workspace,
  });
  final ApiClient api;
  final String initialKind;
  final Json? initialRequest;
  final Workspace? workspace;
  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      description = TextEditingController(),
      amount = TextEditingController(),
      hours = TextEditingController();
  late String kind = text(
    widget.initialRequest ?? {},
    'kind',
    widget.initialKind,
  );
  DateTime start = DateTime.now(), end = DateTime.now();
  bool busy = false;
  late final kindSearch = TextEditingController(text: kind);
  bool uploading = false;
  final expenses = <ExpenseDraft>[];
  @override
  void initState() {
    super.initState();
    final r = widget.initialRequest;
    if (r != null) {
      title.text = text(r, 'title', '');
      description.text = text(r, 'description', '');
      amount.text = number(r, 'amount').toInt().toString();
      hours.text = number(r, 'hours').toString();
      start = DateTime.tryParse(text(r, 'startDate', '')) ?? start;
      end = DateTime.tryParse(text(r, 'endDate', '')) ?? end;
    }
    final items = (r?['items'] as List?) ?? [];
    for (final item in items) {
      expenses.add(ExpenseDraft(Json.from(item as Map)));
    }
    if (expenses.isEmpty) expenses.add(ExpenseDraft({}));
  }

  Future<void> upload(ExpenseDraft item) async {
    if (busy || uploading) return;
    setState(() => uploading = true);
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
      );
      if (file == null) return;
      final size = await file.length();
      if (size == null || size <= 0 || size > 2 * 1024 * 1024) {
        throw ApiException('Bukti transaksi maksimal 2 MB.');
      }
      final bytes = await file.readAsBytes();
      final result = await widget.api.postJson('/request-receipts', {
        'name': file.name,
        'fileBase64': base64Encode(bytes),
      });
      if (mounted) {
        setState(() {
          item.receiptId = text(result, 'id', '');
          item.receiptName = file.name;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> expenseDate(ExpenseDraft item) async {
    final next = await showDatePicker(
      context: context,
      initialDate: item.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (next != null && mounted) setState(() => item.date = next);
  }

  String? error;
  bool get hasAmount => ['Petty Cash', 'General Affair'].contains(kind);
  @override
  void dispose() {
    for (final c in [title, description, amount, hours, kindSearch]) {
      c.dispose();
    }
    for (final expense in expenses) {
      expense.dispose();
    }
    super.dispose();
  }

  Future<void> pickDate(bool isStart) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? start : end,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) {
      setState(() {
        if (isStart) {
          start = date;
          if (end.isBefore(start)) end = start;
        } else {
          end = date;
        }
        if (kind == 'Lembur') end = start;
      });
    }
  }

  Future<void> submit() async {
    if (!form.currentState!.validate() || busy || uploading) return;
    if (kind == "Reimbursement" && expenses.any((e) => e.receiptId.isEmpty)) {
      setState(() => error = "Unggah bukti untuk setiap rincian pengeluaran.");
      return;
    }
    if (end.isBefore(start)) {
      setState(
        () => error = 'Tanggal selesai tidak boleh sebelum tanggal mulai.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.post('/requests', {
        'id': widget.initialRequest?['id'] ?? '',
        'revision': widget.initialRequest?['revision'] ?? 0,
        'items': kind == 'Reimbursement'
            ? expenses.map((e) => e.json()).toList()
            : [],
        'kind': kind,
        'title': title.text.trim(),
        'description': description.text.trim(),
        'startDate': dateOnly(start),
        'endDate': dateOnly(kind == 'Lembur' ? start : end),
        'amount': kind == 'Reimbursement'
            ? expenses.fold<int>(
                0,
                (sum, e) => sum + (int.tryParse(e.amount.text) ?? 0),
              )
            : hasAmount
            ? int.tryParse(amount.text) ?? 0
            : 0,
        'hours': kind == 'Lembur'
            ? double.parse(hours.text.replaceAll(',', '.'))
            : 0,
      });
      if (mounted) {
        notify(context, 'Pengajuan berhasil dikirim.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.initialRequest == null ? 'Buat pengajuan' : 'Perbaiki pengajuan',
      ),
    ),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionHeading(
            widget.initialRequest == null
                ? 'Ajukan kebutuhan Anda'
                : 'Lengkapi perbaikan pengajuan',
            subtitle:
                'Isi rincian dan periksa bukti sebelum dikirim ke peninjau.',
          ),
          const SizedBox(height: 24),
          DropdownMenu<String>(
            controller: kindSearch,
            enabled: !busy && !uploading,
            initialSelection: kind,
            expandedInsets: EdgeInsets.zero,
            enableFilter: true,
            enableSearch: true,
            requestFocusOnTap: true,
            label: const Text('Jenis pengajuan'),
            dropdownMenuEntries: requestKinds
                .map((k) => DropdownMenuEntry(value: k, label: k))
                .toList(),
            onSelected: busy
                ? null
                : (v) {
                    if (v == null) {
                      kindSearch.text = kind;
                      return;
                    }
                    setState(() {
                      kind = v;
                      if (kind == 'Lembur') end = start;
                    });
                  },
          ),
          const SizedBox(height: 16),
          const SectionHeading('Informasi pengajuan'),
          const SizedBox(height: 12),
          TextFormField(
            controller: title,
            maxLength: 160,
            decoration: const InputDecoration(labelText: 'Judul'),
            validator: requiredText,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: description,
            maxLines: 4,
            maxLength: 2000,
            decoration: const InputDecoration(labelText: 'Keperluan / rincian'),
            validator: requiredText,
          ),
          const SizedBox(height: 20),
          if (kind != 'Reimbursement') ...[
            const SectionHeading('Waktu pengajuan'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: busy || uploading ? null : () => pickDate(true),
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                '${kind == 'Lembur' ? 'Tanggal' : 'Mulai'}: ${dateOnly(start)}',
              ),
            ),
            if (kind != 'Lembur')
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: busy || uploading ? null : () => pickDate(false),
                  icon: const Icon(Icons.event_outlined),
                  label: Text('Selesai: ${dateOnly(end)}'),
                ),
              ),
          ],
          if (kind == 'Reimbursement') ...[
            const SectionHeading('Rekening reimbursement'),
            const SizedBox(height: 8),
            Text(
              widget.workspace == null
                  ? 'Rekening diambil dari data karyawan. Hubungi HR jika belum lengkap.'
                  : '${text(widget.workspace!.employee, 'bankName', 'Belum lengkap')} · ${text(widget.workspace!.employee, 'bankAccountName', '')} · ${text(widget.workspace!.employee, 'bankAccountNumber', '')}',
            ),
            const SizedBox(height: 20),
            const SectionHeading('Rincian pengeluaran'),
            for (var i = 0; i < expenses.length; i++)
              expenseFields(expenses[i], i),
            OutlinedButton.icon(
              onPressed: busy || uploading || expenses.length >= 150
                  ? null
                  : () => setState(() => expenses.add(ExpenseDraft({}))),
              icon: const Icon(Icons.add),
              label: const Text('Tambah rincian'),
            ),
            DetailLine(
              'Total klaim',
              rupiah(
                expenses.fold<int>(
                  0,
                  (sum, e) => sum + (int.tryParse(e.amount.text) ?? 0),
                ),
              ),
            ),
            const Text(
              'Setiap rincian wajib disertai bukti transaksi. Ketentuan template: maksimal 14 hari kerja setelah transaksi; peninjau memeriksa kesesuaiannya.',
              style: TextStyle(color: muted),
            ),
          ],
          if (hasAmount)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                controller: amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  helperText: 'Masukkan angka tanpa titik atau koma.',
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '') ?? 0;
                  return n < (kind == 'General Affair' ? 0 : 1) ||
                          n > 1000000000000
                      ? 'Nominal tidak valid'
                      : null;
                },
              ),
            ),
          if (kind == 'Lembur')
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: TextFormField(
                controller: hours,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Durasi lembur (jam)',
                  helperText: 'Satu tanggal per pengajuan; maksimal 24 jam.',
                ),
                validator: (v) {
                  final n = double.tryParse((v ?? '').replaceAll(',', '.'));
                  return n == null || !n.isFinite || n <= 0 || n > 24
                      ? 'Isi durasi lebih dari 0 hingga 24 jam'
                      : null;
                },
              ),
            ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: ErrorNotice(error!),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: busy || uploading ? null : submit,
            child: Text(busy ? 'Mengirim…' : 'Kirim pengajuan'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
  Widget expenseFields(ExpenseDraft item, int index) => Panel(
    key: ObjectKey(item),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeading('Pengeluaran ${index + 1}'),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: busy || uploading ? null : () => expenseDate(item),
          icon: const Icon(Icons.calendar_today_outlined),
          label: Text('Tanggal transaksi: ${dateOnly(item.date)}'),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: item.description,
          enabled: !busy && !uploading,
          maxLength: 500,
          decoration: const InputDecoration(labelText: 'Deskripsi pengeluaran'),
          validator: requiredText,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: item.category,
          enabled: !busy && !uploading,
          maxLength: 80,
          decoration: const InputDecoration(labelText: 'Kategori pengeluaran'),
          validator: requiredText,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: item.amount,
          enabled: !busy && !uploading,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: const InputDecoration(
            labelText: 'Jumlah pengeluaran (Rp)',
          ),
          onChanged: (_) => setState(() {}),
          validator: (v) {
            final n = int.tryParse(v ?? '') ?? 0;
            return n < 1 || n > 1000000000000 ? 'Isi jumlah yang valid' : null;
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: busy || uploading ? null : () => upload(item),
          icon: const Icon(Icons.attach_file),
          label: Text(
            item.receiptId.isEmpty
                ? 'Unggah bukti transaksi'
                : 'Ganti bukti transaksi',
          ),
        ),
        Text(
          item.receiptId.isEmpty
              ? 'JPEG, PNG, atau PDF; maksimal 2 MB'
              : item.receiptName,
        ),
        if (item.receiptId.isNotEmpty)
          TextButton.icon(
            onPressed: busy || uploading
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReceiptPreview(
                        api: widget.api,
                        path:
                            '/request-receipts/${Uri.encodeComponent(item.receiptId)}',
                      ),
                    ),
                  ),
            icon: const Icon(Icons.image_search_outlined),
            label: const Text('Lihat bukti yang diunggah'),
          ),
        if (expenses.length > 1)
          TextButton(
            onPressed: busy || uploading
                ? null
                : () {
                    setState(() => expenses.remove(item));
                    item.dispose();
                  },
            child: Text('Hapus rincian ${index + 1}'),
          ),
      ],
    ),
  );
  String? requiredText(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
}

class ExpenseDraft {
  ExpenseDraft(Json row)
    : description = TextEditingController(text: text(row, 'description', '')),
      category = TextEditingController(text: text(row, 'category', '')),
      amount = TextEditingController(
        text: number(row, 'amount') > 0
            ? number(row, 'amount').toInt().toString()
            : '',
      ),
      date = DateTime.tryParse(text(row, 'date', '')) ?? DateTime.now(),
      receiptId = text(row, 'receiptId', '');
  final TextEditingController description, category, amount;
  DateTime date;
  String receiptId;
  String receiptName = 'Bukti tersimpan';
  Json json() => {
    'date': dateOnly(date),
    'description': description.text.trim(),
    'category': category.text.trim(),
    'amount': int.tryParse(amount.text) ?? 0,
    'receiptId': receiptId,
  };
  void dispose() {
    description.dispose();
    category.dispose();
    amount.dispose();
  }
}

typedef RequestFormPage = RequestForm;
