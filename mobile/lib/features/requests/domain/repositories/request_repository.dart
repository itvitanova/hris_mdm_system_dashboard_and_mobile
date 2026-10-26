import '../../../../core/error/result.dart';

abstract class RequestRepository {
  Future<Result<void>> submitRequest(Map<String, dynamic> requestData);
  Future<Result<void>> decideRequest({
    required String id,
    required int revision,
    required String decision,
    String note = '',
  });
}
