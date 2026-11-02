import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';

enum AppLanguage {
  id('id', 'ID', 'ID', '🇮🇩'),
  en('en', 'ENG', 'ENG', '🇬🇧');

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
  void didUpdateWidget(covariant LanguageSwapButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLanguage != widget.initialLanguage) {
      setState(() {
        currentLanguage = widget.initialLanguage;
      });
    }
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
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        color: Colors.white,
        menuPadding: EdgeInsets.symmetric(vertical: 4.w, horizontal: 4.w),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.0,
          ),
        ),
        offset: Offset(0, 42.w),
        constraints: BoxConstraints(
          minWidth: 88.w,
          maxWidth: 96.w,
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
              height: 34.w,
              padding: EdgeInsets.zero,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 6.w,
                  vertical: 5.w,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF0FDFA)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child:  Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.flagEmoji,
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      lang.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.filterTealAccent
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList();
        },
        child: Container(
          height: 38.w,
          padding: EdgeInsets.symmetric(horizontal: 9.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: const [AppShadows.shadow094],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLanguage.flagEmoji,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(width: 5.w),
              Text(
                currentLanguage.shortLabel,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                  letterSpacing: 0.2,
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
