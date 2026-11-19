import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'language_swap/app_language.dart';
import 'language_swap/language_swap_menu_item.dart';
import 'language_swap/language_swap_trigger.dart';

export 'language_swap/app_language.dart';

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
    currentLanguage = widget.initialLanguage != AppLanguage.id
        ? widget.initialLanguage
        : AppLanguageController.currentLanguage;
    AppLanguageController.instance.addListener(_onGlobalLanguageChanged);
  }

  void _onGlobalLanguageChanged() {
    if (mounted && currentLanguage != AppLanguageController.currentLanguage) {
      setState(() {
        currentLanguage = AppLanguageController.currentLanguage;
      });
    }
  }

  @override
  void dispose() {
    AppLanguageController.instance.removeListener(_onGlobalLanguageChanged);
    super.dispose();
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

  void _handleLanguageSelected(AppLanguage selectedLang) {
    if (selectedLang != currentLanguage) {
      setState(() {
        currentLanguage = selectedLang;
      });
      AppLanguageController.setLanguage(selectedLang);
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
        onSelected: _handleLanguageSelected,
        itemBuilder: (BuildContext context) {
          return AppLanguage.values.map((AppLanguage lang) {
            final bool isSelected = lang == currentLanguage;
            return PopupMenuItem<AppLanguage>(
              value: lang,
              height: 34.w,
              padding: EdgeInsets.zero,
              child: LanguageSwapMenuItem(
                language: lang,
                isSelected: isSelected,
              ),
            );
          }).toList();
        },
        child: LanguageSwapTrigger(currentLanguage: currentLanguage),
      ),
    );
  }
}
