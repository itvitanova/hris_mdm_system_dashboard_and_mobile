import 'package:mdm_hris/features/root/presentation/widgets/language_swap_button.dart';

/// Enum Bulan untuk filter riwayat presensi
enum MonthEnum {
  januari,
  februari,
  maret,
  april,
  mei,
  juni,
  juli,
  agustus,
  september,
  oktober,
  november,
  desember;

  String get name => getName(AppLanguage.id);

  String getName([AppLanguage language = AppLanguage.id]) {
    if (language == AppLanguage.en) {
      const namesEn = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December',
      ];
      return namesEn[index];
    }
    switch (this) {
      case MonthEnum.januari:
        return 'Januari';
      case MonthEnum.februari:
        return 'Februari';
      case MonthEnum.maret:
        return 'Maret';
      case MonthEnum.april:
        return 'April';
      case MonthEnum.mei:
        return 'Mei';
      case MonthEnum.juni:
        return 'Juni';
      case MonthEnum.juli:
        return 'Juli';
      case MonthEnum.agustus:
        return 'Agustus';
      case MonthEnum.september:
        return 'September';
      case MonthEnum.oktober:
        return 'Oktober';
      case MonthEnum.november:
        return 'November';
      case MonthEnum.desember:
        return 'Desember';
    }
  }

  String get shortName => getShortName(AppLanguage.id);

  String getShortName([AppLanguage language = AppLanguage.id]) {
    if (language == AppLanguage.en) {
      const shortLabelsEn = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return shortLabelsEn[index];
    }
    const shortLabels = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return shortLabels[index];
  }
}
