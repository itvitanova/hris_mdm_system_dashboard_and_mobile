import 'package:camera/camera.dart';
import '../../../../core/error/result.dart';
import '../repositories/attendance_repository.dart';

class PunchAttendanceUseCase {
  final AttendanceRepository repository;
  const PunchAttendanceUseCase(this.repository);

  Future<Result<void>> call({
    required String type,
    required XFile photo,
    String earlyReason = '',
  }) => repository.punch(
    type: type,
    photo: photo,
    earlyReason: earlyReason,
  );
}
