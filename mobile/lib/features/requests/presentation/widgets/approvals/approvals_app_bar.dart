import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// App bar for approvals page with back button and refresh action
class ApprovalsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ApprovalsAppBar({
    super.key,
    required this.canPop,
    required this.onBack,
    required this.onRefresh,
  });

  final bool canPop;
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0.4,
      shadowColor: const Color(0x120F172A),
      titleSpacing: canPop ? 0 : 20,
      centerTitle: false,
      leading: canPop
          ? IconButton(
              icon: Icon(
                UIcons.regularRounded.angle_small_left,
                size: 20,
                color: const Color(0xFF0F172A),
              ),
              onPressed: onBack,
            )
          : null,
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Persetujuan',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
          ),
          SizedBox(height: 1.5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              'Tinjau & Verifikasi Pengajuan Tim',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                letterSpacing: 0.1,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 0.8,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(11.r),
              onTap: onRefresh,
              child: Tooltip(
                message: 'Segarkan persetujuan',
                child: Icon(
                  UIcons.regularRounded.refresh,
                  size: 19.w,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 16.w),
      ],
    );
  }
}
