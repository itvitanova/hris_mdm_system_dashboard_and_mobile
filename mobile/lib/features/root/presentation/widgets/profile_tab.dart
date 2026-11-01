import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/api_client.dart';
import '../../../../core/workspace.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets.dart';
import '../../../auth/change_password_screen.dart';

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
                size: 20.w,
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

  @override
  Widget build(BuildContext context) {
    final userName = text(w.actor, 'name');
    final userEmail = text(w.actor, 'email');
    final empId = text(w.employee, 'id');
    final dept = text(w.employee, 'department');
    final position = text(w.employee, 'position');
    final employmentType = text(w.employee, 'employmentType', 'Belum diisi');
    final phone = text(w.employee, 'phone');
    final address = text(w.employee, 'address');
    final ptkp = text(w.employee, 'ptkp');
    final nik = text(w.employee, 'employeeNumber', 'Belum diisi');
    final bankName = text(w.employee, 'bankName');
    final bankAccountName = text(w.employee, 'bankAccountName');
    final bankAccountNumber = text(w.employee, 'bankAccountNumber');
    final isFaceEnrolled = w.employee['faceEnrolled'] == true;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text(
          'Profil Saya',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: widget.onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
            children: [
              _buildHeroHeader(
                name: userName,
                email: userEmail,
                position: position,
                department: dept,
                empId: empId,
                isFaceEnrolled: isFaceEnrolled,
              ),
              SizedBox(height: 16.h),
              _buildSectionCard(
                title: 'Informasi Pekerjaan',
                icon: UIcons.regularRounded.briefcase,
                children: [
                  _buildInfoRow(
                    label: 'ID Karyawan',
                    value: empId,
                    canCopy: true,
                    onCopy: () => _copyToClipboard(empId, 'ID Karyawan'),
                  ),
                  _buildDivider(),
                  _buildInfoRow(label: 'Departemen', value: dept),
                  _buildDivider(),
                  _buildInfoRow(label: 'Jabatan', value: position),
                  _buildDivider(),
                  _buildInfoRow(label: 'Hubungan Kerja', value: employmentType),
                  _buildDivider(),
                  _buildInfoRow(
                    label: 'Pendaftaran Wajah',
                    value: isFaceEnrolled ? 'Terdaftar' : 'Belum terdaftar',
                    customValueWidget: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFaceEnrolled
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFFD97706),
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              isFaceEnrolled ? 'Terdaftar' : 'Belum terdaftar',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: isFaceEnrolled
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              _buildSectionCard(
                title: 'Data Pribadi & Kontak',
                icon: UIcons.regularRounded.user,
                children: [
                  _buildInfoRow(
                    label: 'NIK (No. KTP)',
                    value: nik,
                    canCopy: true,
                    onCopy: () => _copyToClipboard(nik, 'NIK'),
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    label: 'Nomor Telepon',
                    value: phone,
                    canCopy: true,
                    onCopy: () => _copyToClipboard(phone, 'Nomor Telepon'),
                  ),
                  _buildDivider(),
                  _buildInfoRow(label: 'Alamat Rumah', value: address),
                  _buildDivider(),
                  _buildInfoRow(label: 'Status PTKP', value: ptkp),
                ],
              ),
              _buildSectionCard(
                title: 'Rekening Payroll',
                icon: UIcons.regularRounded.credit_card,
                children: [
                  _buildInfoRow(label: 'Nama Bank', value: bankName),
                  _buildDivider(),
                  _buildInfoRow(
                    label: 'Nomor Rekening',
                    value: bankAccountNumber,
                    canCopy: true,
                    onCopy: () =>
                        _copyToClipboard(bankAccountNumber, 'Nomor Rekening'),
                  ),
                  _buildDivider(),
                  _buildInfoRow(
                    label: 'Nama Pemilik',
                    value: bankAccountName,
                  ),
                ],
              ),
              _buildNoticeBox(),
              SizedBox(height: 14.h),
              _buildSectionCard(
                title: 'Keamanan & Akun',
                icon: UIcons.regularRounded.shield_check,
                children: [
                  _buildSettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Ganti Password',
                    subtitle: 'Perbarui kata sandi akun Anda secara berkala',
                    onTap: () async {
                      final changed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChangePasswordScreen(api: widget.api),
                        ),
                      );
                      if (changed == true && mounted) widget.onLogout();
                    },
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Icons.logout_rounded,
                    title: 'Keluar Akun',
                    subtitle: 'Akhiri sesi aktif di perangkat ini',
                    isDanger: true,
                    loading: loggingOut,
                    onTap: loggingOut ? null : _confirmLogout,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Center(
                child: Text(
                  'MDM HR Mobile • Versi 1.2.0 (Build 2013)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroHeader({
    required String name,
    required String email,
    required String position,
    required String department,
    required String empId,
    required bool isFaceEnrolled,
  }) {
    final initials = _getInitials(name);
    final roleText = department.isNotEmpty && department != '—'
        ? '$position • $department'
        : position;

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F766E), // Teal 700
            Color(0xFF14B8A6), // Teal 500
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F766E).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 62.w,
                height: 62.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 4.h,
                      children: [
                        if (empId.isNotEmpty && empId != '—')
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              empId,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (roleText.isNotEmpty && roleText != '—')
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              roleText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 16.w, color: AppColors.deepTeal),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    bool canCopy = false,
    VoidCallback? onCopy,
    Widget? customValueWidget,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 116.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: customValueWidget ??
                Text(
                  value.isEmpty ? '—' : value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
          ),
          if (canCopy && value.isNotEmpty && value != '—' && value != 'Belum diisi') ...[
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: onCopy,
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: EdgeInsets.all(5.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Icon(
                  Icons.copy_rounded,
                  size: 14.w,
                  color: AppColors.deepTeal,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFF1F5F9),
    );
  }

  Widget _buildNoticeBox() {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18.w,
            color: const Color(0xFF0284C7),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Hubungi tim HR untuk memperbarui data pribadi atau nomor rekening penggajian.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF475569),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool isDanger = false,
    bool loading = false,
  }) {
    final primaryColor =
        isDanger ? const Color(0xFFEF4444) : const Color(0xFF0F172A);
    final iconBgColor =
        isDanger ? const Color(0xFFFEE2E2) : const Color(0xFFF1F5F9);
    final iconColor =
        isDanger ? const Color(0xFFEF4444) : const Color(0xFF475569);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 9.h, horizontal: 2.w),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(10.r),
              ),
              alignment: Alignment.center,
              child: loading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                      ),
                    )
                  : Icon(icon, size: 20.w, color: iconColor),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20.w,
              color: isDanger
                  ? const Color(0xFFFCA5A5)
                  : const Color(0xFF94A3B8),
            ),
          ],
        ),
      ),
    );
  }
}
