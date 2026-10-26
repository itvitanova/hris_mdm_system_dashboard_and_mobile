import '../../../../core/api_client.dart';

abstract class AuthLocalDataSource {
  Future<bool> restoreSession();
  Future<void> clearSession();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final ApiClient apiClient;

  AuthLocalDataSourceImpl({required this.apiClient});

  @override
  Future<bool> restoreSession() => apiClient.restore();

  @override
  Future<void> clearSession() => apiClient.forget();
}
