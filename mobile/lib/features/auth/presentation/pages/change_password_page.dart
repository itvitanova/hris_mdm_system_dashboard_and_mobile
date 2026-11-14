import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/api_client.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Halaman Ubah Password Karyawan
///
/// Menggunakan Design Pattern Signature Teal Gradient & Clean Solid Surface:
/// - Signature Teal Gradient Hero Card (#0F766E -> #14B8A6) dengan Frosted White Squircle
/// - Clean Solid Surface form card dengan border putih & shadow094
/// - Ergonomic form input dengan visibility toggle & live criteria checklist
class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({
    super.key,
    required this.api,
    this.authBloc,
  });

  final ApiClient api;
  final AuthBloc? authBloc;

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _currentPasswordController.addListener(_onFieldChanged);
    _newPasswordController.addListener(_onFieldChanged);
    _confirmPasswordController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _currentPasswordController.removeListener(_onFieldChanged);
    _newPasswordController.removeListener(_onFieldChanged);
    _confirmPasswordController.removeListener(_onFieldChanged);
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Live checklist criteria evaluation
  bool get _isMin8 => _newPasswordController.text.trim().length >= 8;

  bool get _isDifferentFromCurrent {
    final cur = _currentPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    return newPass.isNotEmpty && cur.isNotEmpty && newPass != cur;
  }

  bool get _isConfirmMatching {
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();
    return newPass.isNotEmpty && confirm.isNotEmpty && newPass == confirm;
  }

  AuthBloc? _getBloc() {
    if (widget.authBloc != null) return widget.authBloc;
    try {
      return context.read<AuthBloc>();
    } catch (_) {
      return null;
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              UIcons.regularRounded.check,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Password berhasil diganti. Silakan login kembali.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F766E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              UIcons.regularRounded.exclamation,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFDC2626),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (_busy || !_formKey.currentState!.validate()) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    setState(() => _busy = true);

    final bloc = _getBloc();
    if (bloc != null) {
      bloc.add(
        AuthPasswordChangeRequested(
          currentPassword: currentPassword,
          newPassword: newPassword,
        ),
      );
      return;
    }

    // Direct fallback for isolated test harnesses without BLoC provider
    try {
      await widget.api.post('/auth/password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      await widget.api.forget();
      if (!mounted) return;
      _showSuccessSnackbar();
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) _showErrorSnackbar(e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Signature Teal Gradient Hero Card
                      _buildGradientHeroCard(),

                      SizedBox(height: 16.h),

                      // 2. Form Card (Clean Solid Surface)
                      _buildFormCard(),

                      SizedBox(height: 16.h),

                      // 3. Security Notice Banner
                      _buildSecurityNoticeBanner(),

                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Bottom Action Bar
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  /// Signature Teal Gradient Hero Card
  Widget _buildGradientHeroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
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
            color: const Color(0xFF0F766E).withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: Stack(
          children: [
            Positioned(
              top: -30.w,
              right: -30.w,
              child: Container(
                width: 130.w,
                height: 130.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              bottom: -40.w,
              left: 40.w,
              child: Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.45),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      UIcons.regularRounded.lock,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Keamanan Kata Sandi',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Perbarui kata sandi secara berkala untuk menjaga keamanan akun Anda.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.90),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Clean Solid Surface Form Card
  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.white,
          width: 1.5.w,
        ),
        boxShadow: const [AppShadows.shadow094],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDFA),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: const Color(0xFFCCFBF1),
                    width: 1.w,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  UIcons.regularRounded.key,
                  size: 18.sp,
                  color: AppColors.filterTealAccent,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Formulir Kata Sandi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Lengkapi data sandi lama dan sandi baru Anda.',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          SizedBox(height: 18.h),

          // 1. Password Saat Ini
          _buildFieldLabel(
            label: 'Password Saat Ini',
            isRequired: true,
          ),
          SizedBox(height: 6.h),
          TextFormField(
            key: const Key('current_password_input'),
            controller: _currentPasswordController,
            obscureText: _obscureCurrent,
            cursorColor: AppColors.filterTealAccent,
            style: _inputTextStyle,
            decoration: _inputDecoration(
              hint: 'Masukkan kata sandi saat ini',
              prefixIcon: UIcons.regularRounded.lock,
              isObscure: _obscureCurrent,
              onToggleObscure: () {
                setState(() => _obscureCurrent = !_obscureCurrent);
              },
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Masukkan kata sandi saat ini';
              }
              return null;
            },
          ),

          SizedBox(height: 18.h),

          // 2. Password Baru
          _buildFieldLabel(
            label: 'Password Baru',
            isRequired: true,
          ),
          SizedBox(height: 6.h),
          TextFormField(
            key: const Key('new_password_input'),
            controller: _newPasswordController,
            obscureText: _obscureNew,
            cursorColor: AppColors.filterTealAccent,
            style: _inputTextStyle,
            decoration: _inputDecoration(
              hint: 'Minimal 8 karakter',
              prefixIcon: UIcons.regularRounded.key,
              isObscure: _obscureNew,
              onToggleObscure: () {
                setState(() => _obscureNew = !_obscureNew);
              },
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Masukkan kata sandi baru';
              }
              if (value.trim().length < 8) {
                return 'Password minimal 8 karakter';
              }
              if (value.trim() == _currentPasswordController.text.trim()) {
                return 'Password baru harus berbeda dari password lama';
              }
              return null;
            },
          ),

          SizedBox(height: 18.h),

          // 3. Konfirmasi Password Baru
          _buildFieldLabel(
            label: 'Konfirmasi Password Baru',
            isRequired: true,
          ),
          SizedBox(height: 6.h),
          TextFormField(
            key: const Key('confirm_password_input'),
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            cursorColor: AppColors.filterTealAccent,
            style: _inputTextStyle,
            decoration: _inputDecoration(
              hint: 'Ulangi kata sandi baru',
              prefixIcon: UIcons.regularRounded.shield_check,
              isObscure: _obscureConfirm,
              onToggleObscure: () {
                setState(() => _obscureConfirm = !_obscureConfirm);
              },
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Konfirmasi kata sandi baru diperlukan';
              }
              if (value.trim() != _newPasswordController.text.trim()) {
                return 'Konfirmasi password tidak cocok';
              }
              return null;
            },
          ),

          SizedBox(height: 18.h),

          // Real-time Criteria Checklist
          _buildCriteriaChecklist(),
        ],
      ),
    );
  }

  /// Live Criteria Checklist Card
  Widget _buildCriteriaChecklist() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                UIcons.regularRounded.list_check,
                size: 15.sp,
                color: const Color(0xFF475569),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Kriteria Keamanan Sandi',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          _buildCriteriaItem(
            isValid: _isMin8,
            label: 'Minimal 8 karakter',
          ),
          SizedBox(height: 6.h),
          _buildCriteriaItem(
            isValid: _isDifferentFromCurrent,
            label: 'Berbeda dari password saat ini',
          ),
          SizedBox(height: 6.h),
          _buildCriteriaItem(
            isValid: _isConfirmMatching,
            label: 'Konfirmasi password cocok',
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem({
    required bool isValid,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          isValid
              ? UIcons.regularRounded.check
              : UIcons.regularRounded.circle,
          size: 16.sp,
          color: isValid ? const Color(0xFF00AA13) : const Color(0xFF94A3B8),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.5.sp,
              fontWeight: isValid ? FontWeight.w600 : FontWeight.w400,
              color:
                  isValid ? const Color(0xFF0F766E) : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }

  /// Security Notice Banner
  Widget _buildSecurityNoticeBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDFA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: const Color(0xFFCCFBF1),
          width: 1.w,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            UIcons.regularRounded.info,
            size: 18.sp,
            color: const Color(0xFF0D9488),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Setelah kata sandi berhasil diperbarui, seluruh sesi login aktif akan diakhiri dan Anda perlu masuk kembali.',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.5.sp,
                color: const Color(0xFF0F766E),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky Bottom Action Bar with Teal Gradient Button
  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.of(context).padding.bottom + 12.h,
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
        height: 50.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.r),
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
              color: const Color(0xFF0D9488).withValues(alpha: 0.28),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const Key('submit_change_password_button'),
            borderRadius: BorderRadius.circular(14.r),
            onTap: _busy ? null : _handleSubmit,
            child: Center(
              child: _busy
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          UIcons.regularRounded.lock,
                          size: 18.sp,
                          color: Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Simpan Kata Sandi',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel({
    required String label,
    required bool isRequired,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (isRequired) ...[
          SizedBox(width: 3.w),
          Text(
            '*',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    required bool isObscure,
    required VoidCallback onToggleObscure,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF94A3B8),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      prefixIcon: Icon(
        prefixIcon,
        size: 19.sp,
        color: const Color(0xFF64748B),
      ),
      suffixIcon: IconButton(
        icon: Icon(
          isObscure ? UIcons.regularRounded.eye_crossed : UIcons.regularRounded.eye,
          size: 19.sp,
          color: const Color(0xFF94A3B8),
        ),
        onPressed: onToggleObscure,
        splashRadius: 18.r,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: const Color(0xFFE2E8F0),
          width: 1.w,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: AppColors.filterTealAccent,
          width: 1.6.w,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: const Color(0xFFEF4444),
          width: 1.w,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: const Color(0xFFEF4444),
          width: 1.5.w,
        ),
      ),
      errorStyle: TextStyle(
        fontFamily: 'Inter',
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFEF4444),
      ),
    );
  }

  TextStyle get _inputTextStyle => TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5.sp,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  @override
  Widget build(BuildContext context) {
    final bloc = _getBloc();
    if (bloc == null) {
      return _buildBody(context);
    }

    return BlocConsumer<AuthBloc, AuthState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is AuthPasswordChangeSuccess) {
          _showSuccessSnackbar();
          Navigator.pop(context, true);
        } else if (state is AuthActionFailure) {
          setState(() => _busy = false);
          _showErrorSnackbar(state.message);
        } else if (state is AuthLoading) {
          setState(() => _busy = true);
        }
      },
      builder: (context, state) => _buildBody(context),
    );
  }
}

typedef ChangePasswordPage = ChangePasswordScreen;
