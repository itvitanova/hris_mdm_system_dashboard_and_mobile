import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'change_password_criteria_item.dart';

/// Real-time Criteria Checklist Card for password strength and matching
class ChangePasswordCriteriaChecklist extends StatelessWidget {
  const ChangePasswordCriteriaChecklist({
    super.key,
    required this.isMin8,
    required this.isDifferentFromCurrent,
    required this.isConfirmMatching,
  });

  final bool isMin8;
  final bool isDifferentFromCurrent;
  final bool isConfirmMatching;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                UIcons.regularRounded.list_check,
                size: 15.sp,
                color: const Color(0xFF475569),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Kriteria Keamanan Sandi',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ChangePasswordCriteriaItem(
            isValid: isMin8,
            label: 'Minimal 8 karakter',
          ),
          SizedBox(height: 6.h),
          ChangePasswordCriteriaItem(
            isValid: isDifferentFromCurrent,
            label: 'Berbeda dari password saat ini',
          ),
          SizedBox(height: 6.h),
          ChangePasswordCriteriaItem(
            isValid: isConfirmMatching,
            label: 'Konfirmasi password cocok',
          ),
        ],
      ),
    );
  }
}
