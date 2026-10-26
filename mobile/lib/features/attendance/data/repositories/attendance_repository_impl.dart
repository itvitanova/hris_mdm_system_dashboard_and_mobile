import 'package:camera/camera.dart';
import '../../../../core/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<void>> enrollFace(String employeeId, XFile photo) async {
    try {
      await remoteDataSource.enroll(employeeId, photo);
      return const Success(null);
    } on ApiException catch (e) {
      return FailureResult(ServerFailure(e.message, e.status));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> punch({
    required String type,
    required XFile photo,
    String earlyReason = '',
  }) async {
    try {
      await remoteDataSource.punch(type, photo, earlyReason: earlyReason);
      return const Success(null);
    } on ApiException catch (e) {
      return FailureResult(ServerFailure(e.message, e.status));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
