import '../../../domain/entities/submission_kind.dart';
import '../../../../root/presentation/widgets/language_swap_button.dart';

/// Helper for dedicated module localized titles, subtitles, and hero texts
class ModuleLocalizationHelper {
  const ModuleLocalizationHelper._();

  static String getModuleTitle(
    SubmissionKind kind,
    AppLanguage language,
    String fallbackTitle,
  ) {
    if (language == AppLanguage.en) {
      switch (kind) {
        case SubmissionKind.cuti:
          return 'Leave Request';
        case SubmissionKind.izin:
          return 'Permission Request';
        case SubmissionKind.lembur:
          return 'Overtime Request';
        case SubmissionKind.reimbursement:
          return 'Reimbursement Claim';
        case SubmissionKind.medicalClaim:
          return 'Medical Claim';
        case SubmissionKind.pettyCash:
          return 'Petty Cash Request';
        case SubmissionKind.generalAffair:
          return 'General Affair';
      }
    }
    return fallbackTitle;
  }

  static String getModuleSubtitle(SubmissionKind kind, AppLanguage language) {
    if (language == AppLanguage.en) {
      switch (kind) {
        case SubmissionKind.cuti:
          return 'Manage leave quota & requests';
        case SubmissionKind.izin:
          return 'Sick leave & work dispensation records';
        case SubmissionKind.lembur:
          return 'Task records & overtime compensation';
        case SubmissionKind.reimbursement:
          return 'Operational expenses & claims';
        case SubmissionKind.medicalClaim:
          return 'Outpatient & health expenses claim';
        case SubmissionKind.pettyCash:
          return 'Operational petty cash requests';
        case SubmissionKind.generalAffair:
          return 'Procurement, assets & workplace facilities';
      }
    }
    switch (kind) {
      case SubmissionKind.cuti:
        return 'Kelola kuota & permohonan cuti';
      case SubmissionKind.izin:
        return 'Pencatatan izin sakit & dispensasi kerja';
      case SubmissionKind.lembur:
        return 'Pencatatan tugas & kompensasi lembur';
      case SubmissionKind.reimbursement:
        return 'Klaim biaya operasional & reimburse';
      case SubmissionKind.medicalClaim:
        return 'Penggantian biaya kesehatan & rawat jalan';
      case SubmissionKind.pettyCash:
        return 'Pengajuan & kas kecil operasional';
      case SubmissionKind.generalAffair:
        return 'Pengadaan logistik, aset & sarana';
    }
  }

  static (String badgeText, String headline, String subtitle, String buttonText)
      getHeroTexts(SubmissionKind kind, AppLanguage language) {
    final isEn = language == AppLanguage.en;
    return switch (kind) {
      SubmissionKind.cuti => (
          isEn ? 'Annual Leave Service' : 'Layanan Cuti Tahunan',
          isEn ? 'Need Time Off?' : 'Perlu Cuti Kerja?',
          isEn
              ? 'Apply for annual leave or important personal affairs.'
              : 'Ajukan permohonan cuti tahunan atau urusan penting.',
          isEn ? 'Create Leave Request' : 'Buat Pengajuan Cuti',
        ),
      SubmissionKind.izin => (
          isEn ? 'Permission & Sick Leave' : 'Layanan Izin & Sakit',
          isEn ? 'Need Work Permission?' : 'Perlu Izin Tidak Masuk?',
          isEn
              ? 'Submit sick leave or work dispensation with attachments.'
              : 'Ajukan izin sakit atau dispensasi kerja dengan lampiran dokumen.',
          isEn ? 'Create Permission Request' : 'Buat Pengajuan Izin',
        ),
      SubmissionKind.lembur => (
          isEn ? 'Overtime Service' : 'Layanan Lembur',
          isEn ? 'Assigned Overtime?' : 'Ada Penugasan Lembur?',
          isEn
              ? 'Record overtime tasks for accurate work compensation.'
              : 'Catat tugas lembur untuk kompensasi kerja yang akurat.',
          isEn ? 'Create Overtime Request' : 'Buat Pengajuan Lembur',
        ),
      SubmissionKind.reimbursement => (
          isEn ? 'Operational Expense Claim' : 'Klaim Biaya Operasional',
          isEn ? 'Claim Your Expenses?' : 'Klaim Biaya Pengeluaran?',
          isEn
              ? 'Submit claim for transport, meals, and business trips.'
              : 'Ajukan penggantian dana transportasi, makan, dan dinas.',
          isEn ? 'Submit Reimbursement' : 'Ajukan Reimbursement',
        ),
      SubmissionKind.medicalClaim => (
          isEn ? 'Medical Expense Claim' : 'Klaim Biaya Medis',
          isEn ? 'Inpatient / Outpatient Claim?' : 'Klaim Rawat Jalan / Inap?',
          isEn
              ? 'Reimbursement of employee medical and healthcare costs.'
              : 'Penggantian biaya kesehatan dan rawat jalan karyawan.',
          isEn ? 'Submit Medical Claim' : 'Ajukan Medical Claim',
        ),
      SubmissionKind.pettyCash => (
          isEn ? 'Petty Cash Request' : 'Permohonan Kas Kecil',
          isEn ? 'Need Petty Cash Funds?' : 'Butuh Dana Kas Kecil?',
          isEn
              ? 'Request cash advance or quick office operational funds.'
              : 'Permohonan uang muka atau dana operasional cepat kantor.',
          isEn ? 'Request Petty Cash' : 'Ajukan Petty Cash',
        ),
      SubmissionKind.generalAffair => (
          isEn ? 'GA Facilities & Supplies' : 'Fasilitas & Sarana GA',
          isEn ? 'Need Work Equipment?' : 'Kebutuhan Sarana Kerja?',
          isEn
              ? 'Procurement, inventory repair, and workplace facilities.'
              : 'Pengadaan barang, perbaikan inventaris, dan fasilitas kerja.',
          isEn ? 'Request General Affair' : 'Ajukan General Affair',
        ),
    };
  }
}
