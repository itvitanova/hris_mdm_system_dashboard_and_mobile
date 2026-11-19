import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'abstract_teal_curves_painter.dart';

/// Abstract Teal Gradient Background with glowing orbs, fluid curves, and geometric glass accents
class AbstractTealBackground extends StatelessWidget {
  const AbstractTealBackground({super.key});

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
                Color(0xFF042F2E),
                Color(0xFF0F766E),
                Color(0xFF115E59),
                Color(0xFF0D9488),
              ],
              stops: [0.0, 0.35, 0.70, 1.0],
            ),
          ),
        ),

        // Fluid Abstract Vector Curves Painter
        const Positioned.fill(
          child: CustomPaint(
            painter: AbstractTealCurvesPainter(),
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
          top: -25.w,
          left: -25.w,
          child: Container(
            width: 150.w,
            height: 150.w,
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
          top: -5.w,
          left: -5.w,
          child: Container(
            width: 110.w,
            height: 110.w,
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
          top: -25.w,
          right: 25.w,
          child: Transform.rotate(
            angle: -0.32,
            child: Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(34.r),
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
          top: 45.w,
          right: -8.w,
          child: Transform.rotate(
            angle: 0.42,
            child: Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18.r),
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
