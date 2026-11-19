import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Single numeric page box button inside pagination bar
class ApprovalsPageNumberButton extends StatelessWidget {
  const ApprovalsPageNumberButton({
    super.key,
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isActive ? null : onTap,
          borderRadius: BorderRadius.circular(8.r),
          child: Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF0D9488) : Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF0D9488)
                    : const Color(0xFFCBD5E1),
                width: 0.8,
              ),
            ),
            child: Text(
              '$page',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.5.sp,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                color: isActive ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
