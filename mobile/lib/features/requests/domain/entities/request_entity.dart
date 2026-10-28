import 'package:equatable/equatable.dart';

class ExpenseItemEntity extends Equatable {
  final String date;
  final String description;
  final String category;
  final int amount;
  final String? receiptId;

  const ExpenseItemEntity({
    required this.date,
    required this.description,
    required this.category,
    required this.amount,
    this.receiptId,
  });

  @override
  List<Object?> get props => [date, description, category, amount, receiptId];
}

class RequestSnapshotEntity extends Equatable {
  final String employeeId;
  final String name;
  final String department;
  final String position;
  final String phone;
  final String bankName;
  final String bankAccountName;
  final String bankAccountNumber;
  final String submittedAt;
  final String timezone;
  final String templateVersion;

  const RequestSnapshotEntity({
    required this.employeeId,
    required this.name,
    required this.department,
    required this.position,
    required this.phone,
    required this.bankName,
    required this.bankAccountName,
    required this.bankAccountNumber,
    required this.submittedAt,
    required this.timezone,
    required this.templateVersion,
  });

  @override
  List<Object?> get props => [
    employeeId,
    name,
    department,
    position,
    phone,
    bankName,
    bankAccountName,
    bankAccountNumber,
    submittedAt,
    timezone,
    templateVersion,
  ];
}

class ApproverEntity extends Equatable {
  final String employeeId;
  final String name;

  const ApproverEntity({
    required this.employeeId,
    required this.name,
  });

  @override
  List<Object?> get props => [employeeId, name];
}

class ApprovalEventEntity extends Equatable {
  final int revision;
  final int step;
  final String employeeId;
  final String name;
  final String decision;
  final String note;
  final String at;

  const ApprovalEventEntity({
    required this.revision,
    required this.step,
    required this.employeeId,
    required this.name,
    required this.decision,
    required this.note,
    required this.at,
  });

  @override
  List<Object?> get props => [
    revision,
    step,
    employeeId,
    name,
    decision,
    note,
    at,
  ];
}

class ApprovalStepEntity extends Equatable {
  final String name;
  final String source;
  final String mode;
  final String status;
  final List<ApproverEntity> approvers;
  final List<ApprovalEventEntity> decisions;

  const ApprovalStepEntity({
    required this.name,
    required this.source,
    required this.mode,
    required this.status,
    required this.approvers,
    required this.decisions,
  });

  @override
  List<Object?> get props => [name, source, mode, status, approvers, decisions];
}

class RequestEntity extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final String kind;
  final String title;
  final String description;
  final int amount;
  final String startDate;
  final String endDate;
  final double hours;
  final int days;
  final String status;
  final String createdAt;
  final String reviewedBy;
  final String reviewNote;
  final bool unread;
  final String updateToken;
  final String pendingWith;
  final int version;
  final int revision;
  final int currentStep;
  final bool canReview;
  final bool canDownload;
  final String? finalizedAt;
  final List<ExpenseItemEntity> items;
  final RequestSnapshotEntity? snapshot;
  final List<ApprovalStepEntity> steps;
  final List<ApprovalEventEntity> history;

  const RequestEntity({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.kind,
    required this.title,
    required this.description,
    required this.amount,
    required this.startDate,
    required this.endDate,
    required this.hours,
    required this.days,
    required this.status,
    required this.createdAt,
    required this.reviewedBy,
    required this.reviewNote,
    required this.unread,
    required this.updateToken,
    required this.pendingWith,
    required this.version,
    required this.revision,
    required this.currentStep,
    required this.canReview,
    required this.canDownload,
    this.finalizedAt,
    required this.items,
    this.snapshot,
    required this.steps,
    required this.history,
  });

  @override
  List<Object?> get props => [
    id,
    employeeId,
    employeeName,
    kind,
    title,
    description,
    amount,
    startDate,
    endDate,
    hours,
    days,
    status,
    createdAt,
    reviewedBy,
    reviewNote,
    unread,
    updateToken,
    pendingWith,
    version,
    revision,
    currentStep,
    canReview,
    canDownload,
    finalizedAt,
    items,
    snapshot,
    steps,
    history,
  ];
}
