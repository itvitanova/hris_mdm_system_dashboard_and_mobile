import '../../../../core/api_client.dart';

abstract class WorkspaceRemoteDataSource {
  Future<Map<String, dynamic>> fetchWorkspace();
}

class WorkspaceRemoteDataSourceImpl implements WorkspaceRemoteDataSource {
  final ApiClient apiClient;

  WorkspaceRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> fetchWorkspace() => apiClient.workspace();
}
