import 'package:camera/camera.dart';
import '../../attendance_service.dart';

abstract class AttendanceRemoteDataSource {
  Future<void> enroll(String employeeId, XFile photo);
  Future<void> punch(String type, XFile photo, {String earlyReason = ''});
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final AttendanceService service;

  AttendanceRemoteDataSourceImpl({required this.service});

  @override
  Future<void> enroll(String employeeId, XFile photo) =>
      service.enroll(employeeId, photo);

  @override
  Future<void> punch(String type, XFile photo, {String earlyReason = ''}) =>
      service.punch(type, photo, earlyReason: earlyReason);
}
