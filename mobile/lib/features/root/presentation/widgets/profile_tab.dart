import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/di/injection_container.dart';
import 'package:mdm_hris/core/services/network_connectivity_service.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import 'package:mdm_hris/core/widgets/core_widgets.dart';
import 'package:mdm_hris/features/requests/presentation/pages/request_notifications_page.dart';
import 'logout_confirmation_bottom_sheet.dart';
import 'profile/employee_details_bottom_sheet.dart';
import 'profile/profile_header_card.dart';
import 'profile/profile_info_grid.dart';
import 'profile/profile_logout_item.dart';
import 'profile/profile_setting_item.dart';
import 'profile/profile_settings_header.dart';
import 'profile/profile_version_footer.dart';

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

  bool get _isOnline => sl.isRegistered<NetworkConnectivityService>()
      ? sl<NetworkConnectivityService>().isOnline : true;

  @override
  void initState() {
    super.initState();
    if (sl.isRegistered<NetworkConnectivityService>()) {
      sl<NetworkConnectivityService>().isOnlineNotifier.addListener(_onConnChanged);
    }
  }

  void _onConnChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (sl.isRegistered<NetworkConnectivityService>()) {
      sl<NetworkConnectivityService>().isOnlineNotifier.removeListener(_onConnChanged);
    }
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    if (sl.isRegistered<NetworkConnectivityService>()) {
      await sl<NetworkConnectivityService>().checkConnection();
    }
    await widget.onRefresh();
  }

  void _handleAvatarTap() {
    if (!_isOnline) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('Koneksi internet mati. Anda sedang dalam mode offline.',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  String _getInitials(String name) {
    final t = name.trim();
    if (t.isEmpty) return 'HR';
    final parts = t.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return t.length >= 2 ? t.substring(0, 2).toUpperCase() : t.toUpperCase();
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

  @override
  Widget build(BuildContext context) {
    final userName = text(w.actor, 'name');
    final userEmail = text(w.actor, 'email');
    final emp = w.employee;
    final hasUnreadNotification = w.mine('requests').any((r) => r['unread'] == true);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
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
                  isOnline: _isOnline,
                  onAvatarTap: _handleAvatarTap,
                  onNotificationTap: () async {
                    await Navigator.of(context, rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (_) => RequestNotificationsScreen(api: widget.api, workspace: w),
                      ),
                    );
                    if (mounted) await _handleRefresh();
                  },
                ),
                SizedBox(height: 16.h),
                ProfileInfoGrid(
                  empId: text(emp, 'id'),
                  dept: text(emp, 'department'),
                  position: text(emp, 'position'),
                  phone: text(emp, 'phone'),
                ),
                SizedBox(height: 16.h),
                const ProfileSettingsHeader(),
                SizedBox(height: 12.h),
                ProfileSettingItem(
                  icon: UIcons.regularRounded.id_badge,
                  label: 'Detail Data & Kepegawaian',
                  onTap: () => EmployeeDetailsBottomSheet.show(
                    context: context,
                    empId: text(emp, 'id'),
                    nik: text(emp, 'employeeNumber', 'Belum diisi'),
                    employmentType: text(emp, 'employmentType', 'Belum diisi'),
                    ptkp: text(emp, 'ptkp', '—'),
                    phone: text(emp, 'phone'),
                    address: text(emp, 'address', 'Belum diisi'),
                    bankName: text(emp, 'bankName', '—'),
                    bankAccountNumber: text(emp, 'bankAccountNumber', '—'),
                    bankAccountName: text(emp, 'bankAccountName', '—'),
                    isFaceEnrolled: emp['faceEnrolled'] == true,
                  ),
                ),
                SizedBox(height: 12.h),
                ProfileLogoutItem(
                  label: 'Keluar Akun',
                  loading: loggingOut,
                  onTap: loggingOut ? () {} : () => LogoutConfirmationBottomSheet.show(context, onConfirmLogout: logout),
                ),
                SizedBox(height: 24.h),
                const ProfileVersionFooter(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
