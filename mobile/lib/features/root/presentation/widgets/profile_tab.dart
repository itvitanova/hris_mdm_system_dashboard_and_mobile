import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/core_widgets.dart';
import '../../../requests/presentation/pages/request_notifications_page.dart';
import 'logout_confirmation_bottom_sheet.dart';
import 'profile/employee_details_bottom_sheet.dart';
import 'profile/profile_header_card.dart';
import 'profile/profile_info_grid.dart';
import 'profile/profile_logout_item.dart';
import 'profile/profile_setting_item.dart';
import 'profile/profile_settings_header.dart';
import 'package:uicons/uicons.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.api,
    required this.workspace,
    required this.onRefresh,
    this.open,
    required this.onLogout,
  });

  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
  final Future<void> Function(Widget)? open;
  final VoidCallback onLogout;

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool loggingOut = false;

  Workspace get w => widget.workspace;

  String _getInitials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'HR';
    final parts =
        trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed.length >= 2
        ? trimmed.substring(0, 2).toUpperCase()
        : trimmed.toUpperCase();
  }

  Future<void> logout() async {
    setState(() => loggingOut = true);
    try {
      await widget.api.logout();
      if (mounted) widget.onLogout();
    } catch (e) {
      if (mounted) notify(context, e);
    } finally {
      if (mounted) setState(() => loggingOut = false);
    }
  }

  Future<void> _confirmLogout() async {
    if (loggingOut) return;
    await LogoutConfirmationBottomSheet.show(
      context,
      onConfirmLogout: logout,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userName = text(w.actor, 'name');
    final userEmail = text(w.actor, 'email');
    final empId = text(w.employee, 'id');
    final dept = text(w.employee, 'department');
    final position = text(w.employee, 'position');
    final employmentType = text(w.employee, 'employmentType', 'Belum diisi');
    final phone = text(w.employee, 'phone');
    final address = text(w.employee, 'address', 'Belum diisi');
    final ptkp = text(w.employee, 'ptkp', '—');
    final nik = text(w.employee, 'employeeNumber', 'Belum diisi');
    final bankName = text(w.employee, 'bankName', '—');
    final bankAccountName = text(w.employee, 'bankAccountName', '—');
    final bankAccountNumber = text(w.employee, 'bankAccountNumber', '—');
    final isFaceEnrolled = w.employee['faceEnrolled'] == true;
    final hasUnreadNotification =
        w.mine('requests').any((r) => r['unread'] == true);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 20.h),
                ProfileHeaderCard(
                  name: userName,
                  email: userEmail,
                  initials: _getInitials(userName),
                  hasUnreadNotification: hasUnreadNotification,
                  onNotificationTap: () async {
                    await Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => RequestNotificationsScreen(
                          api: widget.api,
                          workspace: w,
                        ),
                      ),
                    );
                    if (mounted) await widget.onRefresh();
                  },
                ),
                SizedBox(height: 16.h),
                ProfileInfoGrid(
                  empId: empId,
                  dept: dept,
                  position: position,
                  phone: phone,
                ),
                SizedBox(height: 16.h),
                const ProfileSettingsHeader(),
                SizedBox(height: 12.h),
                ProfileSettingItem(
                  icon: UIcons.regularRounded.id_badge,
                  label: 'Detail Data & Kepegawaian',
                  onTap: () => EmployeeDetailsBottomSheet.show(
                    context: context,
                    empId: empId,
                    nik: nik,
                    employmentType: employmentType,
                    ptkp: ptkp,
                    phone: phone,
                    address: address,
                    bankName: bankName,
                    bankAccountNumber: bankAccountNumber,
                    bankAccountName: bankAccountName,
                    isFaceEnrolled: isFaceEnrolled,
                  ),
                ),
                SizedBox(height: 12.h),
                ProfileLogoutItem(
                  label: 'Keluar Akun',
                  loading: loggingOut,
                  onTap: loggingOut ? () {} : _confirmLogout,
                ),
                SizedBox(height: 24.h),
                Center(
                  child: Text(
                    'HRIS MDM System • Versi 1.2.0 (Build 2013)',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
