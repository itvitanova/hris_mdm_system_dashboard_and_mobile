import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mdm_hris/features/attendance/attendance_service.dart';

void main() {
  final now = DateTime(2026, 10, 22, 9);
  final office = <String, dynamic>{
    'latitude': -6.2088,
    'longitude': 106.8456,
    'radius': 100,
  };
  Position position({
    bool mocked = false,
    double accuracy = 10,
    double offset = 0,
    DateTime? timestamp,
  }) => Position(
    longitude: 106.8456,
    latitude: -6.2088 + offset,
    timestamp: timestamp ?? now,
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
    isMocked: mocked,
  );
  test('rejects mocked fixes even inside office', () {
    expect(
      locationError(position(mocked: true), office, now: now),
      contains('tiruan'),
    );
  });
  test('accepts a fresh precise office location', () {
    expect(locationError(position(), office, now: now), isNull);
  });
  test('rejects poor accuracy and nonfinite values', () {
    expect(locationError(position(accuracy: 51), office, now: now), isNotNull);
    expect(
      locationError(position(accuracy: double.nan), office, now: now),
      isNotNull,
    );
  });
  test('uses distance plus accuracy, not distance alone', () {
    expect(
      locationError(position(offset: .00075, accuracy: 10), office, now: now),
      isNull,
    );
    expect(
      locationError(position(offset: .00075, accuracy: 20), office, now: now),
      contains('Di luar'),
    );
  });
  test('rejects stale and future fixes', () {
    expect(
      locationError(
        position(timestamp: now.subtract(const Duration(seconds: 31))),
        office,
        now: now,
      ),
      contains('kedaluwarsa'),
    );
    expect(
      locationError(
        position(timestamp: now.add(const Duration(seconds: 10))),
        office,
        now: now,
      ),
      isNotNull,
    );
  });
  test('uses assigned radius and never grants another site implicitly', () {
    expect(locationError(position(offset: .001), office, now: now), isNotNull);
    expect(
      locationError(position(offset: .001), {
        ...office,
        'radius': 200,
      }, now: now),
      isNull,
    );
  });
  test('anywhere exemption still requires fresh accurate genuine GPS', () {
    final policy = {...office, 'allowAnyLocation': true, 'active': true};
    expect(locationError(position(offset: 2), policy, now: now), isNull);
    expect(
      locationError(position(offset: 2, mocked: true), policy, now: now),
      isNotNull,
    );
    expect(locationError(position(accuracy: 66), policy, now: now), isNotNull);
    expect(
      locationError(
        position(timestamp: now.subtract(const Duration(minutes: 2))),
        policy,
        now: now,
      ),
      isNotNull,
    );
    expect(
      locationError(position(), {...policy, 'active': false}, now: now),
      isNotNull,
    );
  });
}
