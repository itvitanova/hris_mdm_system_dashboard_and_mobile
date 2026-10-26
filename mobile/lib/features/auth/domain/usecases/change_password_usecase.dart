import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class ChangePasswordUseCase {
  final AuthRepository repository;
  const ChangePasswordUseCase(this.repository);

  Future<Result<void>> call(String currentPassword, String newPassword) =>
      repository.changePassword(currentPassword, newPassword);
}
