import 'package:flutter/material.dart';
import '../face_capture_gate.dart';

class FaceGuidePainter extends CustomPainter {
  FaceGuidePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final guide = Rect.fromLTRB(
      faceGuide.left * size.width,
      faceGuide.top * size.height,
      faceGuide.right * size.width,
      faceGuide.bottom * size.height,
    );
    final rounded = RRect.fromRectAndRadius(guide, const Radius.circular(24));
    final mask = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(rounded);
    canvas.drawPath(mask, Paint()..color = const Color(0x88000000));
    canvas.drawRRect(
      rounded,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(FaceGuidePainter oldDelegate) => color != oldDelegate.color;
}
