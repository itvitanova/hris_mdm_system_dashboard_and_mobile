import 'package:flutter/material.dart';
import '../../../../../core/api_client.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/widgets/core_widgets.dart';
import '../../../../../core/workspace.dart';
import '../../../../home/presentation/bloc/workspace_bloc.dart';
import '../../../../home/presentation/bloc/workspace_event.dart';
import 'detail_decision_modal.dart';

/// Handles review decision submission (Approve, Revise, Reject)
class DetailDecisionHandler {
  static Future<Json?> handleDecision({
    required BuildContext context,
    required ApiClient api,
    required Json request,
    required String decision,
    required void Function(bool) setBusy,
    required void Function(String?) setError,
  }) async {
    final result = await DetailDecisionModal.show(
      context,
      decision: decision,
      requestTitle: text(request, 'title'),
    );
    if (result == null || !context.mounted) return null;
    if (decision != 'Disetujui' && result.isEmpty) {
      setError('Isi alasan penolakan atau revisi.');
      return null;
    }

    setBusy(true);
    setError(null);
    try {
      await api.post(
        '/requests/${Uri.encodeComponent(text(request, 'id'))}/review',
        {
          'status': decision,
          'note': result,
          'revision': request['revision'] ?? 0,
        },
      );

      final updated = {
        ...request,
        'status': decision,
        'canReview': false,
        'reviewNote': result,
        'revision': (request['revision'] ?? 0) + 1,
      };

      if (sl.isRegistered<WorkspaceBloc>()) {
        sl<WorkspaceBloc>().add(const WorkspaceRefreshRequested());
      }
      if (context.mounted) {
        Navigator.pop(context, true);
        notify(context, 'Keputusan tersimpan.');
      }
      return updated;
    } catch (e) {
      if (context.mounted) setError(e.toString());
      return null;
    } finally {
      if (context.mounted) setBusy(false);
    }
  }
}
