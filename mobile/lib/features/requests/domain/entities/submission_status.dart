import '../../../root/presentation/widgets/language_swap_button.dart';

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

  String getLabel([AppLanguage language = AppLanguage.id]) {
    if (language == AppLanguage.en) {
      switch (this) {
        case SubmissionStatus.menunggu:
          return 'Pending';
        case SubmissionStatus.disetujui:
          return 'Approved';
        case SubmissionStatus.perluRevisi:
          return 'Needs Revision';
        case SubmissionStatus.ditolak:
          return 'Rejected';
      }
    }
    return displayName;
  }
}
