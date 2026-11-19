import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// CustomPainter that renders fluid abstract waves & glowing contours in teal
class AbstractTealCurvesPainter extends CustomPainter {
  const AbstractTealCurvesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final headerH = 147.w;

    // Upper sweeping abstract wave
    final path1 = Path();
    path1.moveTo(0, headerH * 0.65);
    path1.cubicTo(
      size.width * 0.35,
      headerH * 0.25,
      size.width * 0.65,
      headerH * 0.85,
      size.width,
      headerH * 0.50,
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
      ).createShader(Rect.fromLTWH(0, 0, size.width, headerH));

    canvas.drawPath(path1, paint1);

    // Diagonal intersecting secondary wave
    final path2 = Path();
    path2.moveTo(0, headerH * 0.88);
    path2.cubicTo(
      size.width * 0.4,
      headerH * 0.55,
      size.width * 0.7,
      headerH * 0.95,
      size.width,
      headerH * 0.70,
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
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, headerH));

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
      ).createShader(Rect.fromLTWH(0, 0, size.width, headerH));

    final linePath = Path();
    linePath.moveTo(0, headerH * 0.78);
    linePath.cubicTo(
      size.width * 0.3,
      headerH * 0.45,
      size.width * 0.75,
      headerH * 0.88,
      size.width,
      headerH * 0.55,
    );
    canvas.drawPath(linePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
