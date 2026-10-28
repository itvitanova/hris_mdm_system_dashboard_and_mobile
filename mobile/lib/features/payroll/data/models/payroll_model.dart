import '../../domain/entities/payroll_entity.dart';

int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? defaultValue;
}

int? _parseNullableInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool _parseBool(dynamic value, [bool defaultValue = false]) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value.toString().toLowerCase() == 'true';
}

class PayrollModel extends PayrollEntity {
  const PayrollModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.department,
    required super.position,
    required super.companyName,
    required super.companyAddress,
    required super.companyLogo,
    required super.period,
    required super.baseSalary,
    required super.allowance,
    required super.bonus,
    required super.grossSalary,
    required super.ptkp,
    required super.taxCategory,
    required super.taxRateBps,
    required super.pph21,
    required super.taxMode,
    super.manualPph21,
    required super.taxNote,
    required super.taxReady,
    required super.lastTaxPeriod,
    required super.bpjsHealth,
    required super.jht,
    required super.jp,
    required super.finalizedAt,
    required super.finalizedBy,
    required super.overtime,
    required super.reimbursement,
    required super.deductions,
    required super.netSalary,
    required super.status,
    required super.version,
    required super.revision,
  });

  factory PayrollModel.fromJson(Map<String, dynamic> json) {
    return PayrollModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      companyName: json['companyName']?.toString() ?? '',
      companyAddress: json['companyAddress']?.toString() ?? '',
      companyLogo: json['companyLogo']?.toString() ?? '',
      period: json['period']?.toString() ?? '',
      baseSalary: _parseInt(json['baseSalary']),
      allowance: _parseInt(json['allowance']),
      bonus: _parseInt(json['bonus']),
      grossSalary: _parseInt(json['grossSalary']),
      ptkp: json['ptkp']?.toString() ?? '',
      taxCategory: json['taxCategory']?.toString() ?? '',
      taxRateBps: _parseInt(json['taxRateBps']),
      pph21: _parseInt(json['pph21']),
      taxMode: json['taxMode']?.toString() ?? '',
      manualPph21: _parseNullableInt(json['manualPph21']),
      taxNote: json['taxNote']?.toString() ?? '',
      taxReady: _parseBool(json['taxReady']),
      lastTaxPeriod: _parseBool(json['lastTaxPeriod']),
      bpjsHealth: _parseInt(json['bpjsHealth']),
      jht: _parseInt(json['jht']),
      jp: _parseInt(json['jp']),
      finalizedAt: json['finalizedAt']?.toString() ?? '',
      finalizedBy: json['finalizedBy']?.toString() ?? '',
      overtime: _parseInt(json['overtime']),
      reimbursement: _parseInt(json['reimbursement']),
      deductions: _parseInt(json['deductions']),
      netSalary: _parseInt(json['netSalary']),
      status: json['status']?.toString() ?? '',
      version: _parseInt(json['version']),
      revision: _parseInt(json['revision']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'department': department,
      'position': position,
      'companyName': companyName,
      'companyAddress': companyAddress,
      'companyLogo': companyLogo,
      'period': period,
      'baseSalary': baseSalary,
      'allowance': allowance,
      'bonus': bonus,
      'grossSalary': grossSalary,
      'ptkp': ptkp,
      'taxCategory': taxCategory,
      'taxRateBps': taxRateBps,
      'pph21': pph21,
      'taxMode': taxMode,
      if (manualPph21 != null) 'manualPph21': manualPph21,
      'taxNote': taxNote,
      'taxReady': taxReady,
      'lastTaxPeriod': lastTaxPeriod,
      'bpjsHealth': bpjsHealth,
      'jht': jht,
      'jp': jp,
      'finalizedAt': finalizedAt,
      'finalizedBy': finalizedBy,
      'overtime': overtime,
      'reimbursement': reimbursement,
      'deductions': deductions,
      'netSalary': netSalary,
      'status': status,
      'version': version,
      'revision': revision,
    };
  }

  PayrollModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? department,
    String? position,
    String? companyName,
    String? companyAddress,
    String? companyLogo,
    String? period,
    int? baseSalary,
    int? allowance,
    int? bonus,
    int? grossSalary,
    String? ptkp,
    String? taxCategory,
    int? taxRateBps,
    int? pph21,
    String? taxMode,
    int? manualPph21,
    String? taxNote,
    bool? taxReady,
    bool? lastTaxPeriod,
    int? bpjsHealth,
    int? jht,
    int? jp,
    String? finalizedAt,
    String? finalizedBy,
    int? overtime,
    int? reimbursement,
    int? deductions,
    int? netSalary,
    String? status,
    int? version,
    int? revision,
  }) {
    return PayrollModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      department: department ?? this.department,
      position: position ?? this.position,
      companyName: companyName ?? this.companyName,
      companyAddress: companyAddress ?? this.companyAddress,
      companyLogo: companyLogo ?? this.companyLogo,
      period: period ?? this.period,
      baseSalary: baseSalary ?? this.baseSalary,
      allowance: allowance ?? this.allowance,
      bonus: bonus ?? this.bonus,
      grossSalary: grossSalary ?? this.grossSalary,
      ptkp: ptkp ?? this.ptkp,
      taxCategory: taxCategory ?? this.taxCategory,
      taxRateBps: taxRateBps ?? this.taxRateBps,
      pph21: pph21 ?? this.pph21,
      taxMode: taxMode ?? this.taxMode,
      manualPph21: manualPph21 ?? this.manualPph21,
      taxNote: taxNote ?? this.taxNote,
      taxReady: taxReady ?? this.taxReady,
      lastTaxPeriod: lastTaxPeriod ?? this.lastTaxPeriod,
      bpjsHealth: bpjsHealth ?? this.bpjsHealth,
      jht: jht ?? this.jht,
      jp: jp ?? this.jp,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      finalizedBy: finalizedBy ?? this.finalizedBy,
      overtime: overtime ?? this.overtime,
      reimbursement: reimbursement ?? this.reimbursement,
      deductions: deductions ?? this.deductions,
      netSalary: netSalary ?? this.netSalary,
      status: status ?? this.status,
      version: version ?? this.version,
      revision: revision ?? this.revision,
    );
  }
}
