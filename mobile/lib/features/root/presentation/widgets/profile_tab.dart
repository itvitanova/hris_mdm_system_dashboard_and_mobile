import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../../shared/widgets.dart';
import '../../../auth/change_password_screen.dart';
import '../../../requests/presentation/pages/request_notifications_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.api,
    required this.workspace,
    required this.onRefresh,
    required this.onLogout,
  });

  final ApiClient api;
  final Workspace workspace;
  final Future<void> Function() onRefresh;
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
    if (trimmed.length >= 2) {
      return trimmed.substring(0, 2).toUpperCase();
    }
    return trimmed.toUpperCase();
  }

  void _copyToClipboard(String val, String label) {
    if (val.isEmpty || val == '—' || val == 'Belum diisi') return;
    Clipboard.setData(ClipboardData(text: val));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin ke papan klip'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: const Color(0xFFEF4444),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 10.w),
            const Expanded(
              child: Text(
                'Keluar Akun',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini? Anda harus memasukkan kredensial kembali untuk masuk.',
          style: TextStyle(color: Color(0xFF475569)),
        ),
        actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await logout();
    }
  }

  void _showEmployeeDetailsModal({
    required String empId,
    required String nik,
    required String employmentType,
    required String ptkp,
    required String phone,
    required String address,
    required String bankName,
    required String bankAccountNumber,
    required String bankAccountName,
    required bool isFaceEnrolled,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section with Drag Handle
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 12.h),
                child: Column(
                  children: [
                    Center(
                      child: Container(
                        width: 38.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Container(
                          width: 38.w,
                          height: 38.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDFA),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: const Color(0xFF99F6E4),
                              width: 1.w,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.badge_outlined,
                            size: 20.sp,
                            color: AppColors.deepTeal,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Informasi Lengkap Karyawan',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'Data terdaftar pada sistem HRIS MDM',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.5.sp,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFF1F5F9)),

              // Scrollable Details Body
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 14.h),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            _buildModalRow(
                              label: 'NIK (No. KTP)',
                              value: nik,
                              canCopy: true,
                              onCopy: () => _copyToClipboard(nik, 'NIK'),
                            ),
                            Divider(height: 18.h, color: const Color(0xFFE2E8F0)),
                            _buildModalRow(
                              label: 'Hubungan Kerja',
                              value: employmentType,
                            ),
                            Divider(height: 18.h, color: const Color(0xFFE2E8F0)),
                            _buildModalRow(
                              label: 'Status PTKP',
                              value: ptkp,
                            ),
                            Divider(height: 18.h, color: const Color(0xFFE2E8F0)),
                            _buildModalRow(
                              label: 'Pendaftaran Wajah',
                              value:
                                  isFaceEnrolled ? 'Terdaftar' : 'Belum terdaftar',
                              customValue: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isFaceEnrolled
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Text(
                                  isFaceEnrolled ? 'Terdaftar' : 'Belum terdaftar',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: isFaceEnrolled
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB45309),
                                  ),
                                ),
                              ),
                            ),
                            Divider(height: 18.h, color: const Color(0xFFE2E8F0)),
                            _buildModalRow(
                              label: 'Alamat Rumah',
                              value: address,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rekening Payroll',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.deepTeal,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            _buildModalRow(label: 'Nama Bank', value: bankName),
                            Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
                            _buildModalRow(
                              label: 'Nomor Rekening',
                              value: bankAccountNumber,
                              canCopy: true,
                              onCopy: () => _copyToClipboard(
                                  bankAccountNumber, 'Nomor Rekening'),
                            ),
                            Divider(height: 16.h, color: const Color(0xFFE2E8F0)),
                            _buildModalRow(
                              label: 'Nama Pemilik',
                              value: bankAccountName,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDFA),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: const Color(0xFFCCFBF1)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 16.sp,
                              color: AppColors.deepTeal,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Pembaruan data kepegawaian & payroll dapat diajukan melalui tim HRD.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 11.sp,
                                  color: const Color(0xFF0F766E),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom Action Bar with Teal Gradient Button
              Container(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  12.h,
                  20.w,
                  MediaQuery.of(ctx).padding.bottom + 12.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: const Border(
                    top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.filterGradientStart,
                        AppColors.filterGradientEnd,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF0D9488).withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.r),
                      onTap: () => Navigator.pop(ctx),
                      child: Center(
                        child: Text(
                          'Tutup',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalRow({
    required String label,
    required String value,
    bool canCopy = false,
    VoidCallback? onCopy,
    Widget? customValue,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 6,
          child: customValue ??
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5.sp,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (canCopy && onCopy != null)
                    GestureDetector(
                      onTap: onCopy,
                      child: Padding(
                        padding: EdgeInsets.only(left: 6.w),
                        child: Icon(
                          Icons.copy_rounded,
                          size: 14.sp,
                          color: AppColors.deepTeal,
                        ),
                      ),
                    ),
                ],
              ),
        ),
      ],
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

                // Signature Profile Header Card (Simetris & Sejajar)
                _ProfileHeaderCard(
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

                // Grid 2x2 Info Cards (Tinggi dan Lebar Simetris 100%)
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.qr_code,
                        label: 'ID Karyawan',
                        value: empId,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.business_outlined,
                        label: 'Departemen',
                        value: dept,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.work_outline,
                        label: 'Jabatan',
                        value: position,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.call_outlined,
                        label: 'Nomor Telepon',
                        value: phone,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Header Section "Pengaturan Akun"
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10.r),
                    boxShadow: const [AppShadows.shadow094],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3.5.w,
                        height: 14.h,
                        decoration: BoxDecoration(
                          color: AppColors.deepTeal,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Pengaturan Akun',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 12.h),

                // 1. Detail Data & Kepegawaian (Teal Gradient Button)
                _SettingItem(
                  icon: Icons.badge_outlined,
                  label: 'Detail Data & Kepegawaian',
                  onTap: () => _showEmployeeDetailsModal(
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

                // 2. Ganti Kata Sandi (Teal Gradient Button)
                _SettingItem(
                  icon: Icons.lock_outline_rounded,
                  label: 'Ganti Kata Sandi',
                  onTap: () async {
                    final changed =
                        await Navigator.of(context, rootNavigator: true)
                            .push<bool>(
                      MaterialPageRoute(
                        builder: (_) => ChangePasswordScreen(api: widget.api),
                      ),
                    );
                    if (changed == true && mounted) widget.onLogout();
                  },
                ),

                SizedBox(height: 12.h),

                // 3. Keluar Akun (Danger Red Card)
                _SettingItem(
                  icon: Icons.logout_rounded,
                  label: 'Keluar Akun',
                  isLogout: true,
                  loading: loggingOut,
                  onTap: loggingOut ? () {} : _confirmLogout,
                ),

                SizedBox(
                  height: 24.h,
                ),

                // Versi Aplikasi Footer
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

/// Profile Header Card (Simetris & Sejajar)
class _ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String initials;
  final bool hasUnreadNotification;
  final VoidCallback onNotificationTap;

  static const double _contentHeight = 62.0;

  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.hasUnreadNotification,
    required this.onNotificationTap,
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
          _buildAvatar(),
          SizedBox(width: 14.w),
          Expanded(child: _buildUserInfo()),
          SizedBox(width: 10.w),
          _buildNotificationButton(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final size = _contentHeight.w;

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
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white,
                width: 1.5.w,
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
                fontSize: 20.sp,
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
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: const Color(0xFF00AA13),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2.w,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return SizedBox(
      height: _contentHeight.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  Icons.mail_outline_rounded,
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
      ),
    );
  }

  Widget _buildNotificationButton() {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(13.r),
          onTap: onNotificationTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_none_rounded,
                size: 19.sp,
                color: const Color(0xFF0F172A),
              ),
              if (hasUnreadNotification)
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
                        width: 1.5.w,
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
}

/// 2x2 Info Card (Fixed height for strict symmetry)
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.w,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 18.sp, color: AppColors.textPrimary),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF64748B),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Setting Item Button (Tinggi dan Spacing Simetris)
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLogout;
  final bool loading;

  const _SettingItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLogout = false,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLogout) {
      return Container(
        height: 54.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFECDD3),
            width: 1.2.w,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onTap,
            borderRadius: BorderRadius.circular(16.r),
            splashColor: const Color(0xFFFEF2F2),
            highlightColor: const Color(0xFFFEE2E2).withValues(alpha: 0.5),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: const Color(0xFFFECDD3),
                        width: 1.2.w,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: loading
                        ? SizedBox(
                            width: 18.w,
                            height: 18.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFFED2736),
                            ),
                          )
                        : Icon(
                            icon,
                            size: 20.sp,
                            color: const Color(0xFFED2736),
                          ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22.sp,
                    color: const Color(0xFFFCA5A5),
                  ),
                  SizedBox(width: 4.w),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      height: 54.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.45),
          width: 1.2.w,
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.filterGradientStart,
            AppColors.filterGradientEnd,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.40),
                      width: 1.2.w,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 22.sp,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
                SizedBox(width: 4.w),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
