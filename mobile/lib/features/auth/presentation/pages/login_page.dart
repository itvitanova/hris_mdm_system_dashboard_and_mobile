import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/api_client.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.filterGradientStart,
              AppColors.filterGradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    // Atmospheric Header with Fintech Card Gradient Overlay (~185w)
                    const _FintechCardWavesHeader(),

                    // Form Sheet
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28.r),
                            topRight: Radius.circular(28.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 20,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: 26.w,
                          vertical: 22.w,
                        ),
                        child: Form(
                          key: form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // App Logo Center
                              Center(
                                child: Image.asset(
                                  'assets/img/app_logo.png',
                                  height: 42.w,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Text(
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
                              SizedBox(height: 12.w),

                              // Soft Corporate Badge
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 3.w,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0FDFA),
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(
                                    color: const Color(0xFFCCFBF1),
                                    width: 1.w,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 5.w,
                                      height: 5.w,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF0D9488),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'PORTAL PRESENSI KARYAWAN',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 8.5.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0F766E),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 6.w),

                              // Greeting Block
                              Text(
                                'Welcome Back, 👋',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1E293B),
                                  letterSpacing: -0.2,
                                ),
                              ),
                              SizedBox(height: 3.w),
                              Text(
                                'Please enter your login details to access your account.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B),
                                  height: 1.35,
                                ),
                              ),
                              SizedBox(height: 16.w),

                              // Form Inputs
                              InputAuth(
                                label: 'E-Mail',
                                hintText: 'Enter your email',
                                controller: emailTextC,
                                isPassword: false,
                                enabled: !isLoading,
                                prefixIcon: Icons.mail_outline_rounded,
                                keyboardType: TextInputType.emailAddress,
                                autofillHints: const [AutofillHints.username],
                                textInputAction: TextInputAction.next,
                                validator: (v) => v == null || !v.contains('@')
                                    ? 'Masukkan email yang valid'
                                    : null,
                              ),
                              SizedBox(height: 14.w),
                              InputAuth(
                                label: 'Password',
                                hintText: 'Enter your password',
                                controller: passwordTextC,
                                isPassword: true,
                                enabled: !isLoading,
                                prefixIcon: Icons.lock_outline_rounded,
                                autofillHints: const [AutofillHints.password],
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => submit(),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Masukkan kata sandi'
                                    : null,
                              ),
                              SizedBox(height: 12.w),

                              // Remember Me & Forgot Password Row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(6.r),
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
                                          SizedBox(
                                            width: 20.w,
                                            height: 20.w,
                                            child: Checkbox(
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(4.r),
                                              ),
                                              side: BorderSide(
                                                color: const Color(0xFFCBD5E1),
                                                width: 1.3.w,
                                              ),
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Flexible(
                                            child: Text(
                                              'Remember me',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w500,
                                                color: const Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(6.r),
                                    onTap: () {},
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.w,
                                        vertical: 2.w,
                                      ),
                                      child: Text(
                                        'Forgot Password?',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.deepTeal,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.w),

                              // Sign In Primary Gradient Button
                              Container(
                                width: double.infinity,
                                height: 48.w,
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
                                      color: const Color(0xFF0D9488)
                                          .withValues(alpha: 0.28),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(14.r),
                                    onTap: isLoading ? null : submit,
                                    child: Center(
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
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(AppColors.white),
                                                  ),
                                                ),
                                                SizedBox(width: 10.w),
                                                Text(
                                                  'Signing In...',
                                                  style: TextStyle(
                                                    fontFamily: 'Inter',
                                                    color: AppColors.white,
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 14.5.sp,
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              'Sign In',
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: AppColors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14.5.sp,
                                                letterSpacing: 0.2,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.w),
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
        ),
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

/// Header Atmospheric dengan Gradient Overlay Kurva Kartu Debit/Fintech (~185w)
class _FintechCardWavesHeader extends StatelessWidget {
  const _FintechCardWavesHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 185.w,
      child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient Radial Glow (Top-Right Mint)
            Positioned(
              top: -30.w,
              right: -20.w,
              child: Container(
                width: 200.w,
                height: 200.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF5EEAD4).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Fintech Card Overlapping Waves Overlay
            const CustomPaint(
              painter: _FintechCardWavesPainter(),
            ),
          ],
        ),
      ),
    );
  }
}

/// CustomPainter untuk rendering gelombang kurva bertingkat gaya fintech
class _FintechCardWavesPainter extends CustomPainter {
  const _FintechCardWavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Wave 1: Lapisan Kurva Atas (Soft Frosted Fill)
    final path1 = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.45)
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.20,
        size.width * 0.35,
        size.height * 0.70,
        0,
        size.height * 0.55,
      )
      ..close();

    final paint1 = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.03),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);

    canvas.drawPath(path1, paint1);

    // Wave 2: Lapisan Kurva Tengah / Gelombang Silang
    final path2 = Path()
      ..moveTo(0, size.height * 0.35)
      ..cubicTo(
        size.width * 0.30,
        size.height * 0.80,
        size.width * 0.70,
        size.height * 0.15,
        size.width,
        size.height * 0.65,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final paint2 = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [
          Colors.white.withValues(alpha: 0.08),
          const Color(0xFF5EEAD4).withValues(alpha: 0.09),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawPath(path2, paint2);

    // Wave 3: Garis Aksen Kontur Tipis (Frosted Shimmer Line)
    final path3 = Path()
      ..moveTo(0, size.height * 0.60)
      ..cubicTo(
        size.width * 0.40,
        size.height * 0.35,
        size.width * 0.70,
        size.height * 0.85,
        size.width,
        size.height * 0.45,
      );

    final paint3 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.20),
          const Color(0xFF5EEAD4).withValues(alpha: 0.25),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.70, 1.0],
      ).createShader(rect);

    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

typedef LoginPage = LoginScreen;
