import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';

class InputAuthPasswordToggle extends StatelessWidget {
  const InputAuthPasswordToggle({
    super.key,
    required this.obscureText,
    required this.enabled,
    required this.isFocused,
    required this.hasError,
    required this.onToggle,
  });

  final bool obscureText;
  final bool enabled;
  final bool isFocused;
  final bool hasError;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: enabled ? onToggle : null,
      icon: Icon(
        obscureText
            ? UIcons.regularRounded.eye
            : UIcons.regularRounded.eye_crossed,
        size: 20.w,
        color: isFocused
            ? (hasError ? AppColors.red : AppColors.filterTealAccent)
            : (enabled ? AppColors.textSecondary : AppColors.textTertiary),
      ),
    );
  }
}
