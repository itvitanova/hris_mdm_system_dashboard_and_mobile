import '../../domain/entities/employee_entity.dart';

int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? defaultValue;
}

bool _parseBool(dynamic value, [bool defaultValue = false]) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value.toString().toLowerCase() == 'true';
}

class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.id,
    required super.employeeNumber,
    required super.name,
    required super.email,
    required super.department,
    required super.position,
    super.departmentId,
    super.positionId,
    required super.status,
    required super.phone,
    required super.address,
    required super.birthDate,
    required super.joinDate,
    required super.salary,
    required super.ptkp,
    required super.leaveBalance,
    required super.faceEnrolled,
    required super.employmentType,
    super.managerId,
    required super.bankName,
    required super.bankAccountName,
    required super.bankAccountNumber,
    required super.financeVerifier,
    super.servicePointId,
    required super.allowAnyLocation,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      employeeNumber: json['employeeNumber']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      departmentId: json['departmentId']?.toString(),
      positionId: json['positionId']?.toString(),
      status: json['status']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      birthDate: json['birthDate']?.toString() ?? '',
      joinDate: json['joinDate']?.toString() ?? '',
      salary: _parseInt(json['salary']),
      ptkp: json['ptkp']?.toString() ?? '',
      leaveBalance: _parseInt(json['leaveBalance']),
      faceEnrolled: _parseBool(json['faceEnrolled']),
      employmentType: json['employmentType']?.toString() ?? '',
      managerId: json['managerId']?.toString(),
      bankName: json['bankName']?.toString() ?? '',
      bankAccountName: json['bankAccountName']?.toString() ?? '',
      bankAccountNumber: json['bankAccountNumber']?.toString() ?? '',
      financeVerifier: _parseBool(json['financeVerifier']),
      servicePointId: json['servicePointId']?.toString(),
      allowAnyLocation: _parseBool(json['allowAnyLocation']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeNumber': employeeNumber,
      'name': name,
      'email': email,
      'department': department,
      'position': position,
      if (departmentId != null) 'departmentId': departmentId,
      if (positionId != null) 'positionId': positionId,
      'status': status,
      'phone': phone,
      'address': address,
      'birthDate': birthDate,
      'joinDate': joinDate,
      'salary': salary,
      'ptkp': ptkp,
      'leaveBalance': leaveBalance,
      'faceEnrolled': faceEnrolled,
      'employmentType': employmentType,
      if (managerId != null) 'managerId': managerId,
      'bankName': bankName,
      'bankAccountName': bankAccountName,
      'bankAccountNumber': bankAccountNumber,
      'financeVerifier': financeVerifier,
      if (servicePointId != null) 'servicePointId': servicePointId,
      'allowAnyLocation': allowAnyLocation,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? employeeNumber,
    String? name,
    String? email,
    String? department,
    String? position,
    String? departmentId,
    String? positionId,
    String? status,
    String? phone,
    String? address,
    String? birthDate,
    String? joinDate,
    int? salary,
    String? ptkp,
    int? leaveBalance,
    bool? faceEnrolled,
    String? employmentType,
    String? managerId,
    String? bankName,
    String? bankAccountName,
    String? bankAccountNumber,
    bool? financeVerifier,
    String? servicePointId,
    bool? allowAnyLocation,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeNumber: employeeNumber ?? this.employeeNumber,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      position: position ?? this.position,
      departmentId: departmentId ?? this.departmentId,
      positionId: positionId ?? this.positionId,
      status: status ?? this.status,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      birthDate: birthDate ?? this.birthDate,
      joinDate: joinDate ?? this.joinDate,
      salary: salary ?? this.salary,
      ptkp: ptkp ?? this.ptkp,
      leaveBalance: leaveBalance ?? this.leaveBalance,
      faceEnrolled: faceEnrolled ?? this.faceEnrolled,
      employmentType: employmentType ?? this.employmentType,
      managerId: managerId ?? this.managerId,
      bankName: bankName ?? this.bankName,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      financeVerifier: financeVerifier ?? this.financeVerifier,
      servicePointId: servicePointId ?? this.servicePointId,
      allowAnyLocation: allowAnyLocation ?? this.allowAnyLocation,
    );
  }
}
