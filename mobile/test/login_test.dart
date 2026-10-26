import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/features/auth/login_screen.dart';

void main() {
  testWidgets('login validates before sending and fits phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(api: ApiClient(), onLogin: () {}),
      ),
    );
    final buttonFinder = find.text('Sign In').evaluate().isNotEmpty
        ? find.text('Sign In')
        : find.text('Masuk');
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(find.text('Masukkan kata sandi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
