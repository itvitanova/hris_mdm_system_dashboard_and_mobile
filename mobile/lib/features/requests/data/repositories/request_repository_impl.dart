import '../../../../core/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/request_repository.dart';
import '../datasources/request_remote_data_source.dart';

class RequestRepositoryImpl implements RequestRepository {
  final RequestRemoteDataSource remoteDataSource;

  RequestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<void>> submitRequest(Map<String, dynamic> requestData) async {
    try {
      await remoteDataSource.submit(requestData);
      return const Success(null);
    } on ApiException catch (e) {
      return FailureResult(ServerFailure(e.message, e.status));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> decideRequest({
    required String id,
    required int revision,
    required String decision,
    String note = '',
  }) async {
    try {
      await remoteDataSource.decide(
        id: id,
        revision: revision,
        decision: decision,
        note: note,
      );
      return const Success(null);
    } on ApiException catch (e) {
      return FailureResult(ServerFailure(e.message, e.status));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
