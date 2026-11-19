import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

class PayrollAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Future<void> Function() onRefresh;

  const PayrollAppBar({super.key, required this.onRefresh});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.4,
      shadowColor: const Color(0x120F172A),
      titleSpacing: 20,
      centerTitle: false,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Slip Gaji',
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
            'Rincian & Riwayat Pembayaran Gaji',
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
            icon: Icon(
              UIcons.regularRounded.refresh,
              size: 20,
              color: const Color(0xFF0F766E),
            ),
            padding: EdgeInsets.zero,
            tooltip: 'Segarkan data',
            onPressed: onRefresh,
          ),
        ),
      ],
    );
  }
}
