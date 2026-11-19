import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:uicons/uicons.dart';

/// App bar for ChangePasswordScreen
class ChangePasswordAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChangePasswordAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      shadowColor: AppColors.shadowAppBar,
      backgroundColor: AppColors.white,
      surfaceTintColor: AppColors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: Icon(
          UIcons.regularRounded.angle_small_left,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        'Ganti Password',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
