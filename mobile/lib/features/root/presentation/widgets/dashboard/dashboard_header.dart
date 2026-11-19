import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_shadows.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_notifications_page.dart';
import '../language_swap_button.dart';

class DashboardHeader extends StatelessWidget {
  final Workspace workspace;
  final ApiClient api;
  final AppLanguage currentLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final Future<void> Function(Widget) open;

  const DashboardHeader({
    super.key,
    required this.workspace,
    required this.api,
    required this.currentLanguage,
    required this.onLanguageChanged,
    required this.open,
  });

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'HR';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.toUpperCase();
  }

  Widget _buildAvatar(String name) {
    final initials = _getInitials(name);
    final size = 52.w;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: Colors.white,
                width: 1.5,
              ),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.filterGradientStart,
                  AppColors.filterGradientEnd,
                ],
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              initials,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Positioned(
            right: -1.w,
            bottom: -1.w,
            child: Container(
              key: const Key('dashboard_avatar_online_dot'),
              width: 11.w,
              height: 11.w,
              decoration: BoxDecoration(
                color: const Color(0xFF00AA13),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingAndName(String name) {
    final isEn = currentLanguage == AppLanguage.en;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isEn ? 'Welcome 👋' : 'Selamat Datang 👋',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
            letterSpacing: 0.1,
          ),
        ),
        SizedBox(height: 3.w),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.deepTeal,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationButton() {
    final hasUnread = workspace.mine('requests').any((r) => r['unread'] == true);

    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('dashboard_notification_button'),
          borderRadius: BorderRadius.circular(13.r),
          onTap: () => open(
            RequestNotificationsScreen(api: api, workspace: workspace),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                UIcons.regularStraight.bell,
                size: 16.w,
                color: const Color(0xFF0F172A),
              ),
              if (hasUnread)
                Positioned(
                  top: 8.w,
                  right: 8.w,
                  child: Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFED2736),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = text(workspace.actor, 'name');
    final isLargeText = MediaQuery.textScalerOf(context).scale(14) > 22;

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LanguageSwapButton(
          initialLanguage: currentLanguage,
          onLanguageChanged: onLanguageChanged,
        ),
        SizedBox(width: 8.w),
        _buildNotificationButton(),
      ],
    );

    if (isLargeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildAvatar(userName),
              actions,
            ],
          ),
          SizedBox(height: 8.w),
          _buildGreetingAndName(userName),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              _buildAvatar(userName),
              SizedBox(width: 14.w),
              Expanded(child: _buildGreetingAndName(userName)),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        actions,
      ],
    );
  }
}
