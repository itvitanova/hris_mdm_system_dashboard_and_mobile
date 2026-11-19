import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PayrollHistoryHeader extends StatelessWidget {
  final int totalDocuments;

  const PayrollHistoryHeader({
    super.key,
    required this.totalDocuments,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            'Riwayat Pembayaran',
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
        if (totalDocuments > 0)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 7.w,
              vertical: 2.5.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 0.8,
              ),
            ),
            child: Text(
              '$totalDocuments Dokumen',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.5.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
      ],
    );
  }
}
