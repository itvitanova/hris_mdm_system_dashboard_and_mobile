import 'dart:typed_data';
import '../../../../core/error/result.dart';

abstract class PayrollRepository {
  Future<Result<Uint8List>> downloadPayslipPdf(String slipId);
}
