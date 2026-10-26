import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/app.dart';
import 'package:mdm_hris/core/api_client.dart';

class DemoApi extends ApiClient {
  List<Map<String, dynamic>> attendanceRows = [];
  bool signedIn = true;
  List<Map<String, dynamic>> payrollRows = [];
  @override
  Future<bool> restore() async => signedIn;
  @override
  Future<Map<String, dynamic>> workspace() async => {
    'actor': {
      'employeeId': 'EMP-002',
      'name': 'Nadia Putri',
      'email': 'nadia@example.test',
    },
    'employees': [
      {
        'id': 'EMP-002',
        'name': 'Nadia Putri',
        'position': 'Product Designer',
        'department': 'Product & Design',
        'leaveBalance': 12,
        'faceEnrolled': true,
      },
    ],
    'requests': [
      {
        'employeeId': 'EMP-002',
        'kind': 'Cuti',
        'title': 'Cuti tahunan',
        'description': 'Keperluan keluarga',
        'status': 'Menunggu',
        'startDate': '2026-10-26',
        'endDate': '2026-10-27',
      },
    ],
    'payroll': payrollRows,
    'attendanceDate': '2026-10-23',
    'attendance': attendanceRows,
    'settings': {},
    'faceAvailable': false,
  };
}

Future<void> savePreview(
  WidgetTester tester,
  GlobalKey boundary,
  String name,
) async {
  if (!const bool.fromEnvironment('WRITE_PREVIEW')) return;
  await tester.runAsync(() async {
    final image =
        await (boundary.currentContext!.findRenderObject()
                as RenderRepaintBoundary)
            .toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final output = File('../tmp/mobile-$name.png');
    await output.parent.create(recursive: true);
    await output.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  for (final scale in [1.0, 2.0, 3.2]) {
    testWidgets('all tabs reflow at 360dp with font scale $scale', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final api = DemoApi();
      api.attendanceRows = [
        {
          'employeeId': 'EMP-002',
          'date': '2026-10-23',
          'status': 'Hadir',
          'checkIn': '2026-10-23T09:00:00+07:00',
          'checkOut': '',
        },
      ];
      api.payrollRows = [
        {
          'employeeId': 'EMP-002',
          'id': 'PAY-001',
          'period': '2026-10',
          'status': 'Final',
          'netSalary': 1250000000,
          'baseSalary': 1250000000,
          'deductions': 0,
          'employeeName': 'Nadia Putri',
          'department': 'Product & Design',
          'companyName': 'Perusahaan contoh',
        },
      ];
      await tester.pumpWidget(HrisApp(api: api));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      // Traverse the complete scroll extent, including content built lazily.
      for (final destination in [
        'Beranda',
        'Pengajuan',
        'Slip gaji',
        'Profil',
      ]) {
        await tester.tap(find.text(destination).last);
        await tester.pumpAndSettle();
        final scrollable = tester.state<ScrollableState>(
          find.byType(Scrollable).first,
        );
        while (scrollable.position.pixels <
            scrollable.position.maxScrollExtent) {
          await tester.drag(
            find.byType(Scrollable).first,
            const Offset(0, -400),
          );
          await tester.pumpAndSettle();
          expect(
            tester.takeException(),
            isNull,
            reason: '$destination / $scale',
          );
        }
        expect(tester.takeException(), isNull, reason: '$destination / $scale');
        if (destination == 'Slip gaji') {
          await tester.ensureVisible(find.text('2026-10'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('2026-10'));
          await tester.pumpAndSettle();
          expect(find.text('Gaji bersih'), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pageBack();
          await tester.pumpAndSettle();
        }
      }
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets(
    'home refreshes the attendance action after returning from the scanner page',
    (tester) async {
      const locationChannel = MethodChannel('flutter.baseflow.com/geolocator');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(locationChannel, (_) async => false);
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(locationChannel, null),
      );
      final api = DemoApi();
      await tester.pumpWidget(HrisApp(api: api));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Absensi Masuk'));
      await tester.pumpAndSettle();
      api.attendanceRows = [
        {
          'employeeId': 'EMP-002',
          'date': '2026-10-23',
          'checkIn': '2026-10-23T09:00:00+07:00',
          'checkOut': '',
        },
      ];
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FilledButton, 'Absensi Keluar'),
        findsOneWidget,
      );
      await tester.tap(find.text('Absensi Keluar'));
      await tester.pumpAndSettle();
      api.attendanceRows = [
        {...api.attendanceRows.first, 'checkOut': '2026-10-23T17:00:00+07:00'},
      ];
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Absensi Selesai'),
            )
            .onPressed,
        isNull,
      );
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  testWidgets(
    'employee home and navigation fit a phone; face unconfigured blocks punching',
    (tester) async {
      const locationChannel = MethodChannel('flutter.baseflow.com/geolocator');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(locationChannel, (call) async {
            if (call.method == 'isLocationServiceEnabled') return false;
            return null;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(locationChannel, null),
      );
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundary = GlobalKey();
      if (const bool.fromEnvironment('WRITE_PREVIEW')) {
        await tester.runAsync(() async {
          final fonts = Platform.environment['FLUTTER_PREVIEW_FONTS'];
          if (fonts != null) {
            final loader = FontLoader('Roboto');
            for (final name in [
              'roboto-regular.ttf',
              'roboto-bold.ttf',
              'roboto-medium.ttf',
            ]) {
              loader.addFont(
                File(
                  '$fonts/$name',
                ).readAsBytes().then((b) => ByteData.sublistView(b)),
              );
            }
            await loader.load();
            await (FontLoader('MaterialIcons')..addFont(
                  File(
                    '$fonts/materialicons-regular.otf',
                  ).readAsBytes().then((b) => ByteData.sublistView(b)),
                ))
                .load();
          }
        });
      }
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: HrisApp(api: DemoApi()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Nadia Putri'), findsOneWidget);
      expect(find.text('12 hari'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await savePreview(tester, boundary, 'preview');
      await tester.tap(find.text('Pengajuan').last);
      await tester.pumpAndSettle();
      expect(find.text('Cuti tahunan'), findsOneWidget);
      await savePreview(tester, boundary, 'requests');
      await tester.tap(find.text('Slip gaji').last);
      await tester.pumpAndSettle();
      expect(find.text('Slip gaji belum tersedia.'), findsOneWidget);
      await savePreview(tester, boundary, 'payroll-empty');
      await tester.tap(find.text('Profil').last);
      await tester.pumpAndSettle();
      await savePreview(tester, boundary, 'profile');
      await tester.tap(find.text('Beranda'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Absensi Masuk'));
      await tester.pumpAndSettle();
      expect(find.text('Coba pemindai wajah'), findsNothing);
      expect(find.text('Periksa lokasi'), findsNothing);
      await tester.scrollUntilVisible(
        find.widgetWithText(FilledButton, 'Absensi Masuk'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Absensi Masuk'),
            )
            .onPressed,
        isNull,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: HrisApp(key: UniqueKey(), api: DemoApi()..signedIn = false),
        ),
      );
      await tester.pumpAndSettle();
      await savePreview(tester, boundary, 'login');
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );
}
