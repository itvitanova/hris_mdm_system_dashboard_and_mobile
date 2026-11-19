import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import '../input_auth.dart';
import 'login_brand_card_header.dart';
import 'login_remember_me_checkbox.dart';
import 'login_submit_button.dart';

/// Bottom white sheet card holding the login credentials form
class LoginFormCard extends StatelessWidget {
  const LoginFormCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.isChecked,
    required this.isLoading,
    required this.onRememberMeChanged,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool isChecked;
  final bool isLoading;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32.r),
          topRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.16),
            blurRadius: 30,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const LoginBrandCardHeader(),
            SizedBox(height: 20.w),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    InputAuth(
                      label: "E-Mail",
                      hintText: "Enter your email",
                      isPassword: false,
                      controller: emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.username],
                      textInputAction: TextInputAction.next,
                      validator: (v) => v == null || !v.contains('@')
                          ? 'Masukkan email yang valid'
                          : null,
                    ),
                    SizedBox(height: 10.h),
                    InputAuth(
                      label: "Password",
                      hintText: "Enter your password",
                      isPassword: true,
                      controller: passwordController,
                      enabled: !isLoading,
                      autofillHints: const [AutofillHints.password],
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => onSubmit(),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Masukkan kata sandi' : null,
                    ),
                    SizedBox(height: 10.h),
                    LoginRememberMeCheckbox(
                      isChecked: isChecked,
                      isLoading: isLoading,
                      onChanged: onRememberMeChanged,
                    ),
                    SizedBox(height: 30.w),
                    LoginSubmitButton(
                      isLoading: isLoading,
                      onSubmit: onSubmit,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.w),
          ],
        ),
      ),
    );
  }
}
