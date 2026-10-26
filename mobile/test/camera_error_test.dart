import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/features/attendance/camera_error.dart';

void main() {
  test('native ML Kit stack trace becomes an actionable short message', () {
    final message = cameraErrorMessage(
      PlatformException(
        code: 'InputImageConverterError',
        message:
            'java.lang.NullPointerException: getClass() on null\nat l2.ma.<init>',
        details: 'private native diagnostic',
      ),
    );
    expect(message, contains('Tutup pemindai'));
    expect(message, isNot(contains('NullPointerException')));
    expect(message, isNot(contains('private native diagnostic')));
  });
  test(
    'permission and API validation keep their useful recovery information',
    () {
      expect(
        cameraErrorMessage(
          CameraException('CameraAccessDenied', 'native detail'),
        ),
        contains('Aktifkan izin kamera'),
      );
      expect(
        cameraErrorMessage(ApiException('Lihat lurus ke kamera.')),
        'Lihat lurus ke kamera.',
      );
      expect(
        cameraErrorMessage(TimeoutException('native timeout')),
        contains('Periksa koneksi'),
      );
      expect(
        cameraErrorMessage(StateError('internal stack')),
        isNot(contains('internal stack')),
      );
    },
  );
}
