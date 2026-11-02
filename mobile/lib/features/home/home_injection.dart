import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import 'data/datasources/workspace_remote_data_source.dart';
import 'data/repositories/workspace_repository_impl.dart';
import 'domain/repositories/workspace_repository.dart';
import 'domain/usecases/get_workspace_usecase.dart';
import 'presentation/bloc/workspace_bloc.dart';

void initHomeInjection(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<WorkspaceRemoteDataSource>(
    () => WorkspaceRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<WorkspaceRepository>(
    () => WorkspaceRepositoryImpl(
      remoteDataSource: sl<WorkspaceRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<GetWorkspaceUseCase>(
    () => GetWorkspaceUseCase(sl<WorkspaceRepository>()),
  );

  // BLoC
  sl.registerFactory<WorkspaceBloc>(
    () => WorkspaceBloc(getWorkspaceUseCase: sl<GetWorkspaceUseCase>()),
  );
}
