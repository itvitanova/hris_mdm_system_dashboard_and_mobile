/// Jenis pengajuan resmi di PeopleOS HRIS MDM
enum SubmissionKind {
  cuti,
  izin,
  reimbursement,
  medicalClaim,
  pettyCash,
  generalAffair,
  lembur;

  static SubmissionKind fromString(String value) {
    switch (value.toLowerCase().replaceAll(' ', '')) {
      case 'cuti':
      case 'leave':
        return SubmissionKind.cuti;
      case 'izin':
      case 'permission':
        return SubmissionKind.izin;
      case 'reimbursement':
        return SubmissionKind.reimbursement;
      case 'medicalclaim':
      case 'medical':
      case 'klaimmedis':
        return SubmissionKind.medicalClaim;
      case 'pettycash':
      case 'kaskecil':
        return SubmissionKind.pettyCash;
      case 'generalaffair':
      case 'ga':
        return SubmissionKind.generalAffair;
      case 'lembur':
      case 'overtime':
        return SubmissionKind.lembur;
      default:
        return SubmissionKind.cuti;
    }
  }

  String get displayName {
    switch (this) {
      case SubmissionKind.cuti:
        return 'Cuti';
      case SubmissionKind.izin:
        return 'Izin';
      case SubmissionKind.reimbursement:
        return 'Reimbursement';
      case SubmissionKind.medicalClaim:
        return 'Medical Claim';
      case SubmissionKind.pettyCash:
        return 'Petty Cash';
      case SubmissionKind.generalAffair:
        return 'General Affair';
      case SubmissionKind.lembur:
        return 'Lembur';
    }
  }
}
