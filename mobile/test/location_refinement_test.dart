import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/features/attendance/attendance_service.dart';

Position fix(double accuracy, {bool mocked = false, DateTime? timestamp}) =>
    Position(
      latitude: -6.137643,
      longitude: 106.799746,
      timestamp: timestamp ?? DateTime.now(),
      accuracy: accuracy,
      altitude: 0,
      altitudeAccuracy: 0,
      heading: 0,
      headingAccuracy: 0,
      speed: 0,
      speedAccuracy: 0,
      isMocked: mocked,
    );

void main() {
  test(
    'coarse initial GPS stays active until a precise fix arrives, then cancels',
    () async {
      var cancelled = false;
      final stream = StreamController<Position>(
        onCancel: () {
          cancelled = true;
        },
      );
      final seen = <double>[];
      final pending = refinePosition(
        fix(66),
        () => stream.stream,
        onSample: (p) => seen.add(p.accuracy),
      );
      stream.add(fix(80));
      stream.add(fix(8));
      expect((await pending).accuracy, 8);
      expect(seen, [66, 80, 8]);
      expect(cancelled, isTrue);
      await stream.close();
    },
  );

  test('already precise initial fix never starts a stream', () async {
    var started = false;
    final result = await refinePosition(fix(10), () {
      started = true;
      return const Stream.empty();
    });
    expect(result.accuracy, 10);
    expect(started, isFalse);
  });

  test(
    'frequent inaccurate updates cannot extend the overall deadline',
    () async {
      var cancelled = false;
      final stream = StreamController<Position>(
        onCancel: () {
          cancelled = true;
        },
      );
      final periodic = Timer.periodic(
        const Duration(milliseconds: 5),
        (_) => stream.add(fix(66)),
      );
      try {
        final result = await refinePosition(
          fix(66),
          () => stream.stream,
          timeLimit: const Duration(milliseconds: 30),
        ).timeout(const Duration(seconds: 1));
        expect(positionError(result), contains('50 meter'));
        expect(cancelled, isTrue);
      } finally {
        periodic.cancel();
        await stream.close();
      }
    },
  );

  test(
    'mock GPS rejects immediately and cancels even if a later fix is precise',
    () async {
      var cancelled = false;
      final stream = StreamController<Position>(
        onCancel: () {
          cancelled = true;
        },
      );
      final pending = refinePosition(fix(66), () => stream.stream);
      final check = expectLater(
        pending,
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            contains('tiruan'),
          ),
        ),
      );
      stream.add(fix(5, mocked: true));
      stream.add(fix(5));
      await check;
      expect(cancelled, isTrue);
      await stream.close();
    },
  );

  test(
    'stale and malformed accurate fixes do not pass or reach the UI callback',
    () async {
      final seen = <double>[];
      final result = await refinePosition(
        fix(66),
        () => Stream.fromIterable([
          fix(
            3,
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
          fix(double.nan),
          fix(12),
        ]),
        onSample: (p) => seen.add(p.accuracy),
      );
      expect(result.accuracy, 12);
      expect(seen, [66, 12]);
    },
  );

  test(
    'missing usable fixes reject at the deadline and cancel the stream',
    () async {
      var cancelled = false;
      final stream = StreamController<Position>(
        onCancel: () {
          cancelled = true;
        },
      );
      await expectLater(
        refinePosition(
          fix(
            5,
            timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
          () => stream.stream,
          timeLimit: const Duration(milliseconds: 10),
        ),
        throwsA(isA<ApiException>()),
      );
      expect(cancelled, isTrue);
      await stream.close();
    },
  );
}
