import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:uicons/uicons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';
import '../../../root/presentation/widgets/language_swap_button.dart';

/// Jenis kategori statistik presensi
enum AttendanceStatType {
  sudahAbsen,
  tepatWaktu,
  terlambat,
  belumAbsen;

  /// Label ringkas & jelas
  String get label => getLabel(AppLanguage.id);

  String getLabel([AppLanguage language = AppLanguage.id]) {
    final isEn = language == AppLanguage.en;
    switch (this) {
      case AttendanceStatType.sudahAbsen:
        return isEn ? 'CHECKED IN' : 'SUDAH ABSEN';
      case AttendanceStatType.tepatWaktu:
        return isEn ? 'ON TIME' : 'TEPAT WAKTU';
      case AttendanceStatType.terlambat:
        return isEn ? 'LATE' : 'TERLAMBAT';
      case AttendanceStatType.belumAbsen:
        return isEn ? 'ABSENT' : 'BELUM ABSEN';
    }
  }

  /// Ikon vektor monoline korporat
  IconData get iconData {
    switch (this) {
      case AttendanceStatType.sudahAbsen:
        return UIcons.regularRounded.check;
      case AttendanceStatType.tepatWaktu:
        return UIcons.regularRounded.clock;
      case AttendanceStatType.terlambat:
        return UIcons.regularRounded.exclamation;
      case AttendanceStatType.belumAbsen:
        return UIcons.regularRounded.cross_circle;
    }
  }

  /// Warna aksen utama Teal Korporat terpadu
  Color get accentColor => const Color(0xFF0D9488); // Teal 600

  /// Warna kontainer squircle: Frosted Soft Mint Teal
  Color get containerBgColor => const Color(0xFFF0FDFA); // Mint 50

  /// Border kontainer squircle: Teal halus
  Color get borderColor => const Color(0xFFCCFBF1); // Mint / Teal 100
}

/// Data model item statistik
class AttendanceStatItem {
  final AttendanceStatType type;
  final int count;

  const AttendanceStatItem({
    required this.type,
    required this.count,
  });
}

/// Widget Kartu Statistik Presensi (Signature Corporate Teal)
class AttendanceStatCard extends StatelessWidget {
  final AttendanceStatType type;
  final int count;
  final bool isSelected;
  final VoidCallback? onTap;
  final AppLanguage language;

  AttendanceStatCard({
    super.key,
    AttendanceStatType? type,
    int? count,
    AttendanceStatItem? item,
    this.isSelected = false,
    this.onTap,
    this.language = AppLanguage.id,
  })  : assert(
          (type != null && count != null) || item != null,
          'Either (type and count) or item must be provided',
        ),
        type = type ?? item!.type,
        count = count ?? item!.count;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 72.w,
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.w),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF0FDFA) : AppColors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF0D9488)
                  : const Color(0xFFE2E8F0),
              width: isSelected ? 1.5.w : 1.w,
            ),
            boxShadow: isSelected
                ? [
                    const BoxShadow(
                      color: Color(0x180F766E),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ]
                : const [AppShadows.shadow094],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Corporate Teal Squircle + Clean Vector Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0F766E) // Deep Teal saat aktif
                      : const Color(0xFFF0FDFA), // Soft Mint Teal
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF0F766E)
                        : const Color(0xFFCCFBF1),
                    width: 1.2.w,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  type.iconData,
                  size: 20.sp,
                  color: isSelected
                      ? Colors.white
                      : const Color(0xFF0D9488), // Teal 600
                ),
              ),
              SizedBox(width: 8.w),

              // 2. Value & Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$count',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? const Color(0xFF0F766E)
                            : AppColors.textPrimary,
                        letterSpacing: -0.5,
                        height: 1.1,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      type.getLabel(language),
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF0D9488)
                            : const Color(0xFF64748B),
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
