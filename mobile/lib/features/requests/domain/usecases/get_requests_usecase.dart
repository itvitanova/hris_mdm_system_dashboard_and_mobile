import '../../../../core/error/result.dart';
import '../repositories/request_repository.dart';

class GetRequestsUseCase {
  final RequestRepository repository;

  GetRequestsUseCase(this.repository);

  Future<Result<List<Map<String, dynamic>>>> call({
    String? kind,
    String? status,
    String? review,
  }) {
    return repository.getRequests(
      kind: kind,
      status: status,
      review: review,
    );
  }
}
