import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/api_client.dart';
import 'package:mdm_hris/core/error/result.dart';
import 'package:mdm_hris/features/auth/domain/repositories/auth_repository.dart';
import 'package:mdm_hris/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:mdm_hris/features/auth/domain/usecases/login_usecase.dart';
import 'package:mdm_hris/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mdm_hris/features/auth/domain/usecases/restore_session_usecase.dart';
import 'package:mdm_hris/features/auth/login_screen.dart';
import 'package:mdm_hris/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:mdm_hris/features/auth/presentation/bloc/auth_event.dart';

class _FakeAuthRepository implements AuthRepository {
  Completer<Result<void>>? loginCompleter;

  @override
  Future<Result<bool>> restoreSession() async => const Success(false);
  @override
  Future<Result<void>> login(String email, String password) async {
    if (loginCompleter != null) return loginCompleter!.future;
    return const Success(null);
  }
  @override
  Future<Result<void>> logout() async => const Success(null);
  @override
  Future<Result<void>> changePassword(
    String currentPassword,
    String newPassword,
  ) async =>
      const Success(null);
}

void main() {
  testWidgets('login validates before sending and fits phone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(api: ApiClient(), onLogin: () {}),
      ),
    );
    final buttonFinder = find.text('Sign In').evaluate().isNotEmpty
        ? find.text('Sign In')
        : find.text('Masuk');
    await tester.tap(buttonFinder);
    await tester.pumpAndSettle();
    expect(find.text('Masukkan email yang valid'), findsOneWidget);
    expect(find.text('Masukkan kata sandi'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('login screen does not stay in loading state after logout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final repo = _FakeAuthRepository();
    final authBloc = AuthBloc(
      restoreSessionUseCase: RestoreSessionUseCase(repo),
      loginUseCase: LoginUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      changePasswordUseCase: ChangePasswordUseCase(repo),
    );
    addTearDown(authBloc.close);

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: const LoginScreen(),
        ),
      ),
    );

    // Initial state: shows "Sign In"
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Signing In...'), findsNothing);

    // Simulate login with in-flight request
    repo.loginCompleter = Completer<Result<void>>();
    authBloc.add(
      const AuthLoginRequested(
        email: 'user@example.com',
        password: 'password123',
      ),
    );
    await tester.pump();
    // In AuthLoading, shows "Signing In..."
    expect(find.text('Signing In...'), findsOneWidget);

    // Complete login (Authenticated)
    repo.loginCompleter!.complete(const Success(null));
    await tester.pumpAndSettle();

    // Now trigger logout
    authBloc.add(const AuthLogoutRequested());
    await tester.pumpAndSettle();

    // After logout (Unauthenticated), login screen must show idle "Sign In", NOT "Signing In..."
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Signing In...'), findsNothing);
  });
}
