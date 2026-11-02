import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/widgets/core_widgets.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key, required this.api, required this.slip});
  final ApiClient api;
  final Json slip;
  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  bool busy = false;
  Future<void> share() async {
    setState(() => busy = true);
    File? file;
    try {
      final bytes = await widget.api.payslip(text(widget.slip, 'id'));
      final directory = await getTemporaryDirectory();
      final period = text(
        widget.slip,
        'period',
      ).replaceAll(RegExp(r'[^0-9-]'), '');
      file = File(
        '${directory.path}/slip-$period-${DateTime.now().microsecondsSinceEpoch}.pdf',
      );
      await file.writeAsBytes(bytes, flush: true);
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'application/pdf')],
          subject: 'Slip gaji $period',
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (e) {
      if (mounted) notify(context, e);
    } finally {
      if (file != null && await file.exists()) await file.delete();
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.slip;
    final v2 = number(p, 'version') >= 2;
    return Scaffold(
      appBar: AppBar(title: const Text('Slip gaji')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gaji bersih',
                  style: TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                Text(
                  rupiah(number(p, 'netSalary')),
                  style: const TextStyle(
                    color: brand,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (text(p, 'status') != 'Final')
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Text(
                      'Draft: nilai masih dapat berubah dan bukan bukti pembayaran.',
                    ),
                  ),
              ],
            ),
          ),
          const SectionHeading('Rincian slip gaji'),
          const SizedBox(height: 16),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text(p, 'companyName', 'Perusahaan'),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (text(p, 'companyAddress', '').isNotEmpty)
                  Text(text(p, 'companyAddress')),
                const SizedBox(height: 16),
                StatusPill(text(p, 'status')),
                const SizedBox(height: 16),
                Text(
                  text(p, 'employeeName'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text('${text(p, 'period')} • ${text(p, 'department')}'),
                if (v2) DetailLine('Status PTKP', text(p, 'ptkp')),
              ],
            ),
          ),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pendapatan',
                  style: TextStyle(fontWeight: FontWeight.bold, color: brand),
                ),
                const SizedBox(height: 8),
                DetailLine('Gaji pokok', rupiah(number(p, 'baseSalary'))),
                if (v2) DetailLine('Tunjangan', rupiah(number(p, 'allowance'))),
                DetailLine('Lembur', rupiah(number(p, 'overtime'))),
                if (v2) DetailLine('Bonus', rupiah(number(p, 'bonus'))),
                if (!v2)
                  DetailLine(
                    'Reimbursement historis',
                    rupiah(number(p, 'reimbursement')),
                  ),
                const Divider(),
                DetailLine(
                  'Total pendapatan',
                  rupiah(
                    v2
                        ? number(p, 'grossSalary')
                        : number(p, 'baseSalary') +
                              number(p, 'overtime') +
                              number(p, 'reimbursement'),
                  ),
                ),
              ],
            ),
          ),
          Panel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Potongan',
                  style: TextStyle(fontWeight: FontWeight.bold, color: brand),
                ),
                const SizedBox(height: 8),
                if (v2) ...[
                  DetailLine(
                    number(p, 'pph21') < 0 ? 'Pengembalian PPh21' : 'PPh21',
                    p['taxReady'] == true
                        ? rupiah(number(p, 'pph21'))
                        : 'Belum lengkap',
                  ),
                  DetailLine(
                    'BPJS Kesehatan · 1%',
                    rupiah(number(p, 'bpjsHealth')),
                  ),
                  DetailLine('JHT · 2%', rupiah(number(p, 'jht'))),
                  DetailLine('JP · 1%', rupiah(number(p, 'jp'))),
                  const Divider(),
                ],
                DetailLine('Total potongan', rupiah(number(p, 'deductions'))),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: busy ? null : share,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: Text(busy ? 'Menyiapkan…' : 'Simpan / bagikan PDF'),
          ),
        ],
      ),
    );
  }
}

typedef PayslipPage = PayslipScreen;
