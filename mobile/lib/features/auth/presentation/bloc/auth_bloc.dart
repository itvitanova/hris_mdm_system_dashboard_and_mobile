import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RestoreSessionUseCase restoreSessionUseCase;
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final ChangePasswordUseCase changePasswordUseCase;

  AuthBloc({
    required this.restoreSessionUseCase,
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.changePasswordUseCase,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthPasswordChangeRequested>(_onPasswordChangeRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthBooting());
    final result = await restoreSessionUseCase();
    result.fold(
      (failure) => emit(Unauthenticated(failure.message)),
      (restored) =>
          emit(restored ? const Authenticated() : const Unauthenticated()),
    );
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {

    emit(const AuthLoading());
    final result = await loginUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthActionFailure(failure.message)),
      (_) => emit(const Authenticated()),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {

    await logoutUseCase();
    emit(const Unauthenticated());
  }

  Future<void> _onPasswordChangeRequested(
    AuthPasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {

    emit(const AuthLoading());
    final result = await changePasswordUseCase(
      event.currentPassword,
      event.newPassword,
    );
    result.fold(
      (failure) => emit(AuthActionFailure(failure.message)),
      (_) => emit(const AuthPasswordChangeSuccess()),
    );
  }
}
