import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:mdm_hris/core/widgets/core_widgets.dart';
import 'auto_face_capture_validator.dart';

class AutoFaceCaptureService {
  static Future<void> captureAndSubmit({
    required BuildContext context,
    required CameraController camera,
    required FaceDetector detector,
    required bool enrollment,
    required Future<void> Function(XFile) onCapture,
    required bool Function() isAborted,
  }) async {
    XFile? candidate;
    try {
      await camera.stopImageStream();
      candidate = await camera.takePicture();
      if (isAborted() || !context.mounted) return;

      await AutoFaceCaptureValidator.validateStill(
        filePath: candidate.path,
        detector: detector,
      );
      if (isAborted() || !context.mounted) return;

      await onCapture(candidate);
      if (context.mounted && !isAborted()) {
        notify(
          context,
          enrollment
              ? 'Wajah berhasil didaftarkan. Anda dapat melakukan absensi.'
              : 'Wajah terverifikasi. Absensi berhasil dicatat.',
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (candidate != null) {
        try {
          await File(candidate.path).delete();
        } catch (_) {}
      }
    }
  }
}
