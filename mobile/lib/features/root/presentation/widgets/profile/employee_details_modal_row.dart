import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/theme/app_colors.dart';

/// Baris data label-value pada modal bottom sheet
class EmployeeDetailsModalRow extends StatelessWidget {
  final String label;
  final String value;
  final bool canCopy;
  final VoidCallback? onCopy;
  final Widget? customValue;

  const EmployeeDetailsModalRow({
    super.key,
    required this.label,
    required this.value,
    this.canCopy = false,
    this.onCopy,
    this.customValue,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 6,
          child: customValue ??
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5.sp,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (canCopy && onCopy != null)
                    GestureDetector(
                      onTap: onCopy,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: Icon(
                          UIcons.regularRounded.copy,
                          size: 14.sp,
                          color: AppColors.deepTeal,
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
