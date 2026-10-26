import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String email;
  final String? name;
  final String? employeeId;

  const UserEntity({
    required this.email,
    this.name,
    this.employeeId,
  });

  @override
  List<Object?> get props => [email, name, employeeId];
}
