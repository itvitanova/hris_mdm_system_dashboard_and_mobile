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

  Widget _buildTopHeader() {
    return SizedBox(
      height: 147.w,
      width: double.infinity,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.28),
                      width: 1.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        color: const Color(0xFF5EEAD4),
                        size: 15.w,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'MDM ATTENDANCE SYSTEM',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, bool isLoading) {
    return Scaffold(
      backgroundColor: const Color(0xFF042F2E),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // ================= ABSTRACT TEAL GRADIENT BACKGROUND =================
          const Positioned.fill(
            child: _AbstractTealBackground(),
          ),

          // ================= SCROLLABLE CONTENT =================
          CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    // Top Header with brand pill and abstract ambience
                    _buildTopHeader(),

                    // Bottom White Card
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.zero,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(32.r),
                            topRight: Radius.circular(32.r),
                          ),
                          border: Border(
                            top: BorderSide(
                              color: Colors.white.withValues(alpha: 0.8),
                              width: 1.5.w,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A)
                                  .withValues(alpha: 0.16),
                              blurRadius: 30,
                              offset: const Offset(0, -8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(height: 12.w),
                              // Handle bar
                              Container(
                                width: 38.w,
                                height: 4.w,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFCBD5E1),
                                  borderRadius: BorderRadius.circular(2.w),
                                ),
                              ),
                              SizedBox(height: 28.w),
                              SizedBox(
                                width: 150.w,
                                height: 56.w,
                                child: Image.asset(
                                  "assets/img/app_logo.png",
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Center(
                                    child: Text(
                                      'MDM HR',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22.sp,
                                        color: AppColors.filterGradientStart,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 40.w),
                              SizedBox(
                                width: 322.w,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome Back, 👋",
                                      style: AppTextStyles.interExtraBold18,
                                    ),
                                    SizedBox(height: 5.h),
                                    Text(
                                      "Please enter your login details to access your account.",
                                      style: AppTextStyles
                                          .inter13RegularSecondary,
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
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    autofillHints: const [
                                      AutofillHints.username
                                    ],
                                    textInputAction: TextInputAction.next,
                                    validator: (v) =>
                                        v == null || !v.contains('@')
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
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => submit(),
                                    validator: (v) =>
                                        v == null || v.isEmpty
                                            ? 'Masukkan kata sandi'
                                            : null,
                                  ),
                                  SizedBox(height: 10.h),
                                  SizedBox(
                                    width: 322.w,
                                    child: Row(
                                      children: [
                                        Checkbox(
                                          value: isChecked,
                                          visualDensity:
                                              VisualDensity.compact,
                                          materialTapTargetSize:
                                              MaterialTapTargetSize
                                                  .shrinkWrap,
                                          onChanged: isLoading
                                              ? null
                                              : (bool? value) {
                                                  setState(() {
                                                    isChecked =
                                                        value ?? false;
                                                  });
                                                },
                                          activeColor:
                                              AppColors.filterTealAccent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          side: BorderSide(
                                            color: const Color(0xFFCBD5E1),
                                            width: 1.3.w,
                                          ),
                                        ),
                                        SizedBox(width: 6.w),
                                        Expanded(
                                          child: Text(
                                            "Remember me",
                                            style: AppTextStyles
                                                .inter128RegularPrimary,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            "Forgot Password",
                                            style: TextStyle(
                                              fontFamily: 'Inter',
                                              fontSize: 12.sp,
                                              color: isLoading
                                                  ? AppColors.textTertiary
                                                  : AppColors
                                                      .filterTealAccent,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 30.w),
                              // Gradient Sign In Button
                              Container(
                                width: 322.w,
                                height: 48.w,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(12.r),
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
                                      color: const Color(0xFF0D9488)
                                          .withValues(alpha: 0.32),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius:
                                        BorderRadius.circular(12.r),
                                    onTap: isLoading ? null : submit,
                                    child: Center(
                                      child: isLoading
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              mainAxisSize:
                                                  MainAxisSize.min,
                                              children: [
                                                SizedBox(
                                                  width: 18.w,
                                                  height: 18.w,
                                                  child:
                                                      const CircularProgressIndicator(
                                                    strokeWidth: 2.2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(
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
                                                    fontWeight:
                                                        FontWeight.w600,
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
                                                fontWeight:
                                                    FontWeight.w600,
                                                fontSize: 14.sp,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.w),
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

/// Abstract Teal Gradient Background with glowing orbs, fluid curves, and geometric glass accents
class _AbstractTealBackground extends StatelessWidget {
  const _AbstractTealBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Multi-stop Teal Gradient
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF042F2E), // Deep midnight teal
                Color(0xFF0F766E), // Corporate teal start
                Color(0xFF115E59), // Rich medium teal
                Color(0xFF0D9488), // Signature corporate teal
              ],
              stops: [0.0, 0.35, 0.70, 1.0],
            ),
          ),
        ),

        // Fluid Abstract Vector Curves Painter
        Positioned.fill(
          child: CustomPaint(
            painter: _AbstractTealCurvesPainter(),
          ),
        ),

        // Glowing Radial Orb 1 (Top Right)
        Positioned(
          top: -60.w,
          right: -40.w,
          child: Container(
            width: 260.w,
            height: 260.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF2DD4BF).withValues(alpha: 0.35),
                  const Color(0xFF14B8A6).withValues(alpha: 0.12),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // Glowing Radial Orb 2 (Mid Left)
        Positioned(
          top: 60.w,
          left: -60.w,
          child: Container(
            width: 200.w,
            height: 200.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF14B8A6).withValues(alpha: 0.25),
                  const Color(0xFF0F766E).withValues(alpha: 0.08),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.60, 1.0],
              ),
            ),
          ),
        ),

        // Abstract Concentric Rings (Top Left)
        Positioned(
          top: 15.w,
          left: -25.w,
          child: Container(
            width: 170.w,
            height: 170.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF5EEAD4).withValues(alpha: 0.16),
                width: 1.2.w,
              ),
            ),
          ),
        ),
        Positioned(
          top: 40.w,
          left: 0,
          child: Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF2DD4BF).withValues(alpha: 0.10),
                width: 1.w,
              ),
            ),
          ),
        ),

        // Abstract Rotated Frosted Squircle (Top Right / Center)
        Positioned(
          top: -20.w,
          right: 25.w,
          child: Transform.rotate(
            angle: -0.32,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(36.r),
                color: Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.14),
                  width: 1.w,
                ),
              ),
            ),
          ),
        ),

        // Smaller Abstract Diamond Squircle (Floating Mid-Right)
        Positioned(
          top: 80.w,
          right: -10.w,
          child: Transform.rotate(
            angle: 0.42,
            child: Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22.r),
                color: const Color(0xFF2DD4BF).withValues(alpha: 0.06),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.w,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// CustomPainter that renders fluid abstract waves & glowing contours in teal
class _AbstractTealCurvesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Upper sweeping abstract wave
    final path1 = Path();
    path1.moveTo(0, size.height * 0.18);
    path1.cubicTo(
      size.width * 0.35,
      size.height * 0.08,
      size.width * 0.65,
      size.height * 0.28,
      size.width,
      size.height * 0.15,
    );
    path1.lineTo(size.width, 0);
    path1.lineTo(0, 0);
    path1.close();

    final paint1 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF2DD4BF).withValues(alpha: 0.20),
          const Color(0xFF14B8A6).withValues(alpha: 0.05),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.3));

    canvas.drawPath(path1, paint1);

    // Diagonal intersecting secondary wave
    final path2 = Path();
    path2.moveTo(0, size.height * 0.32);
    path2.cubicTo(
      size.width * 0.4,
      size.height * 0.22,
      size.width * 0.7,
      size.height * 0.38,
      size.width,
      size.height * 0.24,
    );
    path2.lineTo(size.width, 0);
    path2.lineTo(0, 0);
    path2.close();

    final paint2 = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          const Color(0xFF14B8A6).withValues(alpha: 0.14),
          const Color(0xFF0F766E).withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.4));

    canvas.drawPath(path2, paint2);

    // Glowing subtle contour stroke line
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          const Color(0xFF5EEAD4).withValues(alpha: 0.30),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final linePath = Path();
    linePath.moveTo(0, size.height * 0.25);
    linePath.cubicTo(
      size.width * 0.3,
      size.height * 0.15,
      size.width * 0.75,
      size.height * 0.30,
      size.width,
      size.height * 0.18,
    );
    canvas.drawPath(linePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

typedef LoginPage = LoginScreen;
