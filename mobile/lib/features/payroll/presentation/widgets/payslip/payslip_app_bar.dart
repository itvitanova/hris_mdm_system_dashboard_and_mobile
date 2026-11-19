import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// App bar for PayslipScreen with period subtitle and share button
class PayslipAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PayslipAppBar({
    super.key,
    required this.period,
    required this.employeeName,
    required this.busy,
    required this.onShare,
  });

  final String period;
  final String employeeName;
  final bool busy;
  final VoidCallback onShare;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.4,
      shadowColor: const Color(0x120F172A),
      titleSpacing: 0,
      centerTitle: false,
      leading: IconButton(
        icon: Icon(
          UIcons.regularRounded.angle_small_left,
          color: const Color(0xFF0F172A),
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
                : Icon(
                    UIcons.regularRounded.share,
                    size: 18,
                    color: const Color(0xFF0F766E),
                  ),
            padding: EdgeInsets.zero,
            tooltip: 'Bagikan / Unduh PDF',
            onPressed: busy ? null : onShare,
          ),
        ),
      ],
    );
  }
}
