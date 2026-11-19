import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:mdm_hris/core/api_client.dart';

class AutoFaceCaptureValidator {
  static Future<void> validateStill({
    required String filePath,
    required FaceDetector detector,
  }) async {
    final faces = await detector.processImage(
      InputImage.fromFilePath(filePath),
    );
    if (faces.length != 1) {
      throw ApiException(
        'Wajah berubah saat pemindaian. Silakan pindai ulang.',
      );
    }
    final face = faces.single;
    if ([
      face.headEulerAngleX,
      face.headEulerAngleY,
      face.headEulerAngleZ,
    ].any((v) => v == null || !v.isFinite || v.abs() > 20)) {
      throw ApiException('Lihat lurus ke kamera, lalu pindai ulang.');
    }
  }
}
