import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:mdm_hris/core/widgets/core_widgets.dart';
import 'face_camera_preview_frame.dart';
import 'face_header_section.dart';
import 'face_scan_feedback_section.dart';

class AutoFaceBody extends StatelessWidget {
  const AutoFaceBody({
    super.key,
    required this.enrollment,
    required this.camera,
    required this.capturing,
    required this.aligned,
    required this.error,
    required this.hint,
    required this.progress,
    required this.onRetry,
  });

  final bool enrollment;
  final CameraController? camera;
  final bool capturing;
  final bool aligned;
  final String? error;
  final String hint;
  final double progress;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final initialized = camera != null && camera!.value.isInitialized;
    final color = capturing ? brand : aligned ? Colors.teal : Colors.white;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          FaceHeaderSection(enrollment: enrollment),
          const SizedBox(height: 24),
          FaceCameraPreviewFrame(
            camera: camera,
            initialized: initialized,
            capturing: capturing,
            hasError: error != null,
            color: color,
          ),
          const SizedBox(height: 20),
          FaceScanFeedbackSection(
            error: error,
            hint: hint,
            color: color,
            capturing: capturing,
            progress: progress,
            onRetry: onRetry,
          ),
          const SizedBox(height: 20),
          const Text(
            'Posisi wajah yang sesuai belum berarti identitas terverifikasi. Kamera tidak merekam video atau audio.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
