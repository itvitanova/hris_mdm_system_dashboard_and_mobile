import 'dart:typed_data';
import '../../../../core/error/result.dart';
import '../repositories/payroll_repository.dart';

class DownloadPayslipUseCase {
  final PayrollRepository repository;
  const DownloadPayslipUseCase(this.repository);

  Future<Result<Uint8List>> call(String slipId) =>
      repository.downloadPayslipPdf(slipId);
}
