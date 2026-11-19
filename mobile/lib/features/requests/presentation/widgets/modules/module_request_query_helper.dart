import '../universal_request_card/universal_request_card.dart';

/// Helper for normalizing and filtering requests for a dedicated module
class ModuleRequestQueryHelper {
  const ModuleRequestQueryHelper._();

  static List<UniversalRequestModel> getAllKindRequests(
    List<Map<String, dynamic>> rows,
    SubmissionKind kind,
  ) {
    final List<UniversalRequestModel> items = [];

    for (final r in rows) {
      final normalized = Map<String, dynamic>.from(r);
      if (normalized['kind'] == null && normalized['type'] != null) {
        normalized['kind'] = normalized['type'];
      }
      final rawAmount =
          normalized['amount'] ?? normalized['nominal'] ?? normalized['total'];
      if (rawAmount is String) {
        final parsed = int.tryParse(rawAmount);
        if (parsed != null) normalized['amount'] = parsed;
      }
      final rawHours = normalized['hours'] ?? normalized['durasi'];
      if (rawHours is String) {
        final parsed = int.tryParse(rawHours);
        if (parsed != null) normalized['hours'] = parsed;
      }
      final model = UniversalRequestModel.fromMap(normalized);
      if (model.kind == kind) items.add(model);
    }

    return items;
  }

  static List<UniversalRequestModel> filterByStatus(
    List<UniversalRequestModel> all,
    SubmissionStatus? status,
  ) {
    if (status == null) return all;
    return all.where((it) {
      if (status == SubmissionStatus.menunggu) {
        return it.status == SubmissionStatus.menunggu ||
            it.status == SubmissionStatus.menungguSinkronisasi;
      }
      return it.status == status;
    }).toList();
  }
}

class ModuleRequestCounts {
  final int approved, pending, rejected, revision, unread;
  const ModuleRequestCounts({
    required this.approved,
    required this.pending,
    required this.rejected,
    required this.revision,
    required this.unread,
  });

  factory ModuleRequestCounts.calculate(
    List<Map<String, dynamic>> rows,
    List<UniversalRequestModel> all,
  ) {
    return ModuleRequestCounts(
      approved: all.where((r) => r.status == SubmissionStatus.disetujui).length,
      pending: all.where((r) =>
          r.status == SubmissionStatus.menunggu ||
          r.status == SubmissionStatus.menungguSinkronisasi).length,
      rejected: all.where((r) => r.status == SubmissionStatus.ditolak).length,
      revision: all.where((r) => r.status == SubmissionStatus.perluRevisi).length,
      unread: rows.where((r) => r['unread'] == true).length,
    );
  }
}
