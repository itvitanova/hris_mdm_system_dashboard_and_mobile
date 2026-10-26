import 'package:camera/camera.dart';
import '../../../../core/error/result.dart';

abstract class AttendanceRepository {
  Future<Result<void>> enrollFace(String employeeId, XFile photo);
  Future<Result<void>> punch({
    required String type,
    required XFile photo,
    String earlyReason = '',
  });
}
