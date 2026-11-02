import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/widgets/core_widgets.dart';
import 'request_form_page.dart';
import '../widgets/approval_step_summary.dart';
import '../widgets/receipt_preview.dart';

class RequestDetailScreen extends StatefulWidget {
  const RequestDetailScreen({
    super.key,
    required this.api,
    required this.request,
    required this.own,
  });
  final ApiClient api;
  final Json request;
  final bool own;
  @override
  State<RequestDetailScreen> createState() => _RequestDetailState();
}

class _RequestDetailState extends State<RequestDetailScreen> {
  late Json request = widget.request;
  bool busy = false;
  String? error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => markSeen());
  }

  Future<void> markSeen() async {
    final token = text(request, 'updateToken', '');
    if (!widget.own || request['unread'] != true || token.length != 64) return;
    try {
      await widget.api.post(
        '/requests/${Uri.encodeComponent(text(request, 'id'))}/seen',
        {'token': token},
      );
      if (mounted) setState(() => request = {...request, 'unread': false});
    } catch (_) {
      /* Keep the update unread when acknowledgement cannot reach the server. */
    }
  }

  Future<void> refresh() async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final w = Workspace(await widget.api.workspace());
      final matches = w.rows('requests').where((r) => r['id'] == request['id']);
      if (matches.isEmpty) {
        throw ApiException(
          'Pengajuan tidak ditemukan atau akses sudah berubah.',
        );
      }
      if (mounted) {
        setState(() {
          request = matches.first;
          error = null;
        });
        await markSeen();
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  List<Json> records(dynamic value) =>
      ((value as List?) ?? []).map((v) => Json.from(v as Map)).toList();
  Future<void> decide(String decision) async {
    final note = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        title: Text(
          decision == 'Disetujui'
              ? 'Setujui pengajuan'
              : decision == 'Perlu revisi'
              ? 'Minta revisi'
              : 'Tolak pengajuan',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text(request, 'title')),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                maxLines: 3,
                maxLength: 2000,
                decoration: InputDecoration(
                  labelText: decision == 'Disetujui'
                      ? 'Catatan (opsional)'
                      : 'Catatan wajib diisi',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, note.text.trim()),
            child: const Text('Simpan keputusan'),
          ),
        ],
      ),
    );
    // The dialog can finish its reverse transition before its controller is disposed.
    await Future<void>.delayed(const Duration(milliseconds: 250));
    note.dispose();
    if (result == null || !mounted) return;
    if (decision != 'Disetujui' && result.isEmpty) {
      setState(() => error = 'Isi alasan penolakan atau revisi.');
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.api.post(
        '/requests/${Uri.encodeComponent(text(request, 'id'))}/review',
        {
          'status': decision,
          'note': result,
          'revision': request['revision'] ?? 0,
        },
      );
      if (mounted) {
        notify(context, 'Keputusan tersimpan.');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> share(String path, String name) async {
    setState(() {
      busy = true;
      error = null;
    });
    File? file;
    try {
      final result = await widget.api.requestFile(path);
      final dir = await getTemporaryDirectory();
      final extension = result.contentType.contains('pdf')
          ? '.pdf'
          : result.contentType.contains('png')
          ? '.png'
          : result.contentType.contains('jpeg')
          ? '.jpg'
          : '';
      final fileName = name.contains('.') ? name : '$name$extension';
      file = File(
        '${dir.path}/${DateTime.now().microsecondsSinceEpoch}-$fileName',
      );
      await file.writeAsBytes(result.bytes, flush: true);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: result.contentType)],
          subject: text(request, 'title'),
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (file != null && await file.exists()) await file.delete();
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = request;
    final id = Uri.encodeComponent(text(r, 'id'));
    final snapshot = Json.from((r['snapshot'] as Map?) ?? {});
    final items = records(r['items']);
    final steps = records(r['steps']);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail pengajuan'),
        actions: [
          IconButton(
            tooltip: 'Segarkan pengajuan',
            onPressed: busy ? null : refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        text(r, 'kind'),
                        style: const TextStyle(
                          color: brand,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      StatusPill(text(r, 'status')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    text(r, 'title'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    text(r, 'employeeName'),
                    style: const TextStyle(color: muted),
                  ),
                  if (number(r, 'amount') > 0) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Total pengajuan',
                      style: TextStyle(color: muted),
                    ),
                    Text(
                      rupiah(number(r, 'amount')),
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: brand),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Diajukan ${requestDateLabel(text(r, 'createdAt'))}',
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (text(r, 'pendingWith', '').isNotEmpty)
              Panel(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.schedule_outlined, color: brand),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text(r, 'pendingWith'),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            if (text(r, 'reviewNote', '').isNotEmpty)
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r['status'] == 'Perlu revisi'
                          ? 'Perlu diperbaiki'
                          : 'Catatan peninjau',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Text(text(r, 'reviewNote')),
                  ],
                ),
              ),
            Panel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionHeading('Ringkasan pengajuan'),
                  const SizedBox(height: 12),
                  _RequestInfo('Keperluan', text(r, 'description')),
                  _RequestInfo(
                    'Periode',
                    '${requestDateLabel(text(r, 'startDate'))} – ${requestDateLabel(text(r, 'endDate'))}',
                  ),
                ],
              ),
            ),
            if (snapshot.isNotEmpty)
              ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 20),
                title: const Text('Data pemohon dan rekening'),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _RequestInfo(
                          'Pemohon',
                          text(snapshot, 'name', text(r, 'employeeName')),
                        ),
                        _RequestInfo(
                          'Departemen / jabatan',
                          '${text(snapshot, 'department')} · ${text(snapshot, 'position')}',
                        ),
                        _RequestInfo('Telepon', text(snapshot, 'phone')),
                        if (items.isNotEmpty) ...[
                          _RequestInfo('Bank', text(snapshot, 'bankName')),
                          _RequestInfo(
                            'Pemilik rekening',
                            text(snapshot, 'bankAccountName'),
                          ),
                          _RequestInfo(
                            'Nomor rekening',
                            text(snapshot, 'bankAccountNumber'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            if (items.isNotEmpty) ...[
              const SizedBox(height: 20),
              SectionHeading(
                'Rincian pengeluaran',
                subtitle:
                    '${items.length} rincian · ${rupiah(number(r, 'amount'))}',
              ),
              const SizedBox(height: 12),
            ],
            for (var i = 0; i < items.length; i++)
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeading('Pengeluaran ${i + 1}'),
                    _RequestInfo('Tanggal transaksi', text(items[i], 'date')),
                    _RequestInfo('Deskripsi', text(items[i], 'description')),
                    _RequestInfo('Kategori', text(items[i], 'category')),
                    _RequestInfo('Jumlah', rupiah(number(items[i], 'amount'))),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: busy
                          ? null
                          : () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReceiptPreview(
                                  api: widget.api,
                                  path:
                                      '/requests/$id/receipts/${Uri.encodeComponent(text(items[i], 'receiptId'))}',
                                  title: 'Bukti pengeluaran ${i + 1}',
                                ),
                              ),
                            ),
                      icon: const Icon(Icons.image_search_outlined),
                      label: const Text('Lihat bukti transaksi'),
                    ),
                  ],
                ),
              ),
            if (steps.isNotEmpty) const SectionHeading('Alur persetujuan'),
            const SizedBox(height: 12),
            for (var i = 0; i < steps.length; i++)
              Panel(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeading('${i + 1}. ${text(steps[i], 'name')}'),
                    const SizedBox(height: 8),
                    if (records(steps[i]['approvers']).length > 1 ||
                        steps[i]['status'] != 'Menunggu' ||
                        r['status'] != 'Menunggu' ||
                        r['currentStep'] != i)
                      Text(
                        records(
                          steps[i]['approvers'],
                        ).map((v) => text(v, 'name')).join(', '),
                      ),
                    Text(
                      approvalStepSummary(
                        steps[i],
                        active: r['currentStep'] == i,
                        requestStatus: text(r, 'status'),
                      ),
                    ),
                    for (final d in records(steps[i]['decisions']))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${text(d, 'name')} · ${text(d, 'decision')}\n${requestDateLabel(text(d, 'at'))}\n${text(d, 'note', '')}',
                        ),
                      ),
                  ],
                ),
              ),
            if (records(r['history']).isNotEmpty)
              ExpansionTile(
                title: const Text('Riwayat pengajuan'),
                children: [
                  for (final h in records(r['history']))
                    ListTile(
                      title: Text(
                        '${text(h, 'name')} · ${text(h, 'decision')}',
                      ),
                      subtitle: Text(
                        '${requestDateLabel(text(h, 'at'))}\n${text(h, 'note', '')}',
                      ),
                    ),
                ],
              ),
            if (error != null) ErrorNotice(error!),
            if (busy)
              const Padding(
                padding: EdgeInsets.all(12),
                child: LinearProgressIndicator(),
              ),
            if (r['canReview'] == true) ...[
              FilledButton(
                onPressed: busy ? null : () => decide('Disetujui'),
                child: Text(
                  steps.isNotEmpty &&
                          steps[(r['currentStep'] as num).toInt()]['source'] ==
                              'finance'
                      ? 'Verifikasi finance'
                      : 'Setujui',
                ),
              ),
              const SizedBox(height: 12),
              if (r['version'] == 2)
                OutlinedButton(
                  onPressed: busy ? null : () => decide('Perlu revisi'),
                  child: const Text('Minta revisi'),
                ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: busy ? null : () => decide('Ditolak'),
                child: const Text('Tolak'),
              ),
            ],
            if (widget.own && r['status'] == 'Perlu revisi')
              FilledButton(
                onPressed: busy
                    ? null
                    : () async {
                        final changed = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                RequestForm(api: widget.api, initialRequest: r),
                          ),
                        );
                        if (changed == true && context.mounted) {
                          Navigator.pop(context, true);
                        }
                      },
                child: const Text('Perbaiki pengajuan'),
              ),
            if (r['canDownload'] == true) ...[
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () => share(
                        '/requests/$id/document/pdf',
                        'reimbursement.pdf',
                      ),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Simpan / bagikan PDF final'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: busy
                    ? null
                    : () => share(
                        '/requests/$id/document/xlsx',
                        'reimbursement.xlsx',
                      ),
                icon: const Icon(Icons.table_chart_outlined),
                label: const Text('Simpan / bagikan Excel final'),
              ),
            ],
            if (r['kind'] == 'Reimbursement')
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text(
                  r['version'] == 2
                      ? 'Dokumen final tersedia setelah persetujuan dan verifikasi finance. Persetujuan bukan bukti pembayaran.'
                      : 'Pengajuan lama belum memiliki rincian dan snapshot template. Dokumen otomatis tersedia untuk pengajuan baru.',
                  style: TextStyle(color: muted),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ApprovalsScreen extends StatefulWidget {
  const ApprovalsScreen({super.key, required this.api});
  final ApiClient api;
  @override
  State<ApprovalsScreen> createState() => _ApprovalsState();
}

class _ApprovalsState extends State<ApprovalsScreen> {
  Workspace? workspace;
  String? error;
  bool history = false;
  bool changed = false;
  String query = '';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final next = Workspace(await widget.api.workspace());
      if (mounted) {
        setState(() {
          workspace = next;
          error = null;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = workspace;
    final rows =
        w
            ?.rows('requests')
            .where(
              (r) =>
                  r['employeeId'] != w.actor['employeeId'] &&
                  (history
                      ? ((r['steps'] as List?) ?? []).any(
                          (s) => ((s['decisions'] as List?) ?? []).any(
                            (d) => d['employeeId'] == w.actor['employeeId'],
                          ),
                        )
                      : r['canReview'] == true),
            )
            .where(
              (r) =>
                  '${text(r, 'employeeName')} ${text(r, 'title')} ${text(r, 'kind')}'
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList() ??
        <Json>[];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan'),
        leading: Navigator.of(context).canPop()
            ? BackButton(onPressed: () => Navigator.pop(context, changed))
            : null,
        actions: [
          IconButton(
            tooltip: 'Segarkan persetujuan',
            onPressed: load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            children: [
              const SectionHeading(
                'Pengajuan tim',
                subtitle: 'Tinjau pengajuan yang menjadi tanggung jawab Anda.',
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Menunggu tindakan'),
                    selected: !history,
                    onSelected: (_) => setState(() => history = false),
                  ),
                  ChoiceChip(
                    label: const Text('Riwayat keputusan'),
                    selected: history,
                    onSelected: (_) => setState(() => history = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Cari pemohon atau pengajuan',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => query = v),
              ),
              const SizedBox(height: 16),
              if (error != null) ...[
                ErrorNotice(error!),
                TextButton(onPressed: load, child: const Text('Coba lagi')),
              ],
              if (w == null && error == null) const LinearProgressIndicator(),
              if (w != null && w.data['approvalAccess'] != true)
                const ErrorNotice(
                  'Anda belum ditetapkan sebagai pemberi persetujuan.',
                )
              else if (w != null && rows.isEmpty)
                const EmptyState('Tidak ada pengajuan yang sesuai.')
              else
                for (final r in rows)
                  Card(
                    child: ListTile(
                      isThreeLine: true,
                      title: Text(text(r, 'title')),
                      subtitle: Text(
                        '${text(r, 'employeeName')} · ${text(r, 'kind')}\n${text(r, 'status')}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RequestDetailScreen(
                              api: widget.api,
                              request: r,
                              own: false,
                            ),
                          ),
                        );
                        if (result == true) {
                          changed = true;
                          await load();
                        }
                      },
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

String requestDateLabel(String value) {
  final date = DateTime.tryParse(value);
  if (date == null) return value;
  final local = value.length > 10 ? date.toLocal() : date;
  final base =
      '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
  return value.length > 10
      ? '$base, ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}'
      : base;
}

class _RequestInfo extends StatelessWidget {
  const _RequestInfo(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: muted, fontSize: 12)),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: const TextStyle(color: ink, fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );
}

typedef RequestDetailPage = RequestDetailScreen;
typedef ApprovalsPage = ApprovalsScreen;
