import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_shadows.dart';
import 'profile_avatar.dart';
import 'profile_notification_badge_button.dart';

/// Profile Header Card (Simetris & Sejajar)
class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String initials;
  final bool hasUnreadNotification;
  final VoidCallback onNotificationTap;
  final bool isOnline;
  final VoidCallback? onAvatarTap;

  static const double _contentHeight = 62.0;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    required this.initials,
    required this.hasUnreadNotification,
    required this.onNotificationTap,
    this.isOnline = true,
    this.onAvatarTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white, width: 1.5.w),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ProfileAvatar(
            initials: initials,
            size: _contentHeight,
            isOnline: isOnline,
            onTap: onAvatarTap,
          ),
          SizedBox(width: 14.w),
          Expanded(child: _buildUserInfo()),
          SizedBox(width: 10.w),
          ProfileNotificationBadgeButton(
            hasUnread: hasUnreadNotification,
            onTap: onNotificationTap,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Selamat Datang 👋',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
            letterSpacing: 0.1,
            height: 1.1,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.deepTeal,
            letterSpacing: -0.2,
            height: 1.2,
          ),
        ),
        SizedBox(height: 5.h),
        Container(
          height: 23.w,
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDFA),
            borderRadius: BorderRadius.circular(11.5.r),
            border: Border.all(
              color: const Color(0xFF99F6E4),
              width: 0.9.w,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                UIcons.regularRounded.envelope,
                size: 12.sp,
                color: AppColors.deepTeal,
              ),
              SizedBox(width: 5.w),
              Flexible(
                child: Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.deepTeal,
                    letterSpacing: -0.1,
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
