import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/auth_event.dart';
import '../blocs/auth_state.dart';
import '../widgets/input_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    this.api,
    this.onLogin,
    this.authBloc,
  });

  final ApiClient? api;
  final VoidCallback? onLogin;
  final AuthBloc? authBloc;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final form = GlobalKey<FormState>();
  final emailTextC = TextEditingController();
  final passwordTextC = TextEditingController();
  bool isChecked = false;
  bool busy = false;
  String? error;

  @override
  void dispose() {
    emailTextC.dispose();
    passwordTextC.dispose();
    super.dispose();
  }

  AuthBloc? _getBloc() {
    if (widget.authBloc != null) return widget.authBloc;
    try {
      return context.read<AuthBloc>();
    } catch (_) {
      return null;
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.red,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.w),
        ),
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.white,
              size: 20.w,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> submit() async {
    if (busy || !form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final bloc = _getBloc();
    if (bloc != null) {
      bloc.add(
        AuthLoginRequested(
          email: emailTextC.text.trim(),
          password: passwordTextC.text,
        ),
      );
      return;
    }

    // Direct fallback for isolated test harnesses without BLoC provider
    final api = widget.api ??
        (sl.isRegistered<ApiClient>() ? sl<ApiClient>() : ApiClient());
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await api.login(emailTextC.text.trim(), passwordTextC.text);
      if (mounted) {
        passwordTextC.clear();
        widget.onLogin?.call();
      }
    } catch (e) {
      if (mounted) {
        final errText =
            e.toString().replaceFirst(RegExp(r'^[A-Za-z]+Exception:\s*'), '');
        setState(() => error = errText);
        _showErrorSnackBar(errText);
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget _buildForm(BuildContext context, bool isLoading) {
    return Scaffold(
      backgroundColor: AppColors.deepTeal,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                SizedBox(height: 147.w),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.w),
                        topRight: Radius.circular(30.w),
                      ),
                    ),
                    child: Form(
                      key: form,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60.w),
                          SizedBox(
                            width: 150.w,
                            height: 56.w,
                            child: Image.asset(
                              "assets/img/app_logo.png",
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Text(
                                  'MDM HR',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                    color: AppColors.deepTeal,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 60.w),
                          SizedBox(
                            width: 322.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Welcome Back, 👋",
                                  style: AppTextStyles.interExtraBold18,
                                ),
                                SizedBox(height: 5.h),
                                Text(
                                  "Please enter your login details to access your account.",
                                  style: AppTextStyles.inter13RegularSecondary,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.w),
                          Column(
                            children: [
                              InputAuth(
                                label: "E-Mail",
                                hintText: "Enter your email",
                                isPassword: false,
                                controller: emailTextC,
                                enabled: !isLoading,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.username],
                                textInputAction: TextInputAction.next,
                                validator: (v) => v == null || !v.contains('@')
                                    ? 'Masukkan email yang valid'
                                    : null,
                              ),
                              SizedBox(height: 10.h),
                              InputAuth(
                                label: "Password",
                                hintText: "Enter your password",
                                isPassword: true,
                                controller: passwordTextC,
                                enabled: !isLoading,
                                autofillHints: const [AutofillHints.password],
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => submit(),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Masukkan kata sandi'
                                    : null,
                              ),
                              SizedBox(height: 8.h),
                              SizedBox(
                                width: 322.w,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: InkWell(
                                        onTap: isLoading
                                            ? null
                                            : () {
                                                setState(() {
                                                  isChecked = !isChecked;
                                                });
                                              },
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Checkbox(
                                              value: isChecked,
                                              onChanged: isLoading
                                                  ? null
                                                  : (bool? value) {
                                                      setState(() {
                                                        isChecked =
                                                            value ?? false;
                                                      });
                                                    },
                                              activeColor: AppColors.deepTeal,
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            ),
                                            Flexible(
                                              child: Text(
                                                "Remember me",
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTextStyles
                                                    .inter128RegularPrimary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "Forgot Password",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12.sp,
                                        color: isLoading
                                            ? AppColors.textTertiary
                                            : Colors.blue,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          SizedBox(
                            width: 322.w,
                            height: 45.w,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.deepTeal,
                                disabledBackgroundColor: AppColors.deepTeal
                                    .withValues(alpha: 0.65),
                                splashFactory: InkRipple.splashFactory,
                                overlayColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.w),
                                ),
                              ),
                              child: isLoading
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SizedBox(
                                          width: 18.w,
                                          height: 18.w,
                                          child:
                                              const CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.white,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Text(
                                          "Signing In...",
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            color: AppColors.white,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Text(
                                      "Sign In",
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 30.h),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) {
        final bloc = _getBloc();
        if (bloc == null) {
          return _buildForm(context, busy);
        }

        return BlocConsumer<AuthBloc, AuthState>(
          bloc: bloc,
          listener: (context, state) {
            if (state is Authenticated) {
              passwordTextC.clear();
              widget.onLogin?.call();
            } else if (state is AuthActionFailure) {
              setState(() {
                busy = false;
                error = state.message;
              });
              _showErrorSnackBar(state.message);
            } else if (state is AuthLoading) {
              setState(() {
                busy = true;
                error = null;
              });
            }
          },
          builder: (context, state) =>
              _buildForm(context, busy || state is AuthLoading),
        );
      },
    );
  }
}

typedef LoginPage = LoginScreen;
