import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/di/injection_container.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login/abstract_teal_background.dart';
import '../widgets/login/auth_remember_me_service.dart';
import '../widgets/login/login_error_snackbar.dart';
import '../widgets/login/login_form_card.dart';
import '../widgets/login/login_top_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.api,
    this.onLogin,
    this.authBloc,
    this.storage,
  });

  final ApiClient? api;
  final VoidCallback? onLogin;
  final AuthBloc? authBloc;
  final FlutterSecureStorage? storage;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final emailTextC = TextEditingController();
  final passwordTextC = TextEditingController();
  bool isChecked = false, busy = false;
  String? error;

  FlutterSecureStorage get _storage =>
      widget.storage ?? (sl.isRegistered<FlutterSecureStorage>() ? sl<FlutterSecureStorage>() : const FlutterSecureStorage());

  @override
  void initState() {
    super.initState();
    _loadRemembered();
  }

  Future<void> _loadRemembered() async {
    final c = await AuthRememberMeService.load(_storage);
    if (c.isEnabled && mounted) {
      setState(() {
        isChecked = true;
        if (c.email != null) emailTextC.text = c.email!;
        if (c.password != null) passwordTextC.text = c.password!;
      });
    }
  }

  Future<void> _handleRememberMe([String? email, String? password]) async {
    final e = (email != null && email.isNotEmpty) ? email : emailTextC.text.trim();
    final p = (password != null && password.isNotEmpty) ? password : passwordTextC.text;
    if (isChecked) {
      await AuthRememberMeService.save(_storage, e, p);
    } else {
      await AuthRememberMeService.clear(_storage);
    }
  }

  @override
  void dispose() {
    emailTextC.dispose();
    passwordTextC.dispose();
    super.dispose();
  }

  AuthBloc? _getBloc() {
    if (widget.authBloc != null) return widget.authBloc;
    try { return context.read<AuthBloc>(); } catch (_) { return null; }
  }

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final bloc = _getBloc();
    if (bloc != null) {
      if (bloc.state is AuthLoading) return;
      bloc.add(AuthLoginRequested(email: emailTextC.text.trim(), password: passwordTextC.text));
      return;
    }

    final api = widget.api ?? (sl.isRegistered<ApiClient>() ? sl<ApiClient>() : ApiClient());
    setState(() { busy = true; error = null; });
    try {
      await api.login(emailTextC.text.trim(), passwordTextC.text);
      if (mounted) {
        await _handleRememberMe();
        if (!isChecked) passwordTextC.clear();
        widget.onLogin?.call();
      }
    } catch (e) {
      if (mounted) {
        final errText = e.toString().replaceFirst(RegExp(r'^[A-Za-z]+Exception:\s*'), '');
        setState(() => error = errText);
        LoginErrorSnackBar.show(context, errText);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget _buildForm(BuildContext context, bool isLoading) {
    return Scaffold(
      backgroundColor: const Color(0xFF042F2E),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: AbstractTealBackground()),
          CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    const LoginTopHeader(),
                    Expanded(
                      child: LoginFormCard(
                        formKey: form,
                        emailController: emailTextC,
                        passwordController: passwordTextC,
                        isChecked: isChecked,
                        isLoading: isLoading,
                        onRememberMeChanged: (val) {
                          setState(() => isChecked = val);
                          if (!val) AuthRememberMeService.clear(_storage);
                        },
                        onSubmit: submit,
                      ),
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

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) {
        final bloc = _getBloc();
        if (bloc == null) return _buildForm(context, busy);

        return BlocConsumer<AuthBloc, AuthState>(
          bloc: bloc,
          listener: (context, state) {
            if (state is Authenticated) {
              _handleRememberMe(emailTextC.text.trim(), passwordTextC.text);
              if (!isChecked) passwordTextC.clear();
              if (busy || error != null) setState(() { busy = false; error = null; });
            } else if (state is Unauthenticated) {
              if (isChecked) { _loadRemembered(); } else { passwordTextC.clear(); }
              if (busy || error != null) setState(() { busy = false; error = null; });
            } else if (state is AuthActionFailure) {
              setState(() { busy = false; error = state.message; });
              LoginErrorSnackBar.show(context, state.message);
            } else if (state is AuthLoading) {
              setState(() { busy = true; error = null; });
            }
          },
          builder: (context, state) => _buildForm(context, state is AuthLoading),
        );
      },
    );
  }
}

typedef LoginPage = LoginScreen;
