import '../../../../core/error/result.dart';
import '../repositories/request_repository.dart';

class DecideRequestUseCase {
  final RequestRepository repository;
  const DecideRequestUseCase(this.repository);

  Future<Result<void>> call({
    required String id,
    required int revision,
    required String decision,
    String note = '',
  }) => repository.decideRequest(
    id: id,
    revision: revision,
    decision: decision,
    note: note,
  );
}
