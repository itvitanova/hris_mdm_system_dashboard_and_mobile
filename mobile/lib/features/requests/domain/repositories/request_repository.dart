import '../../../../core/error/result.dart';

abstract class RequestRepository {
  Future<Result<List<Map<String, dynamic>>>> getRequests({
    String? kind,
    String? status,
    String? review,
  });
  Future<Result<void>> submitRequest(Map<String, dynamic> requestData);
  Future<Result<void>> decideRequest({
    required String id,
    required int revision,
    required String decision,
    String note = '',
  });
  Future<Result<void>> markSeenRequest({
    required String id,
    required String token,
  });
}
