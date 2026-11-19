import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../widgets/camera_input.dart';
import 'camera_error_page.dart';
import '../widgets/face/auto_face_body.dart';
import '../widgets/face/auto_face_camera_initializer.dart';
import '../widgets/face/auto_face_capture_service.dart';
import '../widgets/face_capture_gate.dart';

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

class _AutoFaceScreenState extends State<AutoFaceScreen> with WidgetsBindingObserver {
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
  bool _closed = false, _suspended = false, _processing = false, _capturing = false;
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
    _cameraOperations = _cameraOperations.then((_) async {
      final old = _camera;
      _camera = null;
      await old?.dispose();
      if (_closed || _suspended || epoch != _epoch) return;

      final camera = await AutoFaceCameraInitializer.initFrontCamera();
      _camera = camera;
      if (_closed || _suspended || epoch != _epoch) {
        await camera.dispose();
        if (identical(_camera, camera)) _camera = null;
        return;
      }
      await camera.startImageStream(
        (image) => unawaited(_process(image, camera, epoch)),
      );
      if (mounted && epoch == _epoch) setState(() {});
    }).catchError((Object e) {
      if (!_closed && epoch == _epoch) _reportError(e);
    });
    return _cameraOperations;
  }

  Future<void> _releaseCamera() {
    _epoch++;
    _cameraOperations = _cameraOperations.then((_) async {
      final camera = _camera;
      _camera = null;
      await camera?.dispose();
    }).catchError((Object _) {});
    return _cameraOperations;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
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
    unawaited(_releaseCamera().then((_) async {
      try {
        await _detection;
      } catch (_) {}
      await _detector.close();
    }));
    super.dispose();
  }

  void _reportError(Object error) {
    if (!mounted || _closed) return;
    setState(() {
      _error = cameraErrorMessage(error);
      _capturing = false;
    });
    unawaited(_releaseCamera());
  }

  Future<void> _process(CameraImage image, CameraController camera, int epoch) async {
    final now = DateTime.now();
    if (_closed || _suspended || _processing || _capturing || _error != null || epoch != _epoch ||
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
      final ready = _gate.observe(observations(faces, input, mirrored: true), DateTime.now());
      setState(() => _hint = _gate.hint);
      if (ready) await _captureAndSubmit(camera, epoch);
    } catch (e) {
      if (!_closed && epoch == _epoch) _reportError(e);
    } finally {
      _detection = null;
      _processing = false;
    }
  }

  Future<void> _captureAndSubmit(CameraController camera, int epoch) async {
    _capturing = true;
    setState(() => _hint = widget.enrollment ? 'Mendaftarkan referensi wajah…' : 'Memverifikasi wajah dan lokasi…');
    try {
      await AutoFaceCaptureService.captureAndSubmit(
        context: context,
        camera: camera,
        detector: _detector,
        enrollment: widget.enrollment,
        onCapture: widget.onCapture,
        isAborted: () => _closed || _suspended || epoch != _epoch,
      );
    } catch (e) {
      if (!_closed) _reportError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      body: AutoFaceBody(
        enrollment: widget.enrollment,
        camera: _camera,
        capturing: _capturing,
        aligned: _gate.progress > 0,
        error: _error,
        hint: _hint,
        progress: _gate.progress,
        onRetry: () {
          _capturing = false;
          unawaited(_openCamera());
        },
      ),
    );
  }
}

typedef AutoFacePage = AutoFaceScreen;
