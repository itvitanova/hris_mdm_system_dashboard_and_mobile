import '../../../../core/api_client.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<bool>> restoreSession() async {
    try {
      final restored = await localDataSource.restoreSession();
      return Success(restored);
    } catch (_) {
      return const FailureResult(
        StorageFailure('Penyimpanan sesi tidak dapat dibuka. Silakan coba lagi.'),
      );
    }
  }

  @override
  Future<Result<void>> login(String email, String password) async {
    try {
      await remoteDataSource.login(email, password);
      return const Success(null);
    } on ApiException catch (e) {
      var msg = e.message;
      if (e.status == 401 &&
          (msg.contains('status 401') ||
              msg.contains('Permintaan gagal') ||
              msg.toLowerCase().contains('unauthorized'))) {
        msg = 'Email atau password salah';
      }
      if (e.status == 400 || e.status == 401 || e.status == 422) {
        return FailureResult(ValidationFailure(msg, e.status));
      }
      return FailureResult(ServerFailure(msg, e.status));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Success(null);
    } catch (_) {
      await localDataSource.clearSession();
      return const Success(null);
    }
  }

  @override
  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await remoteDataSource.changePassword(currentPassword, newPassword);
      await localDataSource.clearSession();
      return const Success(null);
    } on ApiException catch (e) {
      return FailureResult(ServerFailure(e.message, e.status));
    } catch (e) {
      return FailureResult(ServerFailure(e.toString()));
    }
  }
}
