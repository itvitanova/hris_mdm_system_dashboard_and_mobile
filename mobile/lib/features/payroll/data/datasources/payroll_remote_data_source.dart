import 'dart:typed_data';
import '../../../../core/api_client.dart';

abstract class PayrollRemoteDataSource {
  Future<Uint8List> getPayslipPdf(String slipId);
}

class PayrollRemoteDataSourceImpl implements PayrollRemoteDataSource {
  final ApiClient apiClient;

  PayrollRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Uint8List> getPayslipPdf(String slipId) => apiClient.payslip(slipId);
}
