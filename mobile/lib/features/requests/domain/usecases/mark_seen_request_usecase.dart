import '../../../../core/error/result.dart';
import '../repositories/request_repository.dart';

class MarkSeenRequestUseCase {
  final RequestRepository repository;
  const MarkSeenRequestUseCase(this.repository);

  Future<Result<void>> call({
    required String id,
    required String token,
  }) => repository.markSeenRequest(id: id, token: token);
}
