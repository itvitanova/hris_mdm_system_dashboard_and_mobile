import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/attendance/presentation/widgets/attendance_modal_bottom_sheet.dart';

class MockAttendanceApi extends ApiClient {
  Map<String, dynamic> customWorkspace = {
    'actor': {
      'employeeId': 'EMP-001',
      'name': 'Budi Santoso',
    },
    'employee': {
      'id': 'EMP-001',
      'name': 'Budi Santoso',
      'faceEnrolled': true,
    },
    'employees': [
      {
        'id': 'EMP-001',
        'name': 'Budi Santoso',
        'faceEnrolled': true,
      },
    ],
    'settings': {
      'name': 'Kantor Pusat MDM',
      'latitude': -6.2088,
      'longitude': 106.8456,
      'radius': 100,
      'active': true,
      'allowAnyLocation': false,
      'workStart': '08:00',
      'workEnd': '17:00',
    },
    'attendance': <Map<String, dynamic>>[],
    'attendanceDate': '2026-10-29',
    'faceAvailable': false,
  };

  @override
  Future<Map<String, dynamic>> workspace() async => customWorkspace;
}

Widget createTestableWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(360, 800),
    minTextAdapt: true,
    splitScreenMode: true,
    builder: (context, _) => MaterialApp(
      home: Scaffold(
        body: child,
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AttendanceModalBottomSheet Tests', () {
    const locationChannel = MethodChannel('flutter.baseflow.com/geolocator');

    setUp(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(locationChannel, (call) async {
        if (call.method == 'isLocationServiceEnabled') return true;
        if (call.method == 'checkPermission') return 3; // whileInUse
        if (call.method == 'requestPermission') return 3;
        if (call.method == 'getCurrentPosition') {
          return {
            'latitude': -6.2088,
            'longitude': 106.8456,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'accuracy': 10.0,
            'altitude': 0.0,
            'heading': 0.0,
            'speed': 0.0,
            'speed_accuracy': 0.0,
            'is_mocked': false,
          };
        }
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(locationChannel, null);
    });

    testWidgets('renders Step 1 with GPS verification UI and manual refresh button', (tester) async {
      final api = MockAttendanceApi();
      final workspace = Workspace(await api.workspace());

      await tester.pumpWidget(
        createTestableWidget(
          AttendanceModalBottomSheet(
            api: api,
            workspace: workspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Verifikasi Lokasi & Waktu'), findsOneWidget);
      expect(find.text('Mengecek posisi Anda terhadap radius kantor'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      // Verify Office Tag
      expect(find.text('Kantor Pusat MDM'), findsOneWidget);

      // Verify Manual Refresh Button
      expect(find.text('Refresh Lokasi'), findsOneWidget);

      // Verify Proceed button (Lanjut ke Kamera or Absensi Masuk)
      expect(find.byType(FilledButton), findsWidgets);
    });

    testWidgets('shows warning when GPS location is outside office radius', (tester) async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(locationChannel, (call) async {
        if (call.method == 'isLocationServiceEnabled') return true;
        if (call.method == 'checkPermission') return 3;
        if (call.method == 'getCurrentPosition') {
          // Far away position (~10km)
          return {
            'latitude': -6.3000,
            'longitude': 106.9000,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'accuracy': 15.0,
            'altitude': 0.0,
            'heading': 0.0,
            'speed': 0.0,
            'speed_accuracy': 0.0,
            'is_mocked': false,
          };
        }
        return null;
      });

      final api = MockAttendanceApi();
      final workspace = Workspace(await api.workspace());

      await tester.pumpWidget(
        createTestableWidget(
          AttendanceModalBottomSheet(
            api: api,
            workspace: workspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Warning Card
      expect(find.text('Di Luar Radius Kantor'), findsOneWidget);

      // Verify Proceed Button is disabled
      final proceedBtn = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Absensi Masuk'),
      );
      expect(proceedBtn.onPressed, isNull);
    });

    testWidgets('navigates to Step 2 when within radius and proceed is clicked', (tester) async {
      final api = MockAttendanceApi();
      final workspace = Workspace(await api.workspace());

      await tester.pumpWidget(
        createTestableWidget(
          AttendanceModalBottomSheet(
            api: api,
            workspace: workspace,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // In safe location, proceed button is enabled with 'Lanjut ke Kamera'
      final proceedFinder = find.widgetWithText(FilledButton, 'Lanjut ke Kamera');
      expect(proceedFinder, findsOneWidget);

      await tester.ensureVisible(proceedFinder);
      await tester.pumpAndSettle();
      await tester.tap(proceedFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Step 2 Header
      expect(find.text('Ambil Absen Masuk'), findsWidgets);
      expect(find.text('Posisikan wajah Anda di dalam bingkai'), findsOneWidget);

      // Verified location badge in Step 2
      expect(find.textContaining('Terverifikasi di Kantor Pusat MDM'), findsOneWidget);

      // Guidance pill
      expect(
        find.text('Pastikan wajah terlihat jelas dan pencahayaan cukup'),
        findsOneWidget,
      );
    });
  });
}
