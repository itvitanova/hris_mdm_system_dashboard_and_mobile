import 'package:get_it/get_it.dart';
import '../api_client.dart';
import '../services/network_connectivity_service.dart';
import '../services/offline_storage_service.dart';
import '../services/offline_sync_manager.dart';
import '../../features/auth/auth_injection.dart';
import '../../features/home/home_injection.dart';
import '../../features/home/presentation/bloc/workspace_bloc.dart';
import '../../features/home/presentation/bloc/workspace_event.dart';
import '../../features/attendance/attendance_injection.dart';
import '../../features/requests/requests_injection.dart';
import '../../features/requests/presentation/bloc/request_bloc.dart';
import '../../features/requests/presentation/bloc/request_event.dart';
import '../../features/payroll/payroll_injection.dart';

final sl = GetIt.instance;

Future<void> initDependencies({ApiClient? customApiClient}) async {
  if (sl.isRegistered<ApiClient>()) {
    if (customApiClient == null || identical(sl<ApiClient>(), customApiClient)) {
      return;
    }
    await sl.reset();
  }

  // 1. Core Services & Network Foundation
  final offlineStorage = OfflineStorageService();
  final connectivityService = NetworkConnectivityService();
  connectivityService.startMonitoring();
  sl.registerLazySingleton<OfflineStorageService>(() => offlineStorage);
  sl.registerLazySingleton<NetworkConnectivityService>(() => connectivityService);

  final client = customApiClient ??
      ApiClient(
        offlineStorage: offlineStorage,
        connectivityService: connectivityService,
      );
  if (customApiClient != null) {
    customApiClient.offlineStorage ??= offlineStorage;
    customApiClient.connectivityService ??= connectivityService;
  }
  sl.registerLazySingleton<ApiClient>(() => client);

  // 2. Offline Sync Manager
  final syncManager = OfflineSyncManager(
    apiClient: sl<ApiClient>(),
    offlineStorage: sl<OfflineStorageService>(),
    connectivityService: sl<NetworkConnectivityService>(),
    onSyncCompleted: () {
      if (sl.isRegistered<WorkspaceBloc>()) {
        sl<WorkspaceBloc>().add(const WorkspaceRefreshRequested());
      }
      if (sl.isRegistered<RequestBloc>()) {
        sl<RequestBloc>().add(const RequestLoadRequested());
      }
    },
  );
  syncManager.initialize();
  connectivityService.startMonitoring();
  sl.registerLazySingleton<OfflineSyncManager>(() => syncManager);

  // 3. Feature Modular Injections
  initAuthInjection(sl);
  initHomeInjection(sl);
  initAttendanceInjection(sl);
  initRequestsInjection(sl);
  initPayrollInjection(sl);
}
