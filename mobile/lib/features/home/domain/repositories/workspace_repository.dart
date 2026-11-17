import '../../../../core/errors/result.dart';
import '../../../../core/workspace.dart';

abstract class WorkspaceRepository {
  Future<Result<Workspace>> getWorkspace();
}
