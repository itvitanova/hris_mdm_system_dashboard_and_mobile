import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/features/attendance/auto_face_screen.dart';
import 'package:mdm_hris/shared/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const detector = MethodChannel('google_mlkit_face_detector');
  const camera = MethodChannel('plugins.flutter.io/camera');
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(detector, (_) async => null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(camera, (_) async => <Object>[]);
  });
  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(detector, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(camera, null);
  });
  testWidgets(
    'camera failure stays readable with retry at 360dp and large text',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          theme: hrisTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(3.2)),
            child: child!,
          ),
          home: AutoFaceScreen(
            title: 'Pendaftaran wajah',
            enrollment: true,
            onCapture: (_) async =>
                fail('Camera initialization failure must not submit a photo'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Pindai ulang'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.text('Kamera depan tidak tersedia pada perangkat ini.'),
        findsOneWidget,
      );
      expect(find.textContaining('MissingPluginException'), findsNothing);
      expect(find.textContaining('java.lang'), findsNothing);
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.titleTextStyle?.color, Colors.white);
      await tester.ensureVisible(find.text('Pindai ulang'));
      expect(find.text('Pindai ulang'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
