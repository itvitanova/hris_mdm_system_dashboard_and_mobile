import '../../domain/entities/request_entity.dart';

int _parseInt(dynamic value, [int defaultValue = 0]) {
  if (value == null) return defaultValue;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString()) ?? defaultValue;
}

double _parseDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString()) ?? defaultValue;
}

bool _parseBool(dynamic value, [bool defaultValue = false]) {
  if (value == null) return defaultValue;
  if (value is bool) return value;
  if (value is num) return value != 0;
  return value.toString().toLowerCase() == 'true';
}

class ExpenseItemModel extends ExpenseItemEntity {
  const ExpenseItemModel({
    required super.date,
    required super.description,
    required super.category,
    required super.amount,
    super.receiptId,
  });

  factory ExpenseItemModel.fromJson(Map<String, dynamic> json) {
    return ExpenseItemModel(
      date: json['date']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      amount: _parseInt(json['amount']),
      receiptId: json['receiptId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'description': description,
      'category': category,
      'amount': amount,
      if (receiptId != null) 'receiptId': receiptId,
    };
  }

  ExpenseItemModel copyWith({
    String? date,
    String? description,
    String? category,
    int? amount,
    String? receiptId,
  }) {
    return ExpenseItemModel(
      date: date ?? this.date,
      description: description ?? this.description,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      receiptId: receiptId ?? this.receiptId,
    );
  }
}

class RequestSnapshotModel extends RequestSnapshotEntity {
  const RequestSnapshotModel({
    required super.employeeId,
    required super.name,
    required super.department,
    required super.position,
    required super.phone,
    required super.bankName,
    required super.bankAccountName,
    required super.bankAccountNumber,
    required super.submittedAt,
    required super.timezone,
    required super.templateVersion,
  });

  factory RequestSnapshotModel.fromJson(Map<String, dynamic> json) {
    return RequestSnapshotModel(
      employeeId: json['employeeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      department: json['department']?.toString() ?? '',
      position: json['position']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? '',
      bankAccountName: json['bankAccountName']?.toString() ?? '',
      bankAccountNumber: json['bankAccountNumber']?.toString() ?? '',
      submittedAt: json['submittedAt']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      templateVersion: json['templateVersion']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
      'department': department,
      'position': position,
      'phone': phone,
      'bankName': bankName,
      'bankAccountName': bankAccountName,
      'bankAccountNumber': bankAccountNumber,
      'submittedAt': submittedAt,
      'timezone': timezone,
      'templateVersion': templateVersion,
    };
  }

  RequestSnapshotModel copyWith({
    String? employeeId,
    String? name,
    String? department,
    String? position,
    String? phone,
    String? bankName,
    String? bankAccountName,
    String? bankAccountNumber,
    String? submittedAt,
    String? timezone,
    String? templateVersion,
  }) {
    return RequestSnapshotModel(
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      department: department ?? this.department,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      bankName: bankName ?? this.bankName,
      bankAccountName: bankAccountName ?? this.bankAccountName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      submittedAt: submittedAt ?? this.submittedAt,
      timezone: timezone ?? this.timezone,
      templateVersion: templateVersion ?? this.templateVersion,
    );
  }
}

class ApproverModel extends ApproverEntity {
  const ApproverModel({
    required super.employeeId,
    required super.name,
  });

  factory ApproverModel.fromJson(Map<String, dynamic> json) {
    return ApproverModel(
      employeeId: json['employeeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'name': name,
    };
  }

  ApproverModel copyWith({
    String? employeeId,
    String? name,
  }) {
    return ApproverModel(
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
    );
  }
}

class ApprovalEventModel extends ApprovalEventEntity {
  const ApprovalEventModel({
    required super.revision,
    required super.step,
    required super.employeeId,
    required super.name,
    required super.decision,
    required super.note,
    required super.at,
  });

