import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  const LoginUseCase(this.repository);

  Future<Result<void>> call(String email, String password) =>
      repository.login(email, password);
}
