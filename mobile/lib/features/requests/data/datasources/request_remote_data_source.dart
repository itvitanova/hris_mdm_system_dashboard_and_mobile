import '../../../../core/api_client.dart';

abstract class RequestRemoteDataSource {
  Future<List<Map<String, dynamic>>> getRequests({
    String? kind,
    String? status,
    String? review,
  });
  Future<void> submit(Map<String, dynamic> requestData);
  Future<void> decide({
    required String id,
    required int revision,
    required String decision,
    String note = '',
  });
  Future<void> markSeen({
    required String id,
    required String token,
  });
}

class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final ApiClient apiClient;

  RequestRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<Map<String, dynamic>>> getRequests({
    String? kind,
    String? status,
    String? review,
  }) async {
    final queryParams = <String, String>{};
    if (kind != null && kind.isNotEmpty) queryParams['kind'] = kind;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (review != null && review.isNotEmpty) queryParams['review'] = review;

    try {
      final path = Uri(
        path: '/requests',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      ).toString();
      final list = await apiClient.getList(path);
      return list;
    } catch (_) {
      // Fallback: baca dari workspace.mine('requests')
      final ws = await apiClient.workspace();
      final actor = ws['actor'] as Map<String, dynamic>? ?? {};
      final rows = (ws['requests'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .where((r) => r['employeeId'] == actor['employeeId'])
          .toList();
      return rows.where((r) {
        if (kind != null && kind.isNotEmpty) {
          final rKind = (r['kind'] ?? r['type'])?.toString();
          if (rKind?.toLowerCase() != kind.toLowerCase()) return false;
        }
        if (status != null && status.isNotEmpty) {
          final rStatus = r['status']?.toString();
          if (rStatus?.toLowerCase() != status.toLowerCase()) return false;
        }
        return true;
      }).toList();
    }
  }

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
    '/requests/${Uri.encodeComponent(id)}/review',
    {'revision': revision, 'status': decision, 'note': note},
  );

  @override
  Future<void> markSeen({
    required String id,
    required String token,
  }) => apiClient.post(
    '/requests/${Uri.encodeComponent(id)}/seen',
    {'token': token},
  );
}
