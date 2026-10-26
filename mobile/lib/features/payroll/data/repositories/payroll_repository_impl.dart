import 'dart:typed_data';
import '../../../../core/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/payroll_repository.dart';
import '../datasources/payroll_remote_data_source.dart';

class PayrollRepositoryImpl implements PayrollRepository {
  final PayrollRemoteDataSource remoteDataSource;

  PayrollRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<Uint8List>> downloadPayslipPdf(String slipId) async {
    try {
      final bytes = await remoteDataSource.getPayslipPdf(slipId);
      return Success(bytes);
    } on ApiException catch (e) {
      return FailureResult(ServerFailure(e.message, e.status));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
