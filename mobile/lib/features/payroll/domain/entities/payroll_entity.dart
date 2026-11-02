import 'package:equatable/equatable.dart';

class PayrollEntity extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final String department;
  final String position;
  final String companyName;
  final String companyAddress;
  final String companyLogo;
  final String period;
  final int baseSalary;
  final int allowance;
  final int bonus;
  final int grossSalary;
  final String ptkp;
  final String taxCategory;
  final int taxRateBps;
  final int pph21;
  final String taxMode;
  final int? manualPph21;
  final String taxNote;
  final bool taxReady;
  final bool lastTaxPeriod;
  final int bpjsHealth;
  final int jht;
  final int jp;
  final String finalizedAt;
  final String finalizedBy;
  final int overtime;
  final int reimbursement;
  final int deductions;
  final int netSalary;
  final String status;
  final int version;
  final int revision;

  const PayrollEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.position,
    required this.companyName,
    required this.companyAddress,
    required this.companyLogo,
    required this.period,
    required this.baseSalary,
    required this.allowance,
    required this.bonus,
    required this.grossSalary,
    required this.ptkp,
    required this.taxCategory,
    required this.taxRateBps,
    required this.pph21,
    required this.taxMode,
    this.manualPph21,
    required this.taxNote,
    required this.taxReady,
    required this.lastTaxPeriod,
    required this.bpjsHealth,
    required this.jht,
    required this.jp,
    required this.finalizedAt,
    required this.finalizedBy,
    required this.overtime,
    required this.reimbursement,
    required this.deductions,
    required this.netSalary,
    required this.status,
    required this.version,
    required this.revision,
  });

  @override
  List<Object?> get props => [
    id,
    employeeId,
    employeeName,
    department,
    position,
    companyName,
    companyAddress,
    companyLogo,
    period,
    baseSalary,
    allowance,
    bonus,
    grossSalary,
    ptkp,
    taxCategory,
    taxRateBps,
    pph21,
    taxMode,
    manualPph21,
    taxNote,
    taxReady,
    lastTaxPeriod,
    bpjsHealth,
    jht,
    jp,
    finalizedAt,
    finalizedBy,
    overtime,
    reimbursement,
    deductions,
    netSalary,
    status,
    version,
    revision,
  ];
}
