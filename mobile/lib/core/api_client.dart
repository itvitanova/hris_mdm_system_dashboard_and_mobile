import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'services/network_connectivity_service.dart';
import 'services/offline_storage_service.dart';

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
    this.offlineStorage,
    this.connectivityService,
    String? baseUrl,
  }) : _client = client ?? http.Client(),
       _storage = storage ?? const FlutterSecureStorage(),
       baseUrl =
           baseUrl ??
           const String.fromEnvironment(
             'API_BASE_URL',
             defaultValue: 'https://hris.mdmcorp.co.id',
           );
  final http.Client _client;
  final FlutterSecureStorage _storage;
  OfflineStorageService? offlineStorage;
  NetworkConnectivityService? connectivityService;
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
          .timeout(Duration(seconds: path.contains('/document/') ? 120 : 45));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        String message = 'Permintaan gagal (${response.statusCode}).';
        try {
          message =
              (jsonDecode(response.body) as Map)['error']?.toString() ??
              message;
        } catch (_) {
          /* Non-JSON gateway error. */
        }
        if (response.statusCode == 401 &&
            path != '/auth/login' &&
            path != '/auth/logout') {
          await forget();
          onUnauthorized?.call();
        }
        throw ApiException(message, response.statusCode);
      }
      connectivityService?.setOnline(true);
      return response;
    } on SocketException {
      connectivityService?.setOnline(false);
      throw ApiException(
        'Tidak dapat terhubung. Periksa jaringan dan alamat server.',
      );
    } on http.ClientException {
      connectivityService?.setOnline(false);
      throw ApiException('Koneksi ke server gagal. Periksa jaringan Anda.');
    } on TimeoutException {
      connectivityService?.setOnline(false);
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

  Future<Map<String, dynamic>> workspace() async {
    Map<String, dynamic> data;
    try {
      final response = await _send('GET', '/workspace');
      data = jsonDecode(response.body) as Map<String, dynamic>;
      offlineStorage?.saveWorkspaceCache(data);
    } catch (e) {
      if (offlineStorage != null) {
        final cached = await offlineStorage!.loadWorkspaceCache();
        if (cached != null) {
          data = cached;
        } else {
          rethrow;
        }
      } else {
        rethrow;
      }
    }

    // Merge offline pending requests into data['requests'] so the entire app sees them
    if (offlineStorage != null) {
      final queue = await offlineStorage!.loadQueue();
      if (queue.isNotEmpty) {
        final existingRequests = List<Map<String, dynamic>>.from(
          (data['requests'] as List?)
                  ?.whereType<Map>()
                  .map((m) => Map<String, dynamic>.from(m)) ??
              [],
        );
        final actor = (data['actor'] as Map?) ?? {};
        final employeeId = actor['employeeId']?.toString() ?? '';
        final employee = ((data['employees'] as List?) ?? [])
            .firstWhere((e) => e['id'] == employeeId, orElse: () => {});
        final employeeName = actor['name']?.toString() ??
            (employee is Map ? employee['name']?.toString() : null) ??
            'Karyawan';
        final department =
            employee is Map ? employee['department']?.toString() : null;

        final pendingItems = queue.map((q) {
          final payload = Map<String, dynamic>.from(q['payload'] as Map? ?? {});
          return <String, dynamic>{
            'id': q['id'],
            'kind': q['kind'] ?? payload['kind'] ?? 'Pengajuan',
            'type': q['kind'] ?? payload['kind'] ?? 'Pengajuan',
            'title': q['title'] ?? payload['title'] ?? 'Pengajuan',
            'description':
                q['notes'] ?? payload['notes'] ?? payload['reason'] ?? '',
            'status': 'Menunggu Sinkronisasi',
            'startDate': payload['startDate'],
            'endDate': payload['endDate'],
            'days': payload['days'],
            'hours': payload['hours'],
            'amount': payload['amount'],
            'employeeId': employeeId,
            'employeeName': employeeName,
            'department': department,
            'items': payload['items'],
            'isOffline': true,
            'createdAt': q['createdAt'],
          };
        }).toList();

        data['requests'] = [...pendingItems, ...existingRequests];
      }
    }

    return data;
  }

  Future<List<Map<String, dynamic>>> getList(String path) async {
    final decoded = jsonDecode((await _send('GET', path)).body);
    if (decoded is List) {
      return decoded.map((v) => Map<String, dynamic>.from(v as Map)).toList();
    }
    if (decoded is Map && decoded['data'] is List) {
      return (decoded['data'] as List)
          .map((v) => Map<String, dynamic>.from(v as Map))
          .toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> getJson(String path) async =>
      jsonDecode((await _send('GET', path)).body) as Map<String, dynamic>;

  Future<void> post(String path, Map<String, dynamic> body) async {
    await _send('POST', path, body);
  }

  Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async =>
      jsonDecode((await _send('POST', path, body)).body)
          as Map<String, dynamic>;

  Future<({Uint8List bytes, String contentType})> requestFile(
    String path,
  ) async {
    final response = await _send('GET', path);
    return (
      bytes: response.bodyBytes,
      contentType:
          response.headers['content-type'] ?? 'application/octet-stream',
    );
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
    if (_cookie != null) {
      try {
        await post('/auth/logout', {});
      } catch (_) {
        // Ignored: network error or session already expired on server
      }
    }
    await forget();
  }

  Future<void> forget() async {
    _cookie = null;
    await _storage.delete(key: _storageKey);
    await offlineStorage?.clearWorkspaceCache();
    await offlineStorage?.clearSavedAttachments();
  }
}
