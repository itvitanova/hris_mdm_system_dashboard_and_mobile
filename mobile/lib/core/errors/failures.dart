import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, [this.statusCode]);

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.statusCode]);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.statusCode]);
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message, [super.statusCode]);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.statusCode]);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.statusCode]);
}
