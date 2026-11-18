import '../../../../../core/workspace.dart';

/// Helper to filter workspace requests for approvals screen
class ApprovalsFilterHelper {
  static List<Json> filterRows({
    required Workspace? workspace,
    required String? actorId,
    required bool history,
    required String query,
  }) {
    return workspace
            ?.rows('requests')
            .where(
              (r) =>
                  r['employeeId'] != actorId &&
                  (history
                      ? ((r['steps'] as List?) ?? []).any(
                          (s) => ((s['decisions'] as List?) ?? []).any(
                            (d) => d['employeeId'] == actorId,
                          ),
                        )
                      : r['canReview'] == true),
            )
            .where(
              (r) =>
                  '${text(r, 'employeeName')} ${text(r, 'title')} ${text(r, 'kind')}'
                      .toLowerCase()
                      .contains(query.toLowerCase()),
            )
            .toList() ??
        <Json>[];
  }
}
