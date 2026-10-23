import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/attendance/attendance_screen.dart';
import 'package:mdm_hris/features/attendance/attendance_service.dart';

class SettingsApi extends ApiClient {
  double latitude = -6.137643;
  int reads = 0, writes = 0;
  String attendanceDate = '2026-10-23';
  List<Map<String, dynamic>> attendance = [];
  Map<String, dynamic>? policy;
  Map<String, dynamic> snapshot() => {
    if (policy != null) 'attendancePolicy': policy,
    'attendanceDate': attendanceDate,
    'attendance': attendance,
    'actor': {'employeeId': 'EMP-002'},
    'employees': [
      {'id': 'EMP-002', 'faceEnrolled': true},
    ],
    'faceAvailable': true,
    'settings': {
      'locationName': 'Kantor terbaru',
      'latitude': latitude,
      'longitude': 106.799746,
      'radius': 100,
    },
  };
  @override
  Future<Map<String, dynamic>> workspace() async {
    reads++;
    return snapshot();
  }

  @override
  Future<void> post(String path, Map<String, dynamic> body) async {
    writes++;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('flutter.baseflow.com/geolocator');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'isLocationServiceEnabled') return true;
          if (call.method == 'checkPermission') {
            return LocationPermission.whileInUse.index;
          }
          if (call.method == 'getCurrentPosition') {
            return Position(
              longitude: 106.799651,
              latitude: -6.137651,
              timestamp: DateTime.now(),
              accuracy: 6,
              altitude: 0,
              altitudeAccuracy: 0,
              heading: 0,
              headingAccuracy: 0,
              speed: 0,
              speedAccuracy: 0,
            ).toJson();
          }
          return null;
        });
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null),
  );

  testWidgets(
    'uses the new office immediately and refreshes an open attendance screen',
    (tester) async {
      final api = SettingsApi();
      final old = api.snapshot();
      old['settings'] = {
        'locationName': 'Kantor lama',
        'latitude': -6.2088,
        'longitude': 106.8456,
        'radius': 100,
      };
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpWidget(
        MaterialApp(
          home: AttendanceScreen(api: api, workspace: Workspace(old)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Kantor terbaru'), findsOneWidget);
      expect(find.text('Anda berada di area kantor.'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Absensi Masuk'),
            )
            .onPressed,
        isNotNull,
      );
      api.latitude = -6.0;
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle();
      expect(api.reads, greaterThanOrEqualTo(2));
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Absensi Masuk'),
            )
            .onPressed,
        isNull,
      );
      expect(find.textContaining('Di luar area aman kantor'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'a saved check-in changes the only action to check-out, then disables completion',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final api = SettingsApi();
      await tester.pumpWidget(
        MaterialApp(
          home: AttendanceScreen(
            api: api,
            workspace: Workspace(api.snapshot()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, 'Absensi Masuk'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FilledButton, 'Absensi Keluar'), findsNothing);
      api.attendance = [
        {
          'employeeId': 'EMP-002',
          'date': '2026-10-23',
          'checkIn': '2026-10-23T09:00:00+07:00',
          'checkOut': '',
        },
      ];
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FilledButton, 'Absensi Masuk'), findsNothing);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Absensi Keluar'),
            )
            .onPressed,
        isNotNull,
      );
      api.attendance = [
        {...api.attendance.first, 'checkOut': '2026-10-23T17:00:00+07:00'},
      ];
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Absensi Selesai'),
            )
            .onPressed,
        isNull,
      );
      expect(find.widgetWithText(FilledButton, 'Absensi Keluar'), findsNothing);
      api.attendanceDate = '2026-10-24';
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, 'Absensi Masuk'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'submission fetches current office and rejects a moved office before uploading',
    () async {
      final api = SettingsApi()..latitude = -6.0;
      await expectLater(
        AttendanceService(api).punch('in', XFile('unused.jpg')),
        throwsA(isA<ApiException>()),
      );
      expect(api.reads, 1);
      expect(api.writes, 0);
    },
  );
  testWidgets(
    'assigned site overrides HQ and admin anywhere changes refresh automatically',
    (tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      final api = SettingsApi()..latitude = -6.0;
      api.policy = {
        'name': 'Service Point Jakarta Utara',
        'latitude': -6.137643,
        'longitude': 106.799746,
        'radius': 150,
        'active': true,
        'allowAnyLocation': false,
      };
      await tester.pumpWidget(
        MaterialApp(
          home: AttendanceScreen(
            api: api,
            workspace: Workspace(api.snapshot()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Service Point Jakarta Utara'), findsOneWidget);
      FilledButton action() => tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Absensi Masuk'),
      );
      expect(action().onPressed, isNotNull);
      api.policy = {...api.policy!, 'latitude': -2.0};
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle();
      expect(action().onPressed, isNull);
      api.policy = {...api.policy!, 'allowAnyLocation': true};
      await tester.pump(const Duration(seconds: 15));
      await tester.pumpAndSettle();
      expect(action().onPressed, isNotNull);
      expect(find.textContaining('GPS siap. Izin absensi'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
