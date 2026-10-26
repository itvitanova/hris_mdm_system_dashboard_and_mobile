import '../../../../core/api_client.dart';

abstract class RequestRemoteDataSource {
  Future<void> submit(Map<String, dynamic> requestData);
  Future<void> decide({
    required String id,
    required int revision,
    required String decision,
    String note = '',
  });
}

class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final ApiClient apiClient;

  RequestRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<void> submit(Map<String, dynamic> requestData) =>
      apiClient.post('/requests', requestData);

  @override
  Future<void> decide({
    required String id,
    required int revision,
    required String decision,
    String note = '',
  }) => apiClient.post(
    '/requests/${Uri.encodeComponent(id)}/decision',
    {'revision': revision, 'decision': decision, 'note': note},
  );
}
