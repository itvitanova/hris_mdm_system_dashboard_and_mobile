import '../../../../core/api_client.dart';

abstract class AuthRemoteDataSource {
  Future<void> login(String email, String password);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> login(String email, String password) =>
      apiClient.login(email, password);

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await apiClient.post('/auth/password', {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
  }

  @override
  Future<void> logout() => apiClient.logout();
}
