import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';

/// Single item row displaying criteria status with icon and label
class ChangePasswordCriteriaItem extends StatelessWidget {
  const ChangePasswordCriteriaItem({
    super.key,
    required this.isValid,
    required this.label,
  });

  final bool isValid;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isValid
              ? UIcons.regularRounded.check
              : UIcons.regularRounded.circle,
          size: 16.sp,
          color: isValid ? const Color(0xFF00AA13) : const Color(0xFF94A3B8),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
              color: isValid ? const Color(0xFF0F766E) : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}
