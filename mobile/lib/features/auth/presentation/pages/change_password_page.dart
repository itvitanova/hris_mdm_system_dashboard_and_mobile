import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/theme/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/change_password/change_password_app_bar.dart';
import '../widgets/change_password/change_password_bottom_bar.dart';
import '../widgets/change_password/change_password_form_card.dart';
import '../widgets/change_password/change_password_hero_card.dart';
import '../widgets/change_password/change_password_security_notice.dart';
import '../widgets/change_password/change_password_snackbar_helper.dart';

/// Halaman Ubah Password Karyawan
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

  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
    if (mounted) setState(() {});
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
    try { return context.read<AuthBloc>(); } catch (_) { return null; }
  }

  Future<void> _handleSubmit() async {
    FocusScope.of(context).unfocus();
    if (_busy || !_formKey.currentState!.validate()) return;

    final currentPassword = _currentPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();

    setState(() => _busy = true);

    final bloc = _getBloc();
    if (bloc != null) {
      bloc.add(AuthPasswordChangeRequested(
        currentPassword: currentPassword,
        newPassword: newPassword,
      ));
      return;
    }

    try {
      await widget.api.post('/auth/password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
      await widget.api.forget();
      if (!mounted) return;
      ChangePasswordSnackbarHelper.showSuccess(context);
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ChangePasswordSnackbarHelper.showError(context, e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _buildBody(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: const ChangePasswordAppBar(),
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
                      const ChangePasswordHeroCard(),
                      SizedBox(height: 16.h),
                      ChangePasswordFormCard(
                        currentPasswordController: _currentPasswordController,
                        newPasswordController: _newPasswordController,
                        confirmPasswordController: _confirmPasswordController,
                        obscureCurrent: _obscureCurrent,
                        obscureNew: _obscureNew,
                        obscureConfirm: _obscureConfirm,
                        onToggleCurrent: () => setState(() => _obscureCurrent = !_obscureCurrent),
                        onToggleNew: () => setState(() => _obscureNew = !_obscureNew),
                        onToggleConfirm: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        isMin8: _isMin8,
                        isDifferentFromCurrent: _isDifferentFromCurrent,
                        isConfirmMatching: _isConfirmMatching,
                      ),
                      SizedBox(height: 16.h),
                      const ChangePasswordSecurityNotice(),
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ),
            ),
            ChangePasswordBottomBar(
              busy: _busy,
              onSubmit: _handleSubmit,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bloc = _getBloc();
    if (bloc == null) return _buildBody(context);

    return BlocConsumer<AuthBloc, AuthState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is AuthPasswordChangeSuccess) {
          ChangePasswordSnackbarHelper.showSuccess(context);
          Navigator.pop(context, true);
        } else if (state is AuthActionFailure) {
          setState(() => _busy = false);
          ChangePasswordSnackbarHelper.showError(context, state.message);
        } else if (state is AuthLoading) {
          setState(() => _busy = true);
        }
      },
      builder: (context, state) => _buildBody(context),
    );
  }
}

typedef ChangePasswordPage = ChangePasswordScreen;
