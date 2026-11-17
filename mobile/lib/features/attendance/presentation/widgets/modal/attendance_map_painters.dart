import 'package:flutter/material.dart';

/// Painter to draw subtle map streets and rivers inside map visual card
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final streetPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke;

    final borderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal street
    canvas.drawLine(
      Offset(0, size.height * 0.5),
      Offset(size.width, size.height * 0.5),
      streetPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5 - 3),
      Offset(size.width, size.height * 0.5 - 3),
      borderPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.5 + 3),
      Offset(size.width, size.height * 0.5 + 3),
      borderPaint,
    );

    // Vertical street
    canvas.drawLine(
      Offset(size.width * 0.38, 0),
      Offset(size.width * 0.38, size.height),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.38 - 3, 0),
      Offset(size.width * 0.38 - 3, size.height),
      borderPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.38 + 3, 0),
      Offset(size.width * 0.38 + 3, size.height),
      borderPaint,
    );

    // Secondary vertical street
    canvas.drawLine(
      Offset(size.width * 0.78, 0),
      Offset(size.width * 0.78, size.height),
      streetPaint,
    );

    // Subtle blue curved river on top left
    final riverPaint = Paint()
      ..color = const Color(0xFFDBEAFE)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.3)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.25,
        size.width * 0.45,
        0,
      )
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, riverPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Painter to draw dashed connection line between office and user pin
class DashedLinePainter extends CustomPainter {
  final Color color;

  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 4.0;
    const dashSpace = 3.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedLinePainter oldDelegate) => oldDelegate.color != color;
}
