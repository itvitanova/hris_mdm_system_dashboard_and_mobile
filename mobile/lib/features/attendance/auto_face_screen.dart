import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../core/api_client.dart';
import '../../shared/widgets.dart';
import 'camera_input.dart';
import 'camera_error.dart';
import 'face_capture_gate.dart';

class AutoFaceScreen extends StatefulWidget {
  const AutoFaceScreen({
    super.key,
    required this.title,
    required this.onCapture,
    this.enrollment = false,
  });
  final String title;
  final bool enrollment;
  final Future<void> Function(XFile) onCapture;
  @override
  State<AutoFaceScreen> createState() => _AutoFaceScreenState();
}

class _AutoFaceScreenState extends State<AutoFaceScreen>
    with WidgetsBindingObserver {
  final _gate = FaceCaptureGate();
  final _detector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableTracking: true,
      enableLandmarks: true,
      minFaceSize: .15,
    ),
  );
  CameraController? _camera;
  Future<void> _cameraOperations = Future.value();
  Future<List<Face>>? _detection;
  bool _closed = false,
      _suspended = false,
      _processing = false,
      _capturing = false;
  int _epoch = 0;
  DateTime _lastFrame = DateTime.fromMillisecondsSinceEpoch(0);
  String? _error;
  String _hint = 'Arahkan wajah ke dalam kotak';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_openCamera());
  }

  Future<void> _openCamera() {
    final epoch = ++_epoch;
    _gate.reset();
    if (mounted) {
      setState(() {
        _error = null;
        _hint = 'Arahkan wajah ke dalam kotak';
      });
    }
    _cameraOperations = _cameraOperations
        .then((_) async {
          final old = _camera;
          _camera = null;
          await old?.dispose();
          if (_closed || _suspended || epoch != _epoch) return;
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
          _camera = camera;
          await camera.initialize();
          if (_closed || _suspended || epoch != _epoch) {
            await camera.dispose();
            if (identical(_camera, camera)) _camera = null;
            return;
          }
          await camera.lockCaptureOrientation(DeviceOrientation.portraitUp);
          await camera.setFlashMode(FlashMode.off);
          await camera.startImageStream(
            (image) => unawaited(_process(image, camera, epoch)),
          );
          if (mounted && epoch == _epoch) setState(() {});
        })
        .catchError((Object e) {
          if (!_closed && epoch == _epoch) _reportError(e);
        });
    return _cameraOperations;
  }

  Future<void> _releaseCamera() {
    _epoch++;
    _cameraOperations = _cameraOperations
        .then((_) async {
          final camera = _camera;
          _camera = null;
          await camera?.dispose();
        })
        .catchError((Object _) {
          /* Camera may already be released by the OS. */
        });
    return _cameraOperations;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _suspended = true;
      _gate.reset();
      unawaited(_releaseCamera());
    } else if (state == AppLifecycleState.resumed) {
      _suspended = false;
      if (!_capturing && _error == null) unawaited(_openCamera());
    }
  }

  @override
  void dispose() {
    _closed = true;
    WidgetsBinding.instance.removeObserver(this);
    unawaited(
      _releaseCamera().then((_) async {
        try {
          await _detection;
        } catch (_) {}
        await _detector.close();
      }),
    );
    super.dispose();
  }

  void _reportError(Object error) {
    if (!mounted || _closed) return;
    final message = cameraErrorMessage(error);
    setState(() {
      _error = message;
      _capturing = false;
    });
    unawaited(_releaseCamera());
  }

  Future<void> _process(
    CameraImage image,
    CameraController camera,
    int epoch,
  ) async {
    final now = DateTime.now();
    if (_closed ||
        _suspended ||
        _processing ||
        _capturing ||
        _error != null ||
        epoch != _epoch ||
        now.difference(_lastFrame).inMilliseconds < 200) {
      return;
    }
    _processing = true;
    _lastFrame = now;
    try {
      final input = cameraInput(image, camera);
      final pending = _detector.processImage(input);
      _detection = pending;
      final faces = await pending;
      if (_closed || !mounted || _suspended || epoch != _epoch) return;
      final ready = _gate.observe(
        observations(faces, input, mirrored: true),
        DateTime.now(),
      );
      setState(() {
        _hint = _gate.hint;
      });
      if (ready) {
        await _captureAndSubmit(camera, epoch);
      }
    } catch (e) {
      if (!_closed && epoch == _epoch) _reportError(e);
    } finally {
      _detection = null;
      _processing = false;
    }
  }

  Future<void> _captureAndSubmit(CameraController camera, int epoch) async {
    // Single-flight latch is set before the first await; no automatic retries.
    _capturing = true;
    setState(
      () => _hint = widget.enrollment
          ? 'Mendaftarkan referensi wajah…'
          : 'Memverifikasi wajah dan lokasi…',
    );
    XFile? candidate;
    try {
      await camera.stopImageStream();
      candidate = await camera.takePicture();
      if (_closed || !mounted) return;
      if (_suspended || epoch != _epoch) {
        throw ApiException('Pemindaian terhenti. Silakan pindai ulang.');
      }
      // Recheck the actual still; never send an empty frame or multiple faces.
      _detection = _detector.processImage(
        InputImage.fromFilePath(candidate.path),
      );
      final stillFaces = await _detection!;
      if (stillFaces.length != 1) {
        throw ApiException(
          'Wajah berubah saat pemindaian. Silakan pindai ulang.',
        );
      }
      final face = stillFaces.single;
      if ([
        face.headEulerAngleX,
        face.headEulerAngleY,
        face.headEulerAngleZ,
      ].any((v) => v == null || !v.isFinite || v.abs() > 20)) {
        throw ApiException('Lihat lurus ke kamera, lalu pindai ulang.');
      }
      if (_closed || !mounted) return;
      if (_suspended || epoch != _epoch) {
        throw ApiException('Pemindaian terhenti. Silakan pindai ulang.');
      }
      // Backend atomically checks radius, identity AND liveness before writing.
      await widget.onCapture(candidate);
      if (mounted && !_closed) {
        notify(
          context,
          widget.enrollment
              ? 'Wajah berhasil didaftarkan. Anda dapat melakukan absensi.'
              : 'Wajah terverifikasi. Absensi berhasil dicatat.',
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!_closed) _reportError(e);
    } finally {
      if (candidate != null) {
        try {
          await File(candidate.path).delete();
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final camera = _camera;
    final initialized = camera != null && camera.value.isInitialized;
    final aligned = _gate.progress > 0;
    final color = _capturing
        ? brand
        : aligned
        ? Colors.teal
        : Colors.white;
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              widget.enrollment
                  ? 'Daftarkan wajah Anda'
                  : 'Cukup arahkan wajah Anda',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              widget.enrollment
                  ? 'Foto ini disimpan sebagai referensi untuk mencocokkan wajah saat absensi. Posisikan satu wajah dan tahan sebentar.'
                  : 'Posisikan satu wajah di tengah kotak dan tahan sebentar. Pemindaian berjalan otomatis.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFCBD5E1)),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: initialized ? 1 / camera.value.aspectRatio : 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (initialized)
                      CameraPreview(camera)
                    else
                      const ColoredBox(color: Color(0xFF1E293B)),
                    if (!initialized && _error == null)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    IgnorePointer(
                      child: CustomPaint(painter: _GuidePainter(color)),
                    ),
                    if (_capturing)
                      const ColoredBox(
                        color: Color(0x770F172A),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_error == null) ...[
              Text(
                _hint,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: _capturing ? null : _gate.progress,
                color: Colors.tealAccent,
                backgroundColor: Colors.white12,
                borderRadius: BorderRadius.circular(8),
                minHeight: 5,
              ),
            ],
            if (_error != null) ...[
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFFCA5A5)),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  _capturing = false;
                  unawaited(_openCamera());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Pindai ulang'),
              ),
              TextButton(
                onPressed: Geolocator.openAppSettings,
                child: const Text('Buka pengaturan aplikasi'),
              ),
            ],
            const SizedBox(height: 20),
            const Text(
              'Posisi wajah yang sesuai belum berarti identitas terverifikasi. Kamera tidak merekam video atau audio.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidePainter extends CustomPainter {
  _GuidePainter(this.color);
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
  bool shouldRepaint(_GuidePainter oldDelegate) => color != oldDelegate.color;
}
