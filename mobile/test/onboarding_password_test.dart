import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/app.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/features/auth/change_password_screen.dart';

class AccountApi extends ApiClient {
  bool enrolled = false;
  int writes = 0;
  String? path;
  Map<String, dynamic>? payload;
  @override
  Future<bool> restore() async => true;
  @override
  Future<Map<String, dynamic>> workspace() async => {
    'actor': {'employeeId': 'EMP-002', 'name': 'Nadia'},
    'employees': [
      {'id': 'EMP-002', 'faceEnrolled': enrolled},
    ],
    'settings': {},
    'faceAvailable': true,
  };
  @override
  Future<void> post(String path, Map<String, dynamic> body) async {
    writes++;
    this.path = path;
    payload = body;
  }

  @override
  Future<void> forget() async {}
}

void main() {
  testWidgets('first login requires own face registration before home', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final api = AccountApi();
    await tester.pumpWidget(HrisApp(api: api));
    await tester.pumpAndSettle();
    expect(find.text('Daftarkan wajah'), findsOneWidget);
    expect(find.text('Absensi Masuk'), findsNothing);
    expect(find.text('Keluar'), findsOneWidget);
    expect(api.writes, 0);
  });

  testWidgets(
    'password confirmation blocks mismatches and submits old and new password',
    (tester) async {
      final api = AccountApi();
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => MaterialApp(
            home: ChangePasswordScreen(api: api),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'OldPassword123!');
      await tester.enterText(fields.at(1), 'NewPassword456!');
      await tester.enterText(fields.at(2), 'wrong');
      await tester.pumpAndSettle();

      final submitBtn = find.byKey(const Key('submit_change_password_button'));
      await tester.scrollUntilVisible(
        submitBtn,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
      expect(api.writes, 0);
      expect(find.text('Konfirmasi password tidak cocok'), findsOneWidget);

      await tester.enterText(fields.at(2), 'NewPassword456!');
      await tester.pumpAndSettle();
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
      expect(api.path, '/auth/password');
      expect(api.payload, {
        'currentPassword': 'OldPassword123!',
        'newPassword': 'NewPassword456!',
      });
    },
  );
}
