import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/workspace.dart';
import '../language_swap_button.dart';
import 'dashboard_avatar.dart';
import 'dashboard_notification_button.dart';

class DashboardHeader extends StatelessWidget {
  final Workspace workspace;
  final ApiClient api;
  final AppLanguage currentLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final Future<void> Function(Widget) open;
  final bool isOnline;

  const DashboardHeader({
    super.key,
    required this.workspace,
    required this.api,
    required this.currentLanguage,
    required this.onLanguageChanged,
    required this.open,
    this.isOnline = true,
  });

  void _handleAvatarTap(BuildContext context) {
    if (!isOnline) {
      final isEn = currentLanguage == AppLanguage.en;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEn
                      ? 'No internet connection. Operating in offline mode.'
                      : 'Koneksi internet mati. Anda sedang dalam mode offline.',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    final userName = text(workspace.actor, 'name');
    final isLargeText = MediaQuery.textScalerOf(context).scale(14) > 22;

    final avatar = DashboardAvatar(
      name: userName,
      isOnline: isOnline,
      onTap: () => _handleAvatarTap(context),
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LanguageSwapButton(
          initialLanguage: currentLanguage,
          onLanguageChanged: onLanguageChanged,
        ),
        SizedBox(width: 8.w),
        DashboardNotificationButton(
          workspace: workspace,
          api: api,
          open: open,
        ),
      ],
    );

    if (isLargeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              avatar,
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
              avatar,
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
