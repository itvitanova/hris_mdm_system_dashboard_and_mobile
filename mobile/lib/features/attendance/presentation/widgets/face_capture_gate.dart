import 'dart:ui';

/// Framing/steadiness only. Never treats detection or tracking as identity proof.
class FaceObservation {
  const FaceObservation({
    required this.bounds,
    required this.pitch,
    required this.yaw,
    required this.roll,
    this.trackingId,
  });
  final Rect bounds; // upright, normalized to the entire uncropped preview
  final double? pitch, yaw, roll;
  final int? trackingId;
}

const faceGuide = Rect.fromLTRB(.14, .16, .86, .84);

String? framingError(List<FaceObservation> faces) {
  if (faces.isEmpty) return 'Arahkan wajah ke dalam kotak';
  if (faces.length != 1) return 'Pastikan hanya satu wajah di dalam kamera';
  final f = faces.single;
  final r = f.bounds;
  if (![r.left, r.top, r.right, r.bottom].every((v) => v.isFinite)) {
    return 'Wajah belum terlihat jelas';
  }
  if (r.width < .28 || r.height < .28) return 'Dekatkan wajah ke kamera';
  if (r.width > .70 || r.height > .66) return 'Jauhkan wajah sedikit';
  if (!faceGuide.contains(r.topLeft) ||
      !faceGuide.contains(r.bottomRight) ||
      (r.center.dx - .5).abs() > .09 ||
      (r.center.dy - .5).abs() > .10) {
    return 'Posisikan wajah di tengah kotak';
  }
  if ([f.pitch, f.yaw, f.roll].any((v) => v == null || !v.isFinite) ||
      f.pitch!.abs() > 18 ||
      f.yaw!.abs() > 18 ||
      f.roll!.abs() > 15) {
    return 'Lihat lurus ke kamera';
  }
  return null;
}

class FaceCaptureGate {
  DateTime? _since, _lastFrame;
  FaceObservation? _last;
  int _frames = 0;
  bool _fired = false;
  double progress = 0;
  String hint = 'Arahkan wajah ke dalam kotak';
  void reset() {
    _since = null;
    _lastFrame = null;
    _last = null;
    _frames = 0;
    _fired = false;
    progress = 0;
  }

  /// Fires once per uninterrupted stable face. Invalid frames reset the hold.
  bool observe(List<FaceObservation> faces, DateTime now) {
    final issue = framingError(faces);
    if (issue != null) {
      reset();
      hint = issue;
      return false;
    }
    final face = faces.single;
    final changed =
        _last != null &&
        (face.trackingId != _last!.trackingId ||
            (face.bounds.center - _last!.bounds.center).distance > .045 ||
            (face.bounds.width - _last!.bounds.width).abs() > .06 ||
            now.difference(_lastFrame!) > const Duration(milliseconds: 650));
    if (changed) reset();
    _since ??= now;
    _last = face;
    _lastFrame = now;
    _frames++;
    progress = (now.difference(_since!).inMilliseconds / 1200)
        .clamp(0, 1)
        .toDouble();
    hint = 'Posisi sudah pas. Tahan sebentar…';
    if (!_fired && progress >= 1 && _frames >= 4) {
      _fired = true;
      return true;
    }
    return false;
  }
}
