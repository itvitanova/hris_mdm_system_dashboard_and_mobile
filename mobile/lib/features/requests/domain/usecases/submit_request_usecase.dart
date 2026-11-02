import '../../../../core/error/result.dart';
import '../repositories/request_repository.dart';

class SubmitRequestUseCase {
  final RequestRepository repository;
  const SubmitRequestUseCase(this.repository);

  Future<Result<void>> call(Map<String, dynamic> requestData) =>
      repository.submitRequest(requestData);
}
