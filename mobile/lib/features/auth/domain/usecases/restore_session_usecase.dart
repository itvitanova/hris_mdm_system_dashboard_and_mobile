import '../../../../core/error/result.dart';
import '../repositories/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository repository;
  const RestoreSessionUseCase(this.repository);

  Future<Result<bool>> call() => repository.restoreSession();
}
