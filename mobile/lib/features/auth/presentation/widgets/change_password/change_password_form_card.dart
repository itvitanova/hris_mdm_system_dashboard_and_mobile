import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_shadows.dart';
import 'package:uicons/uicons.dart';
import 'change_password_criteria_checklist.dart';
import 'change_password_input_field.dart';

/// Clean Solid Surface Form Card containing all three password fields & criteria checklist
class ChangePasswordFormCard extends StatelessWidget {
  const ChangePasswordFormCard({
    super.key,
    required this.currentPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.obscureCurrent,
    required this.obscureNew,
    required this.obscureConfirm,
    required this.onToggleCurrent,
    required this.onToggleNew,
    required this.onToggleConfirm,
    required this.isMin8,
    required this.isDifferentFromCurrent,
    required this.isConfirmMatching,
  });

  final TextEditingController currentPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final bool obscureCurrent;
  final bool obscureNew;
  final bool obscureConfirm;
  final VoidCallback onToggleCurrent;
  final VoidCallback onToggleNew;
  final VoidCallback onToggleConfirm;
  final bool isMin8;
  final bool isDifferentFromCurrent;
  final bool isConfirmMatching;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white, width: 1.5.w),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: const Color(0xFFCCFBF1), width: 1.w),
                ),
                alignment: Alignment.center,
                child: Icon(
                  UIcons.regularRounded.key,
                  size: 18.sp,
                  color: AppColors.filterTealAccent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Formulir Kata Sandi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Lengkapi data sandi lama dan sandi baru Anda.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: 18.h),

          // 1. Password Saat Ini
          ChangePasswordInputField(
            inputKey: const Key('current_password_input'),
            label: 'Password Saat Ini',
            controller: currentPasswordController,
            hint: 'Masukkan kata sandi saat ini',
            prefixIcon: UIcons.regularRounded.lock,
            isObscure: obscureCurrent,
            onToggleObscure: onToggleCurrent,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Masukkan kata sandi saat ini' : null,
          ),
          SizedBox(height: 18.h),

          // 2. Password Baru
          ChangePasswordInputField(
            inputKey: const Key('new_password_input'),
            label: 'Password Baru',
            controller: newPasswordController,
            hint: 'Minimal 8 karakter',
            prefixIcon: UIcons.regularRounded.key,
            isObscure: obscureNew,
            onToggleObscure: onToggleNew,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Masukkan kata sandi baru';
              if (v.trim().length < 8) return 'Password minimal 8 karakter';
              if (v.trim() == currentPasswordController.text.trim()) {
                return 'Password baru harus berbeda dari password lama';
              }
              return null;
            },
          ),
          SizedBox(height: 18.h),

          // 3. Konfirmasi Password Baru
          ChangePasswordInputField(
            inputKey: const Key('confirm_password_input'),
            label: 'Konfirmasi Password Baru',
            controller: confirmPasswordController,
            hint: 'Ulangi kata sandi baru',
            prefixIcon: UIcons.regularRounded.shield_check,
            isObscure: obscureConfirm,
            onToggleObscure: onToggleConfirm,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Konfirmasi kata sandi baru diperlukan';
              if (v.trim() != newPasswordController.text.trim()) {
                return 'Konfirmasi password tidak cocok';
              }
              return null;
            },
          ),
          SizedBox(height: 18.h),

          // Real-time Criteria Checklist
          ChangePasswordCriteriaChecklist(
            isMin8: isMin8,
            isDifferentFromCurrent: isDifferentFromCurrent,
            isConfirmMatching: isConfirmMatching,
          ),
        ],
      ),
    );
  }
}
