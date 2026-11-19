import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../form_card_input.dart';
import '../form_sections/cuti_izin_form_section.dart';

/// Web-aligned Petty Cash form section with title, dates, amount card, and notes
class PettyCashWebAlignedSection extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final Widget amountWidget;
  final DateTime start;
  final DateTime end;
  final String Function(DateTime) formatDate;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onKindTap;
  final VoidCallback onChanged;

  const PettyCashWebAlignedSection({
    super.key,
    required this.titleController,
    required this.descriptionController,
    required this.amountWidget,
    required this.start,
    required this.end,
    required this.formatDate,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onKindTap,
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
        _buildSectionTitle('Jenis pengajuan *'),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onKindTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Container(
            height: 48.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Petty Cash',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Icon(
                  UIcons.regularRounded.angle_small_down,
                  color: const Color(0xFF64748B),
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16.h),
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
        _buildSectionTitle('Tanggal Mulai & Tanggal Selesai *'),
        SizedBox(height: 8.h),
        LeaveDateRangeCard(
          startLabel: 'Tanggal mulai *',
          endLabel: 'Tanggal selesai *',
          startDateText: formatDate(start),
          endDateText: formatDate(end),
          onPickStart: onPickStart,
          onPickEnd: onPickEnd,
          leaveDays: 1,
          showDuration: false,
        ),
        SizedBox(height: 16.h),
        _buildSectionTitle('Nominal pengajuan (Rp) *'),
        SizedBox(height: 8.h),
        amountWidget,
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
                  'Saldo petty cash HO/service point yang tercatat saat pengajuan dikurangi setelah persetujuan akhir. Pengajuan ditolak atau diminta revisi tidak mengurangi saldo.',
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
