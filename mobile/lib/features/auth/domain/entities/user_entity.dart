import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String? id;
  final String email;
  final String? name;
  final String? role;
  final String? employeeId;

  const UserEntity({
    this.id,
    required this.email,
    this.name,
    this.role,
    this.employeeId,
  });

  @override
  List<Object?> get props => [id, email, name, role, employeeId];
}
