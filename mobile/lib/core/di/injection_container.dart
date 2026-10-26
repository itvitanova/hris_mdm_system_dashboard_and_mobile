import 'package:get_it/get_it.dart';
import '../api_client.dart';

// Auth
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/change_password_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/restore_session_usecase.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Home / Workspace
import '../../features/home/data/datasources/workspace_remote_data_source.dart';
import '../../features/home/data/repositories/workspace_repository_impl.dart';
import '../../features/home/domain/repositories/workspace_repository.dart';
import '../../features/home/domain/usecases/get_workspace_usecase.dart';
import '../../features/home/presentation/bloc/workspace_bloc.dart';

// Attendance
import '../../features/attendance/attendance_service.dart';
import '../../features/attendance/data/datasources/attendance_remote_data_source.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/enroll_face_usecase.dart';
import '../../features/attendance/domain/usecases/punch_attendance_usecase.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';

// Requests
import '../../features/requests/data/datasources/request_remote_data_source.dart';
import '../../features/requests/data/repositories/request_repository_impl.dart';
import '../../features/requests/domain/repositories/request_repository.dart';
import '../../features/requests/domain/usecases/decide_request_usecase.dart';
import '../../features/requests/domain/usecases/submit_request_usecase.dart';
import '../../features/requests/presentation/bloc/request_bloc.dart';

// Payroll
import '../../features/payroll/data/datasources/payroll_remote_data_source.dart';
import '../../features/payroll/data/repositories/payroll_repository_impl.dart';
import '../../features/payroll/domain/repositories/payroll_repository.dart';
import '../../features/payroll/domain/usecases/download_payslip_usecase.dart';
import '../../features/payroll/presentation/bloc/payroll_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies({ApiClient? customApiClient}) async {
  if (sl.isRegistered<ApiClient>()) {
    await sl.reset();
  }

  // 1. Core & Network Foundation
  sl.registerLazySingleton<ApiClient>(() => customApiClient ?? ApiClient());

  // 2. Auth Flow (Entry Point)
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );
  sl.registerLazySingleton<RestoreSessionUseCase>(
    () => RestoreSessionUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(sl<AuthRepository>()),
  );
  sl.registerLazySingleton<ChangePasswordUseCase>(
    () => ChangePasswordUseCase(sl<AuthRepository>()),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      restoreSessionUseCase: sl<RestoreSessionUseCase>(),
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      changePasswordUseCase: sl<ChangePasswordUseCase>(),
    ),
  );

  // 3. Main Feature Flow (Home, Attendance, Requests)
  // Home / Workspace
  sl.registerLazySingleton<WorkspaceRemoteDataSource>(
    () => WorkspaceRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(
      remoteDataSource: sl<WorkspaceRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<GetWorkspaceUseCase>(
    () => GetWorkspaceUseCase(sl<WorkspaceRepository>()),
  );
  sl.registerFactory<WorkspaceBloc>(
    () => WorkspaceBloc(getWorkspaceUseCase: sl<GetWorkspaceUseCase>()),
  );

  // Attendance
  sl.registerLazySingleton<AttendanceService>(
    () => AttendanceService(sl<ApiClient>()),
  );
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(service: sl<AttendanceService>()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(
      remoteDataSource: sl<AttendanceRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<PunchAttendanceUseCase>(
    () => PunchAttendanceUseCase(sl<AttendanceRepository>()),
  );
  sl.registerLazySingleton<EnrollFaceUseCase>(
    () => EnrollFaceUseCase(sl<AttendanceRepository>()),
  );
  sl.registerFactory<AttendanceBloc>(
    () => AttendanceBloc(
      punchAttendanceUseCase: sl<PunchAttendanceUseCase>(),
      enrollFaceUseCase: sl<EnrollFaceUseCase>(),
    ),
  );

  // Requests
  sl.registerLazySingleton<RequestRemoteDataSource>(
    () => RequestRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<RequestRepository>(
    () => RequestRepositoryImpl(
      remoteDataSource: sl<RequestRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<SubmitRequestUseCase>(
    () => SubmitRequestUseCase(sl<RequestRepository>()),
  );
  sl.registerLazySingleton<DecideRequestUseCase>(
    () => DecideRequestUseCase(sl<RequestRepository>()),
  );
  sl.registerFactory<RequestBloc>(
    () => RequestBloc(
      submitRequestUseCase: sl<SubmitRequestUseCase>(),
      decideRequestUseCase: sl<DecideRequestUseCase>(),
    ),
  );

  // 4. Secondary / Settlement Flow (Payroll)
  sl.registerLazySingleton<PayrollRemoteDataSource>(
    () => PayrollRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<PayrollRepository>(
    () => PayrollRepositoryImpl(
      remoteDataSource: sl<PayrollRemoteDataSource>(),
    ),
  );
  sl.registerLazySingleton<DownloadPayslipUseCase>(
    () => DownloadPayslipUseCase(sl<PayrollRepository>()),
  );
  sl.registerFactory<PayrollBloc>(
    () => PayrollBloc(downloadPayslipUseCase: sl<DownloadPayslipUseCase>()),
  );
}
