import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Card showing approval workflow stages (Manager -> HRD -> Finance)
class RequestPolicyWorkflowCard extends StatelessWidget {
  final String kind;

  const RequestPolicyWorkflowCard({super.key, required this.kind});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(UIcons.regularRounded.info, size: 14.sp, color: const Color(0xFF64748B)),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  'Alur Persetujuan Bertingkat',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              _buildStep('1', 'Atasan Langsung', true),
              _buildArrow(),
              _buildStep('2', 'HRD Review', false),
              if (kind == 'Reimbursement' || kind == 'Medical Claim' || kind == 'Petty Cash') ...[
                _buildArrow(),
                _buildStep('3', 'Finance', false),
              ],
            ],
          ),
          if (_getPolicyNote() != null) ...[
            SizedBox(height: 10.h),
            Text(
              _getPolicyNote()!,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5.sp,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _getPolicyNote() {
    return switch (kind) {
      'Cuti' =>
        '• Cuti dihitung per hari kalender, termasuk akhir pekan.\n• Saldo cuti dipotong otomatis setelah pengajuan disetujui pimpinan dan HR.',
      'Izin' =>
        '• Izin tidak memotong saldo cuti.\n• Lampiran pendukung bersifat opsional.',
      'Lembur' =>
        '• Gunakan tanggal mulai dan selesai yang sama. Buat pengajuan terpisah untuk hari berbeda.\n• Durasi diverifikasi oleh atasan sebelum dicatat ke rekapitulasi kehadiran.',
      'Reimbursement' =>
        '• Bukti transaksi wajib disertakan pada setiap baris pengeluaran.\n• Ketentuan template: pengajuan maksimal 14 hari kerja setelah transaksi.',
      'Petty Cash' =>
        'Saldo petty cash HO/service point yang tercatat saat pengajuan dikurangi setelah persetujuan akhir. Pengajuan ditolak atau diminta revisi tidak mengurangi saldo.',
      'General Affair' =>
        'Pengajuan mengikuti alur persetujuan yang ditetapkan kantor. Persetujuan tidak otomatis melakukan pembayaran atau mengeluarkan stok.',
      'Medical Claim' =>
        'Pengajuan mengikuti alur persetujuan yang ditetapkan kantor. Persetujuan tidak otomatis melakukan pembayaran atau mengeluarkan stok.',
      _ => null,
    };
  }

  Widget _buildStep(String num, String label, bool isFirst) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isFirst ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(6.r),
          border: Border.all(
            color: isFirst ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 16.w,
              height: 16.w,
              decoration: BoxDecoration(
                color: isFirst ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                num,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 9.5.sp,
                fontWeight: isFirst ? FontWeight.w600 : FontWeight.w500,
                color: isFirst ? const Color(0xFF1E40AF) : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrow() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Icon(UIcons.regularRounded.arrow_small_right, size: 14.sp, color: const Color(0xFF94A3B8)),
    );
  }
}
