import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/api_client.dart';
import 'face_capture_gate.dart';

const _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

InputImage cameraInput(CameraImage image, CameraController controller) {
  final camera = controller.description;
  var degrees = camera.sensorOrientation;
  if (Platform.isAndroid) {
    final device =
        _orientations[controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation]!;
    degrees = camera.lensDirection == CameraLensDirection.front
        ? (degrees + device) % 360
        : (degrees - device + 360) % 360;
  }
  final rotation = InputImageRotationValue.fromRawValue(degrees);
  final format = InputImageFormatValue.fromRawValue(image.format.raw);
  if (rotation == null ||
      image.planes.length != 1 ||
      (Platform.isAndroid && format != InputImageFormat.nv21) ||
      (Platform.isIOS && format != InputImageFormat.bgra8888)) {
    throw ApiException(
      'Format kamera tidak didukung. Tutup pemindai lalu coba lagi.',
    );
  }
  return InputImage.fromBytes(
    bytes: image.planes.single.bytes,
    metadata: InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format!,
      bytesPerRow: image.planes.single.bytesPerRow,
    ),
  );
}

List<FaceObservation> observations(
  List<Face> faces,
  InputImage input, {
  required bool mirrored,
}) {
  final metadata = input.metadata!;
  final rotate =
      Platform.isAndroid &&
      (metadata.rotation == InputImageRotation.rotation90deg ||
          metadata.rotation == InputImageRotation.rotation270deg);
  final width = rotate ? metadata.size.height : metadata.size.width;
  final height = rotate ? metadata.size.width : metadata.size.height;
  return faces.map((face) {
    final r = face.boundingBox;
    final bounds = mirrored
        ? Rect.fromLTRB(
            1 - r.right / width,
            r.top / height,
            1 - r.left / width,
            r.bottom / height,
          )
        : Rect.fromLTRB(
            r.left / width,
            r.top / height,
            r.right / width,
            r.bottom / height,
          );
    return FaceObservation(
      bounds: bounds,
      pitch: face.headEulerAngleX,
      yaw: face.headEulerAngleY,
      roll: face.headEulerAngleZ,
      trackingId: face.trackingId,
    );
  }).toList();
}
