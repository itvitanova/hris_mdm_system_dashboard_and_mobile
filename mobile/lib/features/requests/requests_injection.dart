import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import 'data/datasources/request_remote_data_source.dart';
import 'data/repositories/request_repository_impl.dart';
import 'domain/repositories/request_repository.dart';
import 'domain/usecases/decide_request_usecase.dart';
import 'domain/usecases/submit_request_usecase.dart';
import 'presentation/bloc/request_bloc.dart';

void initRequestsInjection(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<RequestRemoteDataSource>(
    () => RequestRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<RequestRepository>(
    () => RequestRepositoryImpl(
      remoteDataSource: sl<RequestRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<SubmitRequestUseCase>(
    () => SubmitRequestUseCase(sl<RequestRepository>()),
  );
  sl.registerLazySingleton<DecideRequestUseCase>(
    () => DecideRequestUseCase(sl<RequestRepository>()),
  );

  // BLoC
  sl.registerFactory<RequestBloc>(
    () => RequestBloc(
      submitRequestUseCase: sl<SubmitRequestUseCase>(),
      decideRequestUseCase: sl<DecideRequestUseCase>(),
    ),
  );
}
