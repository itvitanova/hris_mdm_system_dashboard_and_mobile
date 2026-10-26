import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import '../../../../core/api_client.dart';

/// Native exceptions may contain an entire Java stack trace. Keep that detail
/// out of the camera UI while preserving actionable API validation messages.
String cameraErrorMessage(Object error) {
  if (error is ApiException) return error.message;
  if (error is CameraException && error.code.contains('AccessDenied')) {
    return 'Izin kamera diperlukan. Aktifkan izin kamera di pengaturan aplikasi.';
  }
  if (error is PlatformException &&
      (error.code == 'InputImageConverterError' ||
          error.code == 'FaceDetectorError')) {
    return 'Pemindai wajah belum dapat memproses gambar kamera. Tutup pemindai lalu coba lagi.';
  }
  if (error is TimeoutException) {
    return 'Pemindaian terlalu lama. Periksa koneksi lalu coba lagi.';
  }
  return 'Pemindaian belum berhasil. Tutup pemindai lalu coba lagi.';
}
