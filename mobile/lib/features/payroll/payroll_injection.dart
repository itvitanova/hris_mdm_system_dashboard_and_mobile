import 'package:get_it/get_it.dart';
import '../../core/api_client.dart';
import 'data/datasources/payroll_remote_data_source.dart';
import 'data/repositories/payroll_repository_impl.dart';
import 'domain/repositories/payroll_repository.dart';
import 'domain/usecases/download_payslip_usecase.dart';
import 'presentation/bloc/payroll_bloc.dart';

void initPayrollInjection(GetIt sl) {
  // Data Sources
  sl.registerLazySingleton<PayrollRemoteDataSource>(
    () => PayrollRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Repositories
  sl.registerLazySingleton<PayrollRepository>(
    () => PayrollRepositoryImpl(
      remoteDataSource: sl<PayrollRemoteDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton<DownloadPayslipUseCase>(
    () => DownloadPayslipUseCase(sl<PayrollRepository>()),
  );

  // BLoC
  sl.registerFactory<PayrollBloc>(
    () => PayrollBloc(downloadPayslipUseCase: sl<DownloadPayslipUseCase>()),
  );
}
