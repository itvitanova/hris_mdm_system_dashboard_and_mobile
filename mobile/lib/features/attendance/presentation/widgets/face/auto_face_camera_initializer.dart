import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:mdm_hris/core/api_client.dart';

class AutoFaceCameraInitializer {
  static Future<CameraController> initFrontCamera() async {
    final cameras = await availableCameras();
    final front = cameras
        .where((c) => c.lensDirection == CameraLensDirection.front)
        .firstOrNull;
    if (front == null) {
      throw ApiException(
        'Kamera depan tidak tersedia pada perangkat ini.',
      );
    }
    final camera = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    await camera.initialize();
    await camera.lockCaptureOrientation(DeviceOrientation.portraitUp);
    await camera.setFlashMode(FlashMode.off);
    return camera;
  }
}
