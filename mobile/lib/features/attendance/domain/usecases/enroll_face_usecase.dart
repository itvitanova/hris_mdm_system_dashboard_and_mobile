import 'package:camera/camera.dart';
import '../../../../core/error/result.dart';
import '../repositories/attendance_repository.dart';

class EnrollFaceUseCase {
  final AttendanceRepository repository;
  const EnrollFaceUseCase(this.repository);

  Future<Result<void>> call(String employeeId, XFile photo) =>
      repository.enrollFace(employeeId, photo);
}
