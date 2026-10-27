import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';

enum AppLanguage {
  id('id', 'Bahasa Indonesia', 'ID', '🇮🇩'),
  en('en', 'English', 'EN', '🇬🇧');

  final String code;
  final String name;
  final String shortLabel;
  final String flagEmoji;

  const AppLanguage(
    this.code,
    this.name,
    this.shortLabel,
    this.flagEmoji,
  );
}

class LanguageSwapButton extends StatefulWidget {
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final AppLanguage initialLanguage;

  const LanguageSwapButton({
    super.key,
    this.onLanguageChanged,
    this.initialLanguage = AppLanguage.id,
  });

  @override
  State<LanguageSwapButton> createState() => _LanguageSwapButtonState();
}

class _LanguageSwapButtonState extends State<LanguageSwapButton> {
  late AppLanguage currentLanguage;

  @override
  void initState() {
    super.initState();
    currentLanguage = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
      child: PopupMenuButton<AppLanguage>(
        key: const Key('dashboard_language_swap_button'),
        tooltip: 'Pilih Bahasa',
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.16),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        offset: Offset(0, 46.w),
        constraints: BoxConstraints(
          minWidth: 160.w,
        ),
        initialValue: currentLanguage,
        onSelected: (AppLanguage selectedLang) {
          if (selectedLang != currentLanguage) {
            setState(() {
              currentLanguage = selectedLang;
            });
            widget.onLanguageChanged?.call(selectedLang);

            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                margin: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.w,
                ),
                duration: const Duration(seconds: 2),
                content: Row(
                  children: [
                    Text(
                      selectedLang.flagEmoji,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        selectedLang == AppLanguage.id
                            ? 'Bahasa berhasil diubah ke Bahasa Indonesia'
                            : 'Language switched to English',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        itemBuilder: (BuildContext context) {
          return AppLanguage.values.map((AppLanguage lang) {
            final bool isSelected = lang == currentLanguage;

            return PopupMenuItem<AppLanguage>(
              value: lang,
              height: 44.w,
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w,
                  vertical: 6.w,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF0FDFA)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.flagEmoji,
                      style: TextStyle(fontSize: 17.sp),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      lang.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.filterTealAccent
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (isSelected) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.check_rounded,
                        size: 18.w,
                        color: AppColors.filterTealAccent,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }).toList();
        },
        child: Container(
          height: 40.w,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(13.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.w,
            ),
            boxShadow: const [AppShadows.shadow094],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLanguage.flagEmoji,
                style: TextStyle(fontSize: 15.sp),
              ),
              SizedBox(width: 6.w),
              Text(
                currentLanguage.shortLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.arrow_drop_down_rounded,
                size: 18.w,
                color: const Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
