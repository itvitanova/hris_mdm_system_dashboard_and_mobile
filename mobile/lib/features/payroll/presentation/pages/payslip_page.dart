import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  Widget _buildStatusBadge(String status) {
    final isFinal = status.toLowerCase() == 'final';
    final bg = isFinal ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final textCol = isFinal ? const Color(0xFF166534) : const Color(0xFF92400E);
    final borderCol = isFinal ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A);
    final icon = isFinal ? Icons.check_circle_rounded : Icons.schedule_rounded;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderCol, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: textCol),
          SizedBox(width: 4.w),
          Text(
            status,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSalaryCard(Json p) {
    final netSalary = number(p, 'netSalary');
    final isFinal = text(p, 'status', 'Final').toLowerCase() == 'final';

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E), // Teal 700
            Color(0xFF14B8A6), // Teal 500
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180F766E),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            right: -25.w,
            top: -25.h,
            child: Container(
              width: 115.w,
              height: 115.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -20.w,
            bottom: -30.h,
            child: Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(18.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 3.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 0.6,
                    ),
                  ),
                  child: Text(
                    'GAJI BERSIH (TAKE HOME PAY)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  rupiah(netSalary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      isFinal ? Icons.verified_rounded : Icons.info_outline_rounded,
                      size: 14.sp,
                      color: isFinal ? const Color(0xFF4ADE80) : const Color(0xFFFDE68A),
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        isFinal
                            ? 'Pembayaran final telah diverifikasi oleh Finance & HR.'
                            : 'Draft: Nilai masih dapat berubah dan bukan bukti pembayaran.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaCard(Json p, bool v2) {
    final company = text(p, 'companyName', 'PT MDM Human Resource');
    final address = text(p, 'companyAddress', '');
    final employeeName = text(p, 'employeeName');
    final department = text(p, 'department');
    final period = text(p, 'period');
    final status = text(p, 'status', 'Final');
    final ptkp = text(p, 'ptkp');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFCCFBF1), width: 1),
                ),
                child: const Icon(
                  Icons.business_rounded,
                  size: 19,
                  color: Color(0xFF0F766E),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    if (address.isNotEmpty) ...[
                      SizedBox(height: 1.5.h),
                      Text(
                        address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              _buildStatusBadge(status),
            ],
          ),
          SizedBox(height: 14.h),
          Container(height: 1, color: const Color(0xFFF1F5F9)),
          SizedBox(height: 12.h),
          _buildDetailRow('Nama Karyawan', employeeName, isBold: true),
          _buildDetailRow('Departemen', department.isNotEmpty ? department : '-'),
          _buildDetailRow('Periode Penggajian', period),
          if (v2 && ptkp.isNotEmpty) _buildDetailRow('Status PTKP', ptkp),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(Json p, bool v2) {
    final baseSalary = number(p, 'baseSalary');
    final allowance = number(p, 'allowance');
    final overtime = number(p, 'overtime');
    final bonus = number(p, 'bonus');
    final reimbursement = number(p, 'reimbursement');
    final grossSalary = v2
        ? number(p, 'grossSalary')
        : baseSalary + overtime + reimbursement;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  size: 17,
                  color: Color(0xFF16A34A),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Komponen Pendapatan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 0.8),
                ),
                child: Text(
                  'Penambahan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildDetailRow('Gaji Pokok', rupiah(baseSalary)),
          if (v2) _buildDetailRow('Tunjangan', rupiah(allowance)),
          _buildDetailRow('Lembur', rupiah(overtime)),
          if (v2) _buildDetailRow('Bonus', rupiah(bonus)),
          if (!v2) _buildDetailRow('Reimbursement Historis', rupiah(reimbursement)),
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Total Pendapatan Kotor',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF166534),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  rupiah(grossSalary),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF166534),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeductionsCard(Json p, bool v2) {
    final pph21 = number(p, 'pph21');
    final isTaxReady = p['taxReady'] == true;
    final bpjsHealth = number(p, 'bpjsHealth');
    final jht = number(p, 'jht');
    final jp = number(p, 'jp');
    final deductions = number(p, 'deductions');

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30.w,
                height: 30.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFECACA), width: 1),
                ),
                child: const Icon(
                  Icons.trending_down_rounded,
                  size: 17,
                  color: Color(0xFFDC2626),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Komponen Potongan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6.r),
                  border: Border.all(color: const Color(0xFFFECACA), width: 0.8),
                ),
                child: Text(
                  'Pengurangan',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          if (v2) ...[
            _buildDetailRow(
              pph21 < 0 ? 'Pengembalian PPh21' : 'PPh21 (Pajak)',
              isTaxReady ? rupiah(pph21) : 'Belum lengkap',
            ),
            _buildDetailRow('BPJS Kesehatan (1%)', rupiah(bpjsHealth)),
            _buildDetailRow('JHT (2%)', rupiah(jht)),
            _buildDetailRow('JP (1%)', rupiah(jp)),
          ],
          SizedBox(height: 6.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFFECACA), width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Total Potongan',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF991B1B),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '- ${rupiah(deductions)}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF991B1B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5.sp,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.slip;
    final v2 = number(p, 'version') >= 2;
    final period = text(p, 'period');
    final employeeName = text(p, 'employeeName');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0.4,
        shadowColor: const Color(0x120F172A),
        titleSpacing: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF0F172A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Rincian Slip Gaji',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            SizedBox(height: 1.5.h),
            Text(
              employeeName.isNotEmpty ? '$period • $employeeName' : period,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            width: 38.w,
            height: 38.w,
            margin: EdgeInsets.only(right: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: IconButton(
              icon: busy
                  ? SizedBox(
                      width: 16.w,
                      height: 16.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF0F766E),
                      ),
                    )
                  : const Icon(
                      Icons.share_outlined,
                      size: 18,
                      color: Color(0xFF0F766E),
                    ),
              padding: EdgeInsets.zero,
              tooltip: 'Bagikan / Unduh PDF',
              onPressed: busy ? null : share,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          children: [
            _buildHeroSalaryCard(p),
            SizedBox(height: 14.h),
            _buildMetaCard(p, v2),
            SizedBox(height: 14.h),
            _buildEarningsCard(p, v2),
            SizedBox(height: 14.h),
            _buildDeductionsCard(p, v2),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              height: 46.h,
              child: ElevatedButton.icon(
                key: const Key('payslip_share_btn'),
                onPressed: busy ? null : share,
                icon: busy
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(Icons.picture_as_pdf_rounded, size: 18.sp),
                label: Text(
                  busy ? 'Menyiapkan Dokumen…' : 'Unduh / Bagikan Slip Gaji (PDF)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

typedef PayslipPage = PayslipScreen;
