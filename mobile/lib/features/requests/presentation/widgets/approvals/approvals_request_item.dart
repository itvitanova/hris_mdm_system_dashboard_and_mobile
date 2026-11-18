import 'package:flutter/material.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/workspace.dart';
import '../../pages/request_detail_page.dart';
import '../universal_request_card/universal_request_card.dart';

/// Single approval request item card with department enrichment
class ApprovalsRequestItem extends StatelessWidget {
  const ApprovalsRequestItem({
    super.key,
    required this.api,
    required this.r,
    required this.workspace,
    required this.onChanged,
  });

  final ApiClient api;
  final Json r;
  final Workspace? workspace;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> enriched = r;
    final snap = r['snapshot'];
    final snapDept = snap is Map ? snap['department'] : null;
    final hasDept = r['department'] != null || snapDept != null;
    if (!hasDept && workspace != null) {
      final snapEmpId = snap is Map ? snap['employeeId'] : null;
      final empId = r['employeeId'] ?? snapEmpId;
      if (empId != null) {
        final emp = workspace!.rows('employees').firstWhere(
              (e) => e['id'] == empId,
              orElse: () => {},
            );
        final d = emp['department']?.toString().trim();
        if (d != null && d.isNotEmpty && d != '—') {
          enriched = Map<String, dynamic>.from(r);
          enriched['department'] = d;
        }
      }
    }

    return UniversalRequestCard(
      data: UniversalRequestModel.fromMap(enriched),
      showApplicant: true,
      onCardTap: () async {
        final result = await Navigator.of(
          context,
          rootNavigator: true,
        ).push<bool>(
          MaterialPageRoute(
            builder: (_) => RequestDetailScreen(
              api: api,
              request: r,
              own: false,
            ),
          ),
        );
        if (result == true) {
          onChanged();
        }
      },
    );
  }
}
