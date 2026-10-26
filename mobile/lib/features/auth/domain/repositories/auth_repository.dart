import '../../../../core/error/result.dart';

abstract class AuthRepository {
  Future<Result<bool>> restoreSession();
  Future<Result<void>> login(String email, String password);
  Future<Result<void>> logout();
  Future<Result<void>> changePassword(String currentPassword, String newPassword);
}
