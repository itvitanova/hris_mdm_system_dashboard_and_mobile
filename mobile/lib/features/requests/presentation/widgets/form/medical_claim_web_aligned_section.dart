import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/workspace.dart';
import '../form_card_input.dart';
import '../form_sections/cuti_izin_form_section.dart';
import 'medical_claim_amount_card.dart';
import 'medical_claim_plafon_info_card.dart';

/// Web-aligned Medical Claim form section with treatment date, diagnosis, and receipts
class MedicalClaimWebAlignedSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController amountController;
  final Workspace? workspace;
  final DateTime start;
  final DateTime end;
  final String Function(DateTime) formatDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final Widget attachmentWidget;
  final VoidCallback onChanged;

  const MedicalClaimWebAlignedSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.amountController,
    required this.workspace,
    required this.start,
    required this.end,
    required this.formatDate,
    required this.onPickStart,
    required this.onPickEnd,
    required this.attachmentWidget,
    required this.onChanged,
  });

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.5.sp,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF334155),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Judul pengajuan *'),
        SizedBox(height: 8.h),
        FormCardTextInput(
          controller: titleController,
          height: 48.h,
          maxLength: 160,
          hintText: 'Ringkasan keperluan Anda',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          onChanged: (_) => onChanged(),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Periode Perawatan Medis *'),
        SizedBox(height: 8.h),
        LeaveDateRangeCard(
          startLabel: 'Tanggal mulai perawatan *',
          endLabel: 'Tanggal selesai perawatan *',
          startDateText: formatDate(start),
          endDateText: formatDate(end),
          onPickStart: onPickStart,
          onPickEnd: onPickEnd,
          leaveDays: 1,
          showDuration: false,
        ),
        SizedBox(height: 16.h),
        MedicalClaimPlafonInfoCard(workspace: workspace),
        SizedBox(height: 16.h),
        _buildSectionTitle('Biaya perawatan (Rp) *'),
        SizedBox(height: 8.h),
        MedicalClaimAmountCard(
          controller: amountController,
          onChanged: onChanged,
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Detail keperluan / referensi bukti *'),
        SizedBox(height: 8.h),
        FormCardTextInput(
          controller: descriptionController,
          minLines: 4,
          maxLines: 5,
          maxLength: 3000,
          showCounter: true,
          hintText: 'Jelaskan kebutuhan dan cantumkan referensi dokumen pendukung',
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
          onChanged: (_) => onChanged(),
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Lampiran pendukung (opsional)'),
        SizedBox(height: 8.h),
        attachmentWidget,
        SizedBox(height: 4.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'JPEG, PNG, PDF; maksimal 2 MB.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                UIcons.regularRounded.info,
                size: 16.sp,
                color: const Color(0xFF64748B),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Pengajuan mengikuti alur persetujuan yang ditetapkan kantor. Persetujuan tidak otomatis melakukan pembayaran atau mengeluarkan stok.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.5.sp,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
