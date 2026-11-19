import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:uicons/uicons.dart';

/// Reusable password input field with obscure toggle and standardized styling
class ChangePasswordInputField extends StatelessWidget {
  const ChangePasswordInputField({
    super.key,
    required this.inputKey,
    required this.label,
    required this.controller,
    required this.hint,
    required this.prefixIcon,
    required this.isObscure,
    required this.onToggleObscure,
    required this.validator,
    this.isRequired = true,
  });

  final Key inputKey;
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData prefixIcon;
  final bool isObscure;
  final VoidCallback onToggleObscure;
  final FormFieldValidator<String>? validator;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (isRequired) ...[
              SizedBox(width: 3.w),
              Text(
                '*',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 6.h),
        TextFormField(
          key: inputKey,
          controller: controller,
          obscureText: isObscure,
          cursorColor: AppColors.filterTealAccent,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.5.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF94A3B8),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: Icon(
              prefixIcon,
              size: 19.sp,
              color: const Color(0xFF64748B),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? UIcons.regularRounded.eye_crossed : UIcons.regularRounded.eye,
                size: 19.sp,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: onToggleObscure,
              splashRadius: 18.r,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1.w),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFFE2E8F0), width: 1.w),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.filterTealAccent, width: 1.6.w),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFFEF4444), width: 1.w),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: const Color(0xFFEF4444), width: 1.5.w),
            ),
            errorStyle: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEF4444),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
