import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:camera/camera.dart';
import '../../core/api_client.dart';
import '../../core/workspace.dart';

bool _validPositionNumbers(Position p) =>
    p.latitude.isFinite &&
    p.longitude.isFinite &&
    p.latitude >= -90 &&
    p.latitude <= 90 &&
    p.longitude >= -180 &&
    p.longitude <= 180 &&
    p.accuracy.isFinite &&
    p.accuracy > 0;

bool _freshPosition(Position p, DateTime now) {
  final age = now.difference(p.timestamp);
  return age <= const Duration(seconds: 30) &&
      age >= const Duration(seconds: -5);
}

String? positionError(Position p, {DateTime? now}) {
  if (p.isMocked) {
    return 'Lokasi tiruan terdeteksi. Matikan fake GPS dan ambil lokasi kembali.';
  }
  if (!_validPositionNumbers(p) || p.accuracy > 50) {
    return 'Akurasi GPS harus 50 meter atau lebih baik. Coba di area terbuka.';
  }
  if (!_freshPosition(p, now ?? DateTime.now())) {
    return 'Lokasi sudah kedaluwarsa. Ambil lokasi kembali.';
  }
  return null;
}

/// Client checks complement backend validation; they are not device attestation.
String? locationError(Position p, Json settings, {DateTime? now}) {
  final problem = positionError(p, now: now);
  if (problem != null) return problem;
  if (settings['active'] == false) {
    return 'Lokasi penugasan nonaktif. Hubungi admin.';
  }
  if (settings['latitude'] is! num ||
      settings['longitude'] is! num ||
      !number(settings, 'latitude').isFinite ||
      number(settings, 'latitude').abs() > 90 ||
      !number(settings, 'longitude').isFinite ||
      number(settings, 'longitude').abs() > 180 ||
      !number(settings, 'radius').isFinite ||
      number(settings, 'radius') < 10 ||
      number(settings, 'radius') > 10000) {
    return 'Lokasi kantor belum valid. Hubungi admin.';
  }
  if (settings['allowAnyLocation'] == true) return null;
  final distance = Geolocator.distanceBetween(
    p.latitude,
    p.longitude,
    number(settings, 'latitude'),
    number(settings, 'longitude'),
  );
  if (distance + p.accuracy > number(settings, 'radius')) {
    return 'Di luar area aman kantor: ${distance.round()} m ± ${p.accuracy.round()} m. Batas ${number(settings, 'radius').round()} m.';
  }
  return null;
}

/// Keep the GPS receiver active after a coarse initial fix. A fixed deadline
/// bounds the request even if the device keeps sending inaccurate positions.
Future<Position> refinePosition(
  Position first,
  Stream<Position> Function() updates, {
  Duration timeLimit = const Duration(seconds: 25),
  void Function(Position)? onSample,
}) async {
  final result = Completer<Position>();
  Position? latest;
  String? problem;
  void observe(Position p) {
    if (result.isCompleted) return;
    problem = positionError(p);
    if (p.isMocked) {
      result.completeError(ApiException(problem!));
      return;
    }
    if (_validPositionNumbers(p) && _freshPosition(p, DateTime.now())) {
      latest = p;
      onSample?.call(p);
      if (problem == null) result.complete(p);
    }
  }

  void finish() {
    if (result.isCompleted) return;
    if (latest != null) {
      result.complete(latest!);
    } else {
      result.completeError(
        ApiException(
          problem ??
              'GPS belum mendapatkan lokasi. Coba di dekat jendela atau area terbuka.',
        ),
      );
    }
  }

  observe(first);
  if (result.isCompleted) return result.future;
  if (timeLimit <= Duration.zero) {
    finish();
    return result.future;
  }
  final timer = Timer(timeLimit, finish);
  StreamSubscription<Position>? subscription;
  try {
    subscription = updates().listen(
      observe,
      onDone: finish,
      onError: (Object error, StackTrace stack) {
        if (!result.isCompleted) result.completeError(error, stack);
      },
    );
    return await result.future;
  } finally {
    timer.cancel();
    await subscription?.cancel();
  }
}

class AttendanceService {
  AttendanceService(this.api);
  final ApiClient api;
  Future<String> encodePhoto(XFile photo) async {
    final bytes = await photo.readAsBytes();
    if (bytes.length > 3 * 1024 * 1024) {
      throw ApiException('Foto terlalu besar. Ambil ulang foto.');
    }
    final mime = bytes.length >= 3 && bytes[0] == 0xff && bytes[1] == 0xd8
        ? 'image/jpeg'
        : 'image/png';
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  Future<void> enroll(String employeeId, XFile photo) async {
    await api.post('/employees/${Uri.encodeComponent(employeeId)}/face', {
      'photo': await encodePhoto(photo),
    });
  }

  Future<Position> locate({void Function(Position)? onSample}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw ApiException('Aktifkan layanan lokasi/GPS terlebih dahulu.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw ApiException(
        'Izin lokasi diblokir. Aktifkan melalui pengaturan aplikasi.',
      );
    }
    if (permission == LocationPermission.denied) {
      throw ApiException('Izin lokasi diperlukan untuk absensi.');
    }
    const limit = Duration(seconds: 25);
    final started = DateTime.now();
    final first = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        timeLimit: limit,
      ),
    );
    return refinePosition(
      first,
      () => Geolocator.getPositionStream(
        locationSettings: defaultTargetPlatform == TargetPlatform.android
            ? AndroidSettings(
                accuracy: LocationAccuracy.best,
                intervalDuration: const Duration(seconds: 2),
                distanceFilter: 0,
                maxUpdateAge: Duration.zero,
              )
            : const LocationSettings(
                accuracy: LocationAccuracy.best,
                distanceFilter: 0,
              ),
      ),
      timeLimit: limit - DateTime.now().difference(started),
      onSample: onSample,
    );
  }

  Future<void> punch(
    String type,
    XFile photo, {
    String earlyReason = '',
  }) async {
    // Never validate against an office snapshot from before an admin update.
    final settings = Workspace(await api.workspace()).attendancePolicy;
    // Re-fetch after taking the picture, never reuse the preview location.
    final position = await locate();
    final error = locationError(position, settings);
    if (error != null) throw ApiException(error);
    await api.post('/attendance/punch', {
      'type': type,
      'earlyReason': earlyReason,
      'latitude': position.latitude,
      'longitude': position.longitude,
      'accuracy': position.accuracy,
      'photo': await encodePhoto(photo),
    });
  }
}
