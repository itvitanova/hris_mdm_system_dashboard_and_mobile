import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/theme/app_text_styles.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'language_swap_button.dart';

class RootNavBarItems {
  static Widget tabIcon({
    required Widget svg,
    required String label,
    int? badgeCount,
  }) {
    final content = Stack(
      alignment: Alignment.center,
      children: [
        svg,
        SizedBox(
          width: 0,
          height: 0,
          child: OverflowBox(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 0.001,
                color: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );

    if (badgeCount != null && badgeCount > 0) {
      return Badge.count(count: badgeCount, child: content);
    }
    return content;
  }

  static List<PersistentBottomNavBarItem> build({
    required Workspace workspace,
  }) {
    final isEn = AppLanguageController.currentLanguage == AppLanguage.en;
    final unreadCount = workspace
        .mine('requests')
        .where((r) => r['unread'] == true)
        .length;

    return [
      PersistentBottomNavBarItem(
        icon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/home-2.svg',
            colorFilter: const ColorFilter.mode(AppColors.deepTeal, BlendMode.srcIn),
          ),
          label: isEn ? 'Home' : 'Beranda',
        ),
        inactiveIcon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/home-2-not-active.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: isEn ? 'Home' : 'Beranda',
        ),
        title: isEn ? 'Home' : 'Beranda',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/note-add-active.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.deepTeal, BlendMode.srcIn),
          ),
          label: isEn ? 'Requests' : 'Pengajuan',
          badgeCount: unreadCount,
        ),
        inactiveIcon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/note-add.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: isEn ? 'Requests' : 'Pengajuan',
          badgeCount: unreadCount,
        ),
        title: isEn ? 'Requests' : 'Pengajuan',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/message-time-active-new.svg',
            width: 24,
            height: 24,
          ),
          label: isEn ? 'Approvals' : 'Persetujuan',
        ),
        inactiveIcon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/message-time.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: isEn ? 'Approvals' : 'Persetujuan',
        ),
        title: isEn ? 'Approvals' : 'Persetujuan',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/empty-wallet-active.svg',
            width: 24,
            height: 24,
            colorFilter: const ColorFilter.mode(AppColors.deepTeal, BlendMode.srcIn),
          ),
          label: isEn ? 'Payslip' : 'Slip gaji',
        ),
        inactiveIcon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/empty-wallet.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: isEn ? 'Payslip' : 'Slip gaji',
        ),
        title: isEn ? 'Payslip' : 'Slip gaji',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
      PersistentBottomNavBarItem(
        icon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/profile.svg',
            colorFilter: const ColorFilter.mode(AppColors.deepTeal, BlendMode.srcIn),
          ),
          label: isEn ? 'Profile' : 'Profil',
        ),
        inactiveIcon: tabIcon(
          svg: SvgPicture.asset(
            'assets/icon/profile-not-active.svg',
            colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
          ),
          label: isEn ? 'Profile' : 'Profil',
        ),
        title: isEn ? 'Profile' : 'Profil',
        textStyle: AppTextStyles.inter12MediumDeepTeal,
        activeColorPrimary: AppColors.deepTeal,
        inactiveColorPrimary: Colors.grey,
      ),
    ];
  }
}
