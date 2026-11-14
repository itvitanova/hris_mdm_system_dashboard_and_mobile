import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

/// Splash Screen menampilkan animasi logo saat aplikasi baru dibuka.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onAnimationComplete,
    this.fallbackTimeout = const Duration(seconds: 4),
  });

  final VoidCallback onAnimationComplete;
  final Duration fallbackTimeout;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _timer = Timer(widget.fallbackTimeout, _finish);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    if (_completed || !mounted) return;
    _completed = true;
    _timer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onAnimationComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          width: 260.w,
          child: Lottie.asset(
            'assets/lottie/vita_nova_logo.json',
            controller: _controller,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              _timer?.cancel();
              _controller.duration = composition.duration;
              _controller.forward().then((_) => _finish());
            },
            errorBuilder: (context, error, stackTrace) {
              _finish();
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}