  factory ApprovalEventModel.fromJson(Map<String, dynamic> json) {
    return ApprovalEventModel(
      revision: _parseInt(json['revision']),
      step: _parseInt(json['step']),
      employeeId: json['employeeId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      decision: json['decision']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      at: json['at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revision': revision,
      'step': step,
      'employeeId': employeeId,
      'name': name,
      'decision': decision,
      'note': note,
      'at': at,
    };
  }

  ApprovalEventModel copyWith({
    int? revision,
    int? step,
    String? employeeId,
    String? name,
    String? decision,
    String? note,
    String? at,
  }) {
    return ApprovalEventModel(
      revision: revision ?? this.revision,
      step: step ?? this.step,
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      decision: decision ?? this.decision,
      note: note ?? this.note,
      at: at ?? this.at,
    );
  }
}

class ApprovalStepModel extends ApprovalStepEntity {
  const ApprovalStepModel({
    required super.name,
    required super.source,
    required super.mode,
    required super.status,
    required super.approvers,
    required super.decisions,
  });

  factory ApprovalStepModel.fromJson(Map<String, dynamic> json) {
    return ApprovalStepModel(
      name: json['name']?.toString() ?? '',
      source: json['source']?.toString() ?? '',
      mode: json['mode']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      approvers: (json['approvers'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ApproverModel.fromJson)
              .toList() ??
          const [],
      decisions: (json['decisions'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ApprovalEventModel.fromJson)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'source': source,
      'mode': mode,
      'status': status,
      'approvers': approvers
          .map((a) => a is ApproverModel
              ? a.toJson()
              : {'employeeId': a.employeeId, 'name': a.name})
          .toList(),
      'decisions': decisions
          .map((d) => d is ApprovalEventModel
              ? d.toJson()
              : {
                  'revision': d.revision,
                  'step': d.step,
                  'employeeId': d.employeeId,
                  'name': d.name,
                  'decision': d.decision,
                  'note': d.note,
                  'at': d.at,
                })
          .toList(),
    };
  }

  ApprovalStepModel copyWith({
    String? name,
    String? source,
    String? mode,
    String? status,
    List<ApproverEntity>? approvers,
    List<ApprovalEventEntity>? decisions,
  }) {
    return ApprovalStepModel(
      name: name ?? this.name,
      source: source ?? this.source,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      approvers: approvers ?? this.approvers,
      decisions: decisions ?? this.decisions,
    );
  }
}

class RequestModel extends RequestEntity {
  const RequestModel({
    required super.id,
    required super.employeeId,
    required super.employeeName,
    required super.kind,
    required super.title,
    required super.description,
    required super.amount,
    required super.startDate,
    required super.endDate,
    required super.hours,
    required super.days,
    required super.status,
    required super.createdAt,
    required super.reviewedBy,
    required super.reviewNote,
    required super.unread,
    required super.updateToken,
    required super.pendingWith,
    required super.version,
    required super.revision,
    required super.currentStep,
    required super.canReview,
    required super.canDownload,
    super.finalizedAt,
    required super.items,
    super.snapshot,
    required super.steps,
    required super.history,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      amount: _parseInt(json['amount']),
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
      hours: _parseDouble(json['hours']),
      days: _parseInt(json['days']),
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      reviewedBy: json['reviewedBy']?.toString() ?? '',
      reviewNote: json['reviewNote']?.toString() ?? '',
      unread: _parseBool(json['unread']),
      updateToken: json['updateToken']?.toString() ?? '',
      pendingWith: json['pendingWith']?.toString() ?? '',
      version: _parseInt(json['version']),
      revision: _parseInt(json['revision']),
      currentStep: _parseInt(json['currentStep']),
      canReview: _parseBool(json['canReview']),
      canDownload: _parseBool(json['canDownload']),
      finalizedAt: json['finalizedAt']?.toString(),
      items: (json['items'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ExpenseItemModel.fromJson)
              .toList() ??
          const [],
      snapshot: json['snapshot'] is Map<String, dynamic>
          ? RequestSnapshotModel.fromJson(
              json['snapshot'] as Map<String, dynamic>,
            )
          : null,
      steps: (json['steps'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ApprovalStepModel.fromJson)
              .toList() ??
          const [],
      history: (json['history'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(ApprovalEventModel.fromJson)
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'kind': kind,
      'title': title,
      'description': description,
      'amount': amount,
      'startDate': startDate,
      'endDate': endDate,
      'hours': hours,
      'days': days,
      'status': status,
      'createdAt': createdAt,
      'reviewedBy': reviewedBy,
      'reviewNote': reviewNote,
      'unread': unread,
      'updateToken': updateToken,
      'pendingWith': pendingWith,
      'version': version,
      'revision': revision,
      'currentStep': currentStep,
      'canReview': canReview,
      'canDownload': canDownload,
      if (finalizedAt != null) 'finalizedAt': finalizedAt,
      'items': items
          .map((i) => i is ExpenseItemModel
              ? i.toJson()
              : {
                  'date': i.date,
                  'description': i.description,
                  'category': i.category,
                  'amount': i.amount,
                  if (i.receiptId != null) 'receiptId': i.receiptId,
                })
          .toList(),
      if (snapshot != null)
        'snapshot': snapshot is RequestSnapshotModel
            ? (snapshot as RequestSnapshotModel).toJson()
            : {
                'employeeId': snapshot!.employeeId,
                'name': snapshot!.name,
                'department': snapshot!.department,
                'position': snapshot!.position,
                'phone': snapshot!.phone,
                'bankName': snapshot!.bankName,
                'bankAccountName': snapshot!.bankAccountName,
                'bankAccountNumber': snapshot!.bankAccountNumber,
                'submittedAt': snapshot!.submittedAt,
                'timezone': snapshot!.timezone,
                'templateVersion': snapshot!.templateVersion,
              },
      'steps': steps
          .map((s) => s is ApprovalStepModel
              ? s.toJson()
              : {
                  'name': s.name,
                  'source': s.source,
                  'mode': s.mode,
                  'status': s.status,
                  'approvers': s.approvers
                      .map((a) => {'employeeId': a.employeeId, 'name': a.name})
                      .toList(),
                  'decisions': s.decisions
                      .map((d) => {
                            'revision': d.revision,
                            'step': d.step,
                            'employeeId': d.employeeId,
                            'name': d.name,
                            'decision': d.decision,
                            'note': d.note,
                            'at': d.at,
                          })
                      .toList(),
                })
          .toList(),
      'history': history
          .map((h) => h is ApprovalEventModel
              ? h.toJson()
              : {
                  'revision': h.revision,
                  'step': h.step,
                  'employeeId': h.employeeId,
                  'name': h.name,
                  'decision': h.decision,
                  'note': h.note,
                  'at': h.at,
                })
          .toList(),
    };
  }

  RequestModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    String? kind,
    String? title,
    String? description,
    int? amount,
    String? startDate,
    String? endDate,
    double? hours,
    int? days,
    String? status,
    String? createdAt,
    String? reviewedBy,
    String? reviewNote,
    bool? unread,
    String? updateToken,
    String? pendingWith,
    int? version,
    int? revision,
    int? currentStep,
    bool? canReview,
    bool? canDownload,
    String? finalizedAt,
    List<ExpenseItemEntity>? items,
    RequestSnapshotEntity? snapshot,
    List<ApprovalStepEntity>? steps,
    List<ApprovalEventEntity>? history,
  }) {
    return RequestModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      hours: hours ?? this.hours,
      days: days ?? this.days,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      reviewedBy: reviewedBy ?? this.reviewedBy,
      reviewNote: reviewNote ?? this.reviewNote,
      unread: unread ?? this.unread,
      updateToken: updateToken ?? this.updateToken,
      pendingWith: pendingWith ?? this.pendingWith,
      version: version ?? this.version,
      revision: revision ?? this.revision,
      currentStep: currentStep ?? this.currentStep,
      canReview: canReview ?? this.canReview,
      canDownload: canDownload ?? this.canDownload,
      finalizedAt: finalizedAt ?? this.finalizedAt,
      items: items ?? this.items,
      snapshot: snapshot ?? this.snapshot,
      steps: steps ?? this.steps,
      history: history ?? this.history,
    );
  }
}
