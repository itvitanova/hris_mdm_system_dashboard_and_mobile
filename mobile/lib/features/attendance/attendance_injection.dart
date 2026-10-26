import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import 'attendance_service.dart';
import 'data/datasources/attendance_remote_data_source.dart';
import 'data/repositories/attendance_repository_impl.dart';
import 'domain/repositories/attendance_repository.dart';
import 'domain/usecases/enroll_face_usecase.dart';
import 'domain/usecases/punch_attendance_usecase.dart';
import 'presentation/bloc/attendance_bloc.dart';

void initAttendanceInjection(GetIt sl) {
  // Service
  sl.registerLazySingleton<AttendanceService>(
    () => AttendanceService(sl<ApiClient>()),
  );

  // Data Sources
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(service: sl<AttendanceService>()),
  );

  // Repositories
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: sl<AttendanceRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<EnrollFaceUseCase>(
    () => EnrollFaceUseCase(sl<AttendanceRepository>()),
  );
  sl.registerLazySingleton<PunchAttendanceUseCase>(
    () => PunchAttendanceUseCase(sl<AttendanceRepository>()),
  );

  // BLoC
  sl.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(
      punchAttendanceUseCase: sl<PunchAttendanceUseCase>(),
      enrollFaceUseCase: sl<EnrollFaceUseCase>(),
    ),
  );
}
