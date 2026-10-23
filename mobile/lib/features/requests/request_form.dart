import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/api_client.dart';
import '../../core/workspace.dart';
import '../../shared/widgets.dart';

const requestKinds = [
  'Cuti',
  'Reimbursement',
  'Petty Cash',
  'General Affair',
  'Lembur',
];

class RequestForm extends StatefulWidget {
  const RequestForm({super.key, required this.api, this.initialKind = 'Cuti'});
  final ApiClient api;
  final String initialKind;
  @override
  State<RequestForm> createState() => _RequestFormState();
}

class _RequestFormState extends State<RequestForm> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      description = TextEditingController(),
      amount = TextEditingController(),
      hours = TextEditingController();
  late String kind = widget.initialKind;
  DateTime start = DateTime.now(), end = DateTime.now();
  bool busy = false;
  String? error;
  bool get hasAmount =>
      ['Reimbursement', 'Petty Cash', 'General Affair'].contains(kind);
  @override
  void dispose() {
    for (final c in [title, description, amount, hours]) {
      c.dispose();
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
    if (!form.currentState!.validate() || busy) return;
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
        'kind': kind,
        'title': title.text.trim(),
        'description': description.text.trim(),
        'startDate': dateOnly(start),
        'endDate': dateOnly(kind == 'Lembur' ? start : end),
        'amount': hasAmount ? int.tryParse(amount.text) ?? 0 : 0,
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
    appBar: AppBar(title: const Text('Buat pengajuan')),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Apa yang Anda perlukan?',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pengajuan akan ditinjau oleh admin/HR.',
            style: TextStyle(color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: kind,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Jenis pengajuan'),
            items: requestKinds
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: busy
                ? null
                : (v) => setState(() {
                    kind = v!;
                    if (kind == 'Lembur') end = start;
                  }),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: busy ? null : () => pickDate(true),
            icon: const Icon(Icons.calendar_today_outlined),
            label: Text(
              '${kind == 'Lembur' ? 'Tanggal' : 'Mulai'}: ${dateOnly(start)}',
            ),
          ),
          if (kind != 'Lembur')
            OutlinedButton.icon(
              onPressed: busy ? null : () => pickDate(false),
              icon: const Icon(Icons.event_outlined),
              label: Text('Selesai: ${dateOnly(end)}'),
            ),
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
              child: Text(error!, style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: busy ? null : submit,
            child: Text(busy ? 'Mengirim…' : 'Kirim pengajuan'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),
  );
  String? requiredText(String? value) =>
      value == null || value.trim().isEmpty ? 'Wajib diisi' : null;
}
