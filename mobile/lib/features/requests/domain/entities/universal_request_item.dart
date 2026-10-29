import 'submission_kind.dart';
import 'submission_status.dart';

/// Model data pengajuan universal
class UniversalRequestModel {
  final String id;
  final SubmissionKind kind;
  final String title;
  final String? description;
  final SubmissionStatus status;

  // Tanggal & Durasi/Nominal
  final DateTime startDate;
  final DateTime? endDate;
  final int? days; // Untuk Cuti
  final int? hours; // Untuk Lembur
  final int? amount; // Untuk Reimbursement, Petty Cash, GA

  // Karyawan & Approval Data
  final String employeeName;
  final String? pendingWith; // Misal: "Menunggu persetujuan · Aries Munandar"
  final String? reviewedBy; // Misal: "Alicia"
  final String? reviewNote; // Catatan jika "Perlu revisi"

  // Data Spesifik
  final int? transactionCount;
  final String? bankAccount;
  final int? leaveBalance;

  const UniversalRequestModel({
    required this.id,
    required this.kind,
    required this.title,
    this.description,
    required this.status,
    required this.startDate,
    this.endDate,
    this.days,
    this.hours,
    this.amount,
    required this.employeeName,
    this.pendingWith,
    this.reviewedBy,
    this.reviewNote,
    this.transactionCount,
    this.bankAccount,
    this.leaveBalance,
  });

  factory UniversalRequestModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) return value;
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) return parsed;
      }
      return DateTime.now();
    }

    DateTime? parseNullableDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    final kindStr = map['kind']?.toString() ?? 'Cuti';
    final statusStr = map['status']?.toString() ?? 'Menunggu';

    return UniversalRequestModel(
      id: map['id']?.toString() ?? 'REQ-${DateTime.now().millisecondsSinceEpoch}',
      kind: SubmissionKind.fromString(kindStr),
      title: map['title']?.toString() ?? 'Pengajuan',
      description: map['description']?.toString(),
      status: SubmissionStatus.fromString(statusStr),
      startDate: parseDate(map['startDate']),
      endDate: parseNullableDate(map['endDate']),
      days: (map['days'] as num?)?.toInt(),
      hours: (map['hours'] as num?)?.toInt(),
      amount: (map['amount'] as num?)?.toInt(),
      employeeName: map['employeeName']?.toString() ?? 'Karyawan',
      pendingWith: map['pendingWith']?.toString(),
      reviewedBy: map['reviewedBy']?.toString(),
      reviewNote: map['reviewNote']?.toString(),
      transactionCount: (map['transactionCount'] as num?)?.toInt() ??
          (map['items'] is List ? (map['items'] as List).length : null),
      bankAccount: map['bankAccount']?.toString(),
      leaveBalance: (map['leaveBalance'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'kind': kind.displayName,
      'title': title,
      'description': description ?? '',
      'status': status.displayName,
      'startDate': startDate.toIso8601String().substring(0, 10),
      if (endDate != null)
        'endDate': endDate!.toIso8601String().substring(0, 10),
      if (days != null) 'days': days,
      if (hours != null) 'hours': hours,
      if (amount != null) 'amount': amount,
      'employeeName': employeeName,
      if (pendingWith != null) 'pendingWith': pendingWith,
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (reviewNote != null) 'reviewNote': reviewNote,
      if (leaveBalance != null) 'leaveBalance': leaveBalance,
      if (transactionCount != null) 'transactionCount': transactionCount,
      'unread': false,
    };
  }
}

typedef UniversalRequestItem = UniversalRequestModel;
