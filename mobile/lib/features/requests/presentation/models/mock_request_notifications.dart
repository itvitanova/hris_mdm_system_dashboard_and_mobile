import '../../domain/entities/submission_kind.dart';
import '../../domain/entities/submission_status.dart';

import '../../domain/entities/request_notification_item.dart';
export '../../domain/entities/request_notification_item.dart';

/// Mock data realistis notifikasi pengajuan PeopleOS
List<RequestNotificationItem> getMockRequestNotifications() {
  return [
    RequestNotificationItem(
      id: 'notif-mock-1',
      requestId: 'REQ-CUTI-001',
      kind: SubmissionKind.cuti,
      requestTitle: 'Cuti Tahunan (2 Hari)',
      status: SubmissionStatus.disetujui,
      headline: 'Pengajuan Cuti Disetujui',
      message:
          'Aries Munandar telah menyetujui permohonan cuti tahunan Anda untuk tanggal 2–3 November 2026.',
      timeAgo: '15 mnt lalu',
      isUnread: true,
      reviewerName: 'Aries Munandar',
      rawRequest: {
        'id': 'REQ-CUTI-001',
        'title': 'Cuti Tahunan (2 Hari)',
        'kind': 'Cuti',
        'status': 'Disetujui',
        'startDate': '2026-11-02',
        'endDate': '2026-11-03',
        'days': 2,
        'leaveBalance': 10,
        'employeeName': 'Nadia Putri',
        'reviewedBy': 'Aries Munandar',
        'unread': true,
      },
    ),
    RequestNotificationItem(
      id: 'notif-mock-2',
      requestId: 'REQ-REIM-002',
      kind: SubmissionKind.reimbursement,
      requestTitle: 'Biaya Transport & Akomodasi Klien',
      status: SubmissionStatus.perluRevisi,
      headline: 'Perlu Revisi Dokumen Klaim',
      message:
          'Catatan peninjau: "Mohon lampirkan struk kasir asli dengan cap toko dan rincian menu lengkap."',
      timeAgo: '1 jam lalu',
      isUnread: true,
      reviewerName: 'Alicia',
      reviewNote:
          'Mohon lampirkan struk kasir asli dengan cap toko dan rincian menu lengkap.',
      rawRequest: {
        'id': 'REQ-REIM-002',
        'title': 'Biaya Transport & Akomodasi Klien',
        'kind': 'Reimbursement',
        'status': 'Perlu revisi',
        'startDate': '2026-10-28',
        'endDate': '2026-10-28',
        'amount': 850000,
        'employeeName': 'Nadia Putri',
        'reviewedBy': 'Alicia',
        'reviewNote':
            'Mohon lampirkan struk kasir asli dengan cap toko dan rincian menu lengkap.',
        'unread': true,
      },
    ),
    RequestNotificationItem(
      id: 'notif-mock-3',
      requestId: 'REQ-PC-003',
      kind: SubmissionKind.pettyCash,
      requestTitle: 'Konsumsi Rapat Bulanan Divisi',
      status: SubmissionStatus.menunggu,
      headline: 'Menunggu Verifikasi Finance',
      message:
          'Pengajuan kas kecil Rp 375.000 telah disetujui atasan dan kini dalam antrean transfer tim Finance.',
      timeAgo: '3 jam lalu',
      isUnread: false,
      reviewerName: 'Alicia (Finance)',
      rawRequest: {
        'id': 'REQ-PC-003',
        'title': 'Konsumsi Rapat Bulanan Divisi',
        'kind': 'Petty Cash',
        'status': 'Menunggu',
        'startDate': '2026-10-25',
        'endDate': '2026-10-25',
        'amount': 375000,
        'employeeName': 'Nadia Putri',
        'reviewedBy': 'Alicia',
        'unread': false,
      },
    ),
    RequestNotificationItem(
      id: 'notif-mock-4',
      requestId: 'REQ-LMB-004',
      kind: SubmissionKind.lembur,
      requestTitle: 'Lembur Maintenance & Backup Server',
      status: SubmissionStatus.disetujui,
      headline: 'Tugas Lembur Disetujui',
      message:
          'Kompensasi lembur 4 jam telah disetujui oleh Aries Munandar dan tercatat di rekapitulasi kehadiran.',
      timeAgo: 'Kemarin',
      isUnread: false,
      reviewerName: 'Aries Munandar',
      rawRequest: {
        'id': 'REQ-LMB-004',
        'title': 'Lembur Maintenance & Backup Server',
        'kind': 'Lembur',
        'status': 'Disetujui',
        'startDate': '2026-10-20',
        'endDate': '2026-10-20',
        'hours': 4,
        'employeeName': 'Nadia Putri',
        'reviewedBy': 'Aries Munandar',
        'unread': false,
      },
    ),
    RequestNotificationItem(
      id: 'notif-mock-5',
      requestId: 'REQ-GA-005',
      kind: SubmissionKind.generalAffair,
      requestTitle: 'Pengadaan Kursi Kerja Ergonomis',
      status: SubmissionStatus.disetujui,
      headline: 'Permohonan Fasilitas Disetujui',
      message:
          'Tim General Affair telah memproses pengadaan fasilitas kantor dan barang siap dikirim ke meja Anda.',
      timeAgo: '2 hari lalu',
      isUnread: false,
      reviewerName: 'Budi Santoso (GA)',
      rawRequest: {
        'id': 'REQ-GA-005',
        'title': 'Pengadaan Kursi Kerja Ergonomis',
        'kind': 'General Affair',
        'status': 'Disetujui',
        'startDate': '2026-10-18',
        'endDate': '2026-10-18',
        'amount': 1250000,
        'employeeName': 'Nadia Putri',
        'reviewedBy': 'Budi Santoso',
        'unread': false,
      },
    ),
  ];
}
