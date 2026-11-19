import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Status badge displaying Final or Draft status on payslip
class PayslipStatusBadge extends StatelessWidget {
  const PayslipStatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final isFinal = status.toLowerCase() == 'final';
    final bg = isFinal ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final textCol = isFinal ? const Color(0xFF166534) : const Color(0xFF92400E);
    final borderCol = isFinal ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A);
    final icon = isFinal ? UIcons.regularRounded.badge_check : UIcons.regularRounded.clock;

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
}
