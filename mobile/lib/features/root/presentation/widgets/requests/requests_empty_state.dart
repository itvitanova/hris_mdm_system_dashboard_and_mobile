import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Empty state ketika filter pengajuan tidak menemukan kartu
class RequestsEmptyState extends StatelessWidget {
  final bool isEn;
  final String selectedFilter;

  const RequestsEmptyState({
    super.key,
    required this.isEn,
    required this.selectedFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 28.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              UIcons.regularRounded.inbox,
              size: 22.w,
              color: const Color(0xFF94A3B8),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            selectedFilter == 'Semua'
                ? (isEn
                    ? 'No active submissions at the moment.'
                    : 'Belum ada pengajuan aktif saat ini.')
                : (isEn
                    ? 'No submissions with status "${selectedFilter == 'Menunggu' ? 'Pending' : 'Finished'}".'
                    : 'Belum ada pengajuan dengan status "$selectedFilter".'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            isEn
                ? 'Choose one of the service modules above to submit a new request.'
                : 'Pilih salah satu modul layanan di atas untuk mengajukan permohonan baru.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}
