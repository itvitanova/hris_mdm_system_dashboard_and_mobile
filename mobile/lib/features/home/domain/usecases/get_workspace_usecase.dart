import '../../../../core/error/result.dart';
import '../../../../core/workspace.dart';
import '../repositories/workspace_repository.dart';

class GetWorkspaceUseCase {
  final WorkspaceRepository repository;
  const GetWorkspaceUseCase(this.repository);

  Future<Result<Workspace>> call() => repository.getWorkspace();
}
