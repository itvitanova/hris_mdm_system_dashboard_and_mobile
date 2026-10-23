import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int status;
  ApiException(this.message, [this.status = 0]);
  @override
  String toString() => message;
}

/// Existing revocable, 12-hour server session. Passwords are never saved.
class ApiClient {
  ApiClient({
    http.Client? client,
    FlutterSecureStorage? storage,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _storage = storage ?? const FlutterSecureStorage(),
       baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'API_BASE_URL',
             defaultValue: 'http://10.0.2.2:3000',
           );
  final http.Client _client;
  final FlutterSecureStorage _storage;
  final String baseUrl;
  String? _cookie;
  String get _storageKey => 'mdm_session_${Uri.parse(baseUrl).authority}';
  VoidCallback? onUnauthorized;

  Future<bool> restore() async {
    _cookie = await _storage.read(key: _storageKey);
    return _cookie != null;
  }

  Future<http.Response> _send(
    String method,
    String path, [
    Map<String, dynamic>? body,
  ]) async {
    final base = Uri.parse(baseUrl);
    if (base.host.isEmpty || (!kDebugMode && base.scheme != 'https')) {
      throw ApiException('Alamat server rilis harus menggunakan HTTPS.');
    }
    try {
      final request = http.Request(method, base.resolve('/api$path'));
      request.headers['Content-Type'] = 'application/json';
      if (_cookie != null) request.headers['Cookie'] = _cookie!;
      if (body != null) request.body = jsonEncode(body);
      final response = await _client
          .send(request)
          .then(http.Response.fromStream)
          .timeout(const Duration(seconds: 45));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message = 'Permintaan gagal (${response.statusCode}).';
        try {
          message =
              (jsonDecode(response.body) as Map)['error']?.toString() ??
              message;
        } catch (_) {
          /* Non-JSON gateway error. */
        }
        if (response.statusCode == 401 && path != '/auth/login') {
          await forget();
          onUnauthorized?.call();
        }
        throw ApiException(message, response.statusCode);
      }
      return response;
    } on SocketException {
      throw ApiException(
        'Tidak dapat terhubung. Periksa jaringan dan alamat server.',
      );
    } on http.ClientException {
      throw ApiException('Koneksi ke server gagal. Periksa jaringan Anda.');
    } on TimeoutException {
      throw ApiException(
        'Server belum merespons. Periksa riwayat sebelum mencoba ulang.',
      );
    }
  }

  Future<void> login(String email, String password) async {
    final response = await _send('POST', '/auth/login', {
      'email': email.trim(),
      'password': password,
    });
    final header = response.headers['set-cookie'];
    final match = header == null
        ? null
        : RegExp(r'hris_session=([^;\s,]+)').firstMatch(header);
    if (match == null) throw ApiException('Server tidak mengirim sesi login.');
    _cookie = 'hris_session=${match.group(1)}';
    try {
      await _storage.write(key: _storageKey, value: _cookie);
    } catch (_) {
      _cookie = null;
      throw ApiException('Penyimpanan sesi aman tidak tersedia.');
    }
  }

  Future<Map<String, dynamic>> workspace() async =>
      jsonDecode((await _send('GET', '/workspace')).body)
          as Map<String, dynamic>;
  Future<void> post(String path, Map<String, dynamic> body) async {
    await _send('POST', path, body);
  }

  Future<Uint8List> payslip(String id) async {
    final response = await _send(
      'GET',
      '/payroll/${Uri.encodeComponent(id)}/pdf',
    );
    if (!response.headers['content-type'].toString().contains(
      'application/pdf',
    )) {
      throw ApiException('Slip PDF tidak valid.');
    }
    return response.bodyBytes;
  }

  Future<void> logout() async {
    // Preserve on connection failure so revocation can be retried.
    await post('/auth/logout', {});
    await forget();
  }

  Future<void> forget() async {
    _cookie = null;
    await _storage.delete(key: _storageKey);
  }
}
