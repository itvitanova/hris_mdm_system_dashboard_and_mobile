/// Status alur persetujuan pengajuan
enum SubmissionStatus {
  menunggu,
  disetujui,
  perluRevisi,
  ditolak;

  static SubmissionStatus fromString(String value) {
    switch (value.toLowerCase().replaceAll(' ', '')) {
      case 'disetujui':
      case 'approved':
        return SubmissionStatus.disetujui;
      case 'perlurevisi':
      case 'revisi':
      case 'revision':
        return SubmissionStatus.perluRevisi;
      case 'ditolak':
      case 'rejected':
        return SubmissionStatus.ditolak;
      case 'menunggu':
      case 'pending':
      default:
        return SubmissionStatus.menunggu;
    }
  }

  String get displayName {
    switch (this) {
      case SubmissionStatus.menunggu:
        return 'Menunggu';
      case SubmissionStatus.disetujui:
        return 'Disetujui';
      case SubmissionStatus.perluRevisi:
        return 'Perlu Revisi';
      case SubmissionStatus.ditolak:
        return 'Ditolak';
    }
  }
}
