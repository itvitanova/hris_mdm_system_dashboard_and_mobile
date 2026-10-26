import '../../core/workspace.dart';

/// Describe the saved server stage without changing its approval rules.
String approvalStepSummary(
  Json step, {
  required bool active,
  required String requestStatus,
}) {
  final status = text(step, 'status', 'Menunggu');
  final finance = step['source'] == 'finance';
  if (status == 'Disetujui') {
    return finance
        ? 'Verifikasi finance selesai'
        : 'Persetujuan tahap ini selesai';
  }
  if (status != 'Menunggu') return status;
  if (requestStatus == 'Perlu revisi') {
    return 'Menunggu pengajuan diperbaiki';
  }
  if (requestStatus != 'Menunggu') return 'Tahap ini tidak dilanjutkan';

  final approvers = ((step['approvers'] as List?) ?? [])
      .map((v) => Json.from(v as Map))
      .toList();
  if (approvers.isEmpty) {
    return finance
        ? 'Petugas finance belum tersedia'
        : 'Pemberi persetujuan belum tersedia';
  }
  if (!active) return 'Menunggu tahap sebelumnya';
  if (approvers.length == 1) {
    final name = text(approvers.single, 'name', 'petugas yang ditugaskan');
    return finance ? 'Menunggu verifikasi $name' : 'Menunggu persetujuan $name';
  }

  final people = finance
      ? 'petugas finance'
      : step['source'] == 'manager'
      ? 'atasan'
      : 'pemberi persetujuan';
  final action = finance ? 'verifikasi' : 'persetujuan';
  if (step['mode'] != 'all') {
    return 'Menunggu $action salah satu $people';
  }
  final assigned = approvers.map((v) => v['employeeId']).toSet();
  final approved = ((step['decisions'] as List?) ?? [])
      .whereType<Map>()
      .where(
        (v) =>
            v['decision'] == 'Disetujui' && assigned.contains(v['employeeId']),
      )
      .map((v) => v['employeeId'])
      .toSet()
      .length;
  return 'Menunggu $action seluruh $people ($approved/${approvers.length})';
}
