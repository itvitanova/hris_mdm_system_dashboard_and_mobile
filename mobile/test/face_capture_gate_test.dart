import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/features/attendance/face_capture_gate.dart';

void main() {
  const face = FaceObservation(
    bounds: Rect.fromLTRB(.28, .28, .72, .72),
    pitch: 0,
    yaw: 0,
    roll: 0,
    trackingId: 1,
  );
  final now = DateTime(2026, 10, 22);
  test('no face and multiple faces cannot trigger capture', () {
    final gate = FaceCaptureGate();
    expect(gate.observe([], now), isFalse);
    expect(gate.observe([face, face], now), isFalse);
    expect(gate.progress, 0);
  });
  test('requires centered, frontal, correctly sized face', () {
    expect(
      framingError([
        const FaceObservation(
          bounds: Rect.fromLTRB(.43, .43, .57, .57),
          pitch: 0,
          yaw: 0,
          roll: 0,
        ),
      ]),
      contains('Dekatkan'),
    );
    expect(
      framingError([
        const FaceObservation(
          bounds: Rect.fromLTRB(.05, .05, .95, .95),
          pitch: 0,
          yaw: 0,
          roll: 0,
        ),
      ]),
      contains('Jauhkan'),
    );
    expect(
      framingError([
        const FaceObservation(
          bounds: Rect.fromLTRB(.1, .28, .54, .72),
          pitch: 0,
          yaw: 0,
          roll: 0,
        ),
      ]),
      contains('tengah'),
    );
    expect(
      framingError([
        const FaceObservation(
          bounds: Rect.fromLTRB(.28, .28, .72, .72),
          pitch: 0,
          yaw: 30,
          roll: 0,
        ),
      ]),
      contains('lurus'),
    );
    expect(
      framingError([
        const FaceObservation(
          bounds: Rect.fromLTRB(.28, .28, .72, .72),
          pitch: null,
          yaw: 0,
          roll: 0,
        ),
      ]),
      isNotNull,
    );
  });
  test('fires once after 1.2 seconds of consecutive stable frames', () {
    final gate = FaceCaptureGate();
    for (var i = 0; i < 5; i++) {
      expect(
        gate.observe([face], now.add(Duration(milliseconds: i * 250))),
        isFalse,
      );
    }
    expect(
      gate.observe([face], now.add(const Duration(milliseconds: 1250))),
      isTrue,
    );
    expect(
      gate.observe([face], now.add(const Duration(milliseconds: 1500))),
      isFalse,
    );
    expect(gate.progress, 1);
  });
  test(
    'lost detection, tracking change, or camera interruption resets the hold',
    () {
      final gate = FaceCaptureGate();
      gate.observe([face], now);
      gate.observe([face], now.add(const Duration(milliseconds: 500)));
      gate.observe([], now.add(const Duration(milliseconds: 600)));
      expect(gate.progress, 0);
      gate.observe([face], now.add(const Duration(milliseconds: 700)));
      const replacement = FaceObservation(
        bounds: Rect.fromLTRB(.28, .28, .72, .72),
        pitch: 0,
        yaw: 0,
        roll: 0,
        trackingId: 2,
      );
      expect(
        gate.observe([
          replacement,
        ], now.add(const Duration(milliseconds: 1100))),
        isFalse,
      );
      expect(gate.progress, 0);
      gate.observe([replacement], now.add(const Duration(milliseconds: 1500)));
      gate.observe([replacement], now.add(const Duration(milliseconds: 2300)));
      expect(gate.progress, 0);
    },
  );
  test(
    'large movement resets the hold even when the face remains inside guide',
    () {
      final gate = FaceCaptureGate();
      gate.observe([face], now);
      gate.observe([face], now.add(const Duration(milliseconds: 400)));
      const moved = FaceObservation(
        bounds: Rect.fromLTRB(.34, .28, .78, .72),
        pitch: 0,
        yaw: 0,
        roll: 0,
        trackingId: 1,
      );
      expect(
        gate.observe([moved], now.add(const Duration(milliseconds: 600))),
        isFalse,
      );
      expect(gate.progress, 0);
    },
  );
}
