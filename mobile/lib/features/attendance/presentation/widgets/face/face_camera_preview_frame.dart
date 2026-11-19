import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'face_guide_painter.dart';

class FaceCameraPreviewFrame extends StatelessWidget {
  const FaceCameraPreviewFrame({
    super.key,
    required this.camera,
    required this.initialized,
    required this.capturing,
    required this.hasError,
    required this.color,
  });

  final CameraController? camera;
  final bool initialized;
  final bool capturing;
  final bool hasError;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: initialized ? 1 / camera!.value.aspectRatio : 3 / 4,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (initialized)
              CameraPreview(camera!)
            else
              const ColoredBox(color: Color(0xFF1E293B)),
            if (!initialized && !hasError)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            IgnorePointer(
              child: CustomPaint(painter: FaceGuidePainter(color)),
            ),
            if (capturing)
              const ColoredBox(
                color: Color(0x770F172A),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
