import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import 'data/datasources/auth_local_data_source.dart';
import 'data/datasources/auth_remote_data_source.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/change_password_usecase.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/restore_session_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';

void initAuthInjection(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl<AuthRemoteDataSource>(),
      localDataSource: sl<AuthLocalDataSource>(),
    ),
  );

  // Use Cases
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

  // BLoC
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      restoreSessionUseCase: sl<RestoreSessionUseCase>(),
      loginUseCase: sl<LoginUseCase>(),
      logoutUseCase: sl<LogoutUseCase>(),
      changePasswordUseCase: sl<ChangePasswordUseCase>(),
    ),
  );
}
