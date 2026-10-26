import 'package:flutter_test/flutter_test.dart';
import 'package:mdm_hris/core/workspace.dart';
import 'package:mdm_hris/features/requests/approval_step_summary.dart';

void main() {
  Json stage({
    String source = 'manager',
    String mode = 'all',
    int people = 1,
  }) => {
    'source': source,
    'mode': mode,
    'status': 'Menunggu',
    'approvers': [
      for (var i = 0; i < people; i++)
        {'employeeId': 'EMP-$i', 'name': i == 0 ? 'Budi' : 'Sari'},
    ],
    'decisions': [],
  };
  String summary(Json step, {bool active = true, String status = 'Menunggu'}) =>
      approvalStepSummary(step, active: active, requestStatus: status);

  test('one assigned person is named without exposing any/all rules', () {
    expect(summary(stage()), 'Menunggu persetujuan Budi');
    expect(
      summary(stage(source: 'finance', mode: 'any')),
      'Menunggu verifikasi Budi',
    );
  });
  test('all counts only unique approvals from the assigned people', () {
    final step = stage(people: 2);
    expect(summary(step), 'Menunggu persetujuan seluruh atasan (0/2)');
    step['decisions'] = [
      {'employeeId': 'EMP-0', 'decision': 'Disetujui'},
      {'employeeId': 'EMP-0', 'decision': 'Disetujui'},
      {'employeeId': 'OTHER', 'decision': 'Disetujui'},
      {'employeeId': 'EMP-1', 'decision': 'Perlu revisi'},
    ];
    expect(summary(step), 'Menunggu persetujuan seluruh atasan (1/2)');
  });
  test('several finance people require one assigned verifier for any mode', () {
    expect(
      summary(stage(source: 'finance', mode: 'any', people: 2)),
      'Menunggu verifikasi salah satu petugas finance',
    );
    expect(
      summary(stage(source: 'employees', mode: 'any', people: 2)),
      'Menunggu persetujuan salah satu pemberi persetujuan',
    );
  });
  test('future, stopped, and revision stages never ask for action now', () {
    expect(summary(stage(), active: false), 'Menunggu tahap sebelumnya');
    expect(summary(stage(), status: 'Ditolak'), 'Tahap ini tidak dilanjutkan');
    expect(
      summary(stage(), status: 'Perlu revisi'),
      'Menunggu pengajuan diperbaiki',
    );
  });
  test('completed and negative decisions retain their actual outcome', () {
    for (final status in ['Ditolak', 'Perlu revisi']) {
      expect(summary({...stage(), 'status': status}, status: status), status);
    }
    expect(
      summary({...stage(), 'status': 'Disetujui'}, status: 'Disetujui'),
      'Persetujuan tahap ini selesai',
    );
    expect(
      summary({...stage(source: 'finance'), 'status': 'Disetujui'}),
      'Verifikasi finance selesai',
    );
  });
  test('missing assignees do not produce an empty wait message', () {
    expect(summary(stage(people: 0)), 'Pemberi persetujuan belum tersedia');
    expect(
      summary(stage(source: 'finance', people: 0)),
      'Petugas finance belum tersedia',
    );
  });
}
