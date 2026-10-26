// Release-only native regression probe. No camera, employee photo, API request,
// enrollment, or attendance write is performed. Never publish this test APK.
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final detector = FaceDetector(
    options: FaceDetectorOptions(enableTracking: true),
  );
  File? file;
  String result;
  try {
    const width = 640, height = 480;
    final bytes = Uint8List(width * height * 3 ~/ 2);
    bytes.fillRange(0, width * height, 16);
    bytes.fillRange(width * height, bytes.length, 128);
    final faces = await detector.processImage(
      InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: const Size(640, 480),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: width,
        ),
      ),
    );
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.black, BlendMode.src);
    final picture = recorder.endRecording();
    final image = await picture.toImage(width, height);
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    file = File('${Directory.systemTemp.path}/mdm-mlkit-release-probe.png');
    await file.writeAsBytes(png!.buffer.asUint8List());
    image.dispose();
    picture.dispose();
    final stillFaces = await detector.processImage(
      InputImage.fromFilePath(file.path),
    );
    // This probe checks native conversion/initialization, not face accuracy.
    // Report detections rather than treating a model false positive as a crash.
    result =
        'MDM_MLKIT_SMOKE PASS: NV21 and still image processed; '
        'detections=${faces.length}/${stillFaces.length}.';
  } catch (error) {
    result = 'MDM_MLKIT_SMOKE FAIL: $error';
  } finally {
    await file?.delete();
    await detector.close();
  }
  // Retained in release so adb logcat can report the real native outcome.
  // ignore: avoid_print
  print(result);
  runApp(
    MaterialApp(
      home: Scaffold(body: SafeArea(child: Text(result))),
    ),
  );
}
