import 'package:equatable/equatable.dart';

class EmployeeEntity extends Equatable {
  final String id;
  final String employeeNumber;
  final String name;
  final String email;
  final String department;
  final String position;
  final String? departmentId;
  final String? positionId;
  final String status;
  final String phone;
  final String address;
  final String birthDate;
  final String joinDate;
  final int salary;
  final String ptkp;
  final int leaveBalance;
  final bool faceEnrolled;
  final String employmentType;
  final String? managerId;
  final String bankName;
  final String bankAccountName;
  final String bankAccountNumber;
  final bool financeVerifier;
  final String? servicePointId;
  final bool allowAnyLocation;

  const EmployeeEntity({
    required this.id,
    required this.employeeNumber,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    this.departmentId,
    this.positionId,
    required this.status,
    required this.phone,
    required this.address,
    required this.birthDate,
    required this.joinDate,
    required this.salary,
    required this.ptkp,
    required this.leaveBalance,
    required this.faceEnrolled,
    required this.employmentType,
    this.managerId,
    required this.bankName,
    required this.bankAccountName,
    required this.bankAccountNumber,
    required this.financeVerifier,
    this.servicePointId,
    required this.allowAnyLocation,
  });

  @override
  List<Object?> get props => [
    id,
    employeeNumber,
    name,
    email,
    department,
    position,
    departmentId,
    positionId,
    status,
    phone,
    address,
    birthDate,
    joinDate,
    salary,
    ptkp,
    leaveBalance,
    faceEnrolled,
    employmentType,
    managerId,
    bankName,
    bankAccountName,
    bankAccountNumber,
    financeVerifier,
    servicePointId,
    allowAnyLocation,
  ];
}
