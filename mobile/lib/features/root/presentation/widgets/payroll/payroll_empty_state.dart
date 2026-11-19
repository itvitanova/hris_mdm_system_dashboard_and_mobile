import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

class PayrollEmptyState extends StatelessWidget {
  final bool isFiltered;
  final VoidCallback onReset;
  final VoidCallback onRefresh;

  const PayrollEmptyState({
    super.key,
    required this.isFiltered,
    required this.onReset,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 36.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: Icon(
              UIcons.regularRounded.receipt,
              size: 26,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            isFiltered ? 'Tidak Ada Slip yang Sesuai' : 'Slip Gaji Belum Tersedia',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            isFiltered
                ? 'Tidak ditemukan dokumen slip gaji yang sesuai dengan filter pencarian atau periode terpilih.'
                : 'Data slip gaji Anda untuk periode ini belum diterbitkan oleh bagian Finance/HR.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          SizedBox(height: 16.h),
          if (isFiltered)
            ElevatedButton.icon(
              onPressed: onReset,
              icon: Icon(UIcons.regularRounded.cross_circle, size: 16),
              label: const Text('Reset Filter & Pencarian'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: Icon(UIcons.regularRounded.refresh, size: 15),
              label: const Text('Muat Ulang Data'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0F766E),
                side: const BorderSide(color: Color(0xFF0F766E), width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              ),
            ),
        ],
      ),
    );
  }
}
