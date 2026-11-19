import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Helper service for loading, saving, and clearing remembered login credentials
class AuthRememberMeService {
  static const _keyEnabled = 'remember_me_enabled';
  static const _keyEmail = 'remember_me_email';
  static const _keyPassword = 'remember_me_password';

  static Future<({String? email, String? password, bool isEnabled})> load(
    FlutterSecureStorage storage,
  ) async {
    try {
      final enabled = await storage.read(key: _keyEnabled);
      if (enabled == 'true') {
        final email = await storage.read(key: _keyEmail);
        final password = await storage.read(key: _keyPassword);
        return (email: email, password: password, isEnabled: true);
      }
    } catch (_) {}
    return (email: null, password: null, isEnabled: false);
  }

  static Future<void> save(
    FlutterSecureStorage storage,
    String email,
    String password,
  ) async {
    try {
      await storage.write(key: _keyEnabled, value: 'true');
      await storage.write(key: _keyEmail, value: email);
      await storage.write(key: _keyPassword, value: password);
    } catch (_) {}
  }

  static Future<void> clear(FlutterSecureStorage storage) async {
    try {
      await storage.delete(key: _keyEnabled);
      await storage.delete(key: _keyEmail);
      await storage.delete(key: _keyPassword);
    } catch (_) {}
  }
}
