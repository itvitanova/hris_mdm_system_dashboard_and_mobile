import 'package:get_it/get_it.dart';
import '../api_client.dart';
import '../../features/auth/auth_injection.dart';
import '../../features/home/home_injection.dart';
import '../../features/attendance/attendance_injection.dart';
import '../../features/requests/requests_injection.dart';
import '../../features/payroll/payroll_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies({ApiClient? customApiClient}) async {
  if (sl.isRegistered<ApiClient>()) {
    await sl.reset();
  }

  // 1. Core & Network Foundation
  sl.registerLazySingleton<ApiClient>(() => customApiClient ?? ApiClient());

  // 2. Feature Modular Injections
  initAuthInjection(sl);
  initHomeInjection(sl);
  initAttendanceInjection(sl);
  initRequestsInjection(sl);
  initPayrollInjection(sl);
}
