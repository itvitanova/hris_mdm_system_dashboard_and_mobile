import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // This opt-in integration test intentionally talks to Docker, not the widget
  // binding's default HTTP-400 mock. Unit/widget tests retain their mocks.
  HttpOverrides.global = null;
  test(
    'real Docker API: employee scope, PDF and revocable session',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final api = ApiClient(
        baseUrl:
            Platform.environment['TEST_API_BASE_URL'] ??
            'http://127.0.0.1:3000',
      );
      await api.login(
        Platform.environment['TEST_EMAIL']!,
        Platform.environment['TEST_PASSWORD']!,
      );
      try {
        final data = await api.workspace();
        expect((data['employees'] as List).length, 1);
        final ownId = (data['actor'] as Map)['employeeId'];
        for (final payroll in data['payroll'] as List) {
          expect(payroll['employeeId'], ownId);
        }
        final payrolls = data['payroll'] as List;
        if (payrolls.isNotEmpty) {
          expect(
            String.fromCharCodes(
              (await api.payslip(payrolls.first['id'])).take(5),
            ),
            '%PDF-',
          );
        }
      } finally {
        await api.logout();
      }
      await expectLater(
        api.workspace(),
        throwsA(
          isA<ApiException>().having((e) => e.status, 'HTTP status', 401),
        ),
      );
    },
    skip:
        Platform.environment['TEST_EMAIL'] == null ||
        Platform.environment['TEST_PASSWORD'] == null,
  );
}
