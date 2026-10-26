import 'package:equatable/equatable.dart';

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthBooting extends AuthState {
  const AuthBooting();
}

class Authenticated extends AuthState {
  const Authenticated();
}

class Unauthenticated extends AuthState {
  final String? message;
  const Unauthenticated([this.message]);

  @override
  List<Object?> get props => [message];
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthActionFailure extends AuthState {
  final String message;
  const AuthActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordChangeSuccess extends AuthState {
  const AuthPasswordChangeSuccess();
}
