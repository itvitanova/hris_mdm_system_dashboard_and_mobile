import '../../../../core/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/workspace.dart';
import '../../domain/repositories/workspace_repository.dart';
import '../datasources/workspace_remote_data_source.dart';

class WorkspaceRepositoryImpl implements WorkspaceRepository {
  final WorkspaceRemoteDataSource remoteDataSource;

  WorkspaceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Workspace>> getWorkspace() async {
    try {
      final data = await remoteDataSource.fetchWorkspace();
      return Success(Workspace(data));
    } on ApiException catch (e) {
      return FailureResult(ServerFailure(e.message, e.status));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
