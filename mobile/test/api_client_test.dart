import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mdm_hris/core/api_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test('restores only session cookie, sends it and revokes on logout', () async {
    final seen = <String>[];
    final client = MockClient((request) async {
      seen.add(request.url.path);
      if (request.url.path == '/api/auth/login') {
        expect(jsonDecode(request.body)['password'], 'secret');
        return http.Response(
          '{}',
          200,
          headers: {
            'set-cookie':
                'hris_session=test-session; Path=/; HttpOnly; SameSite=Strict',
          },
        );
      }
      expect(request.headers['Cookie'], 'hris_session=test-session');
      return http.Response('{}', 200);
    });
    final api = ApiClient(client: client, baseUrl: 'https://example.test');
    await api.login('nadia@example.test', 'secret');
    final restored = ApiClient(client: client, baseUrl: 'https://example.test');
    expect(await restored.restore(), isTrue);
    await restored.workspace();
    await restored.logout();
    expect(await restored.restore(), isFalse);
    expect(seen, ['/api/auth/login', '/api/workspace', '/api/auth/logout']);
  });
  test('expired session is erased and triggers login flow', () async {
    FlutterSecureStorage.setMockInitialValues({
      'mdm_session_example.test': 'hris_session=old',
    });
    final api = ApiClient(
      baseUrl: 'https://example.test',
      client: MockClient(
        (_) async => http.Response('{"error":"Sesi berakhir"}', 401),
      ),
    );
    var expired = false;
    api.onUnauthorized = () => expired = true;
    await api.restore();
    await expectLater(api.workspace(), throwsA(isA<ApiException>()));
    expect(expired, isTrue);
    expect(await api.restore(), isFalse);
  });
  test('logout does not trigger onUnauthorized when unauthenticated or on 401', () async {
    final client = MockClient((_) async => http.Response('{"error":"Unauthorized"}', 401));
    final api = ApiClient(baseUrl: 'https://example.test', client: client);
    var unauthorizedCalled = false;
    api.onUnauthorized = () => unauthorizedCalled = true;

    await api.logout();
    expect(unauthorizedCalled, isFalse);
  });
}
