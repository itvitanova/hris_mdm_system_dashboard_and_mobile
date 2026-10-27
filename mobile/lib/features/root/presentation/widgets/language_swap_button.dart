import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_shadows.dart';

enum AppLanguage {
  id('id', 'Bahasa Indonesia', 'ID', '🇮🇩'),
  en('en', 'English', 'EN', '🇬🇧'),
  zh('zh', '简体中文', 'ZH', '🇨🇳');

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
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        offset: const Offset(0, 44),
        constraints: const BoxConstraints(
          minWidth: 160,
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
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                duration: const Duration(seconds: 2),
                content: Row(
                  children: [
                    Text(
                      selectedLang.flagEmoji,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        selectedLang == AppLanguage.id
                            ? 'Bahasa berhasil diubah ke Bahasa Indonesia'
                            : selectedLang == AppLanguage.en
                                ? 'Language switched to English'
                                : '语言已切换为简体中文',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
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
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFF0FDFA)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      lang.flagEmoji,
                      style: const TextStyle(fontSize: 17),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      lang.name,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.filterTealAccent
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (isSelected) ...[
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.check_rounded,
                        size: 18,
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
          height: 38,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
            boxShadow: const [AppShadows.shadow094],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                currentLanguage.flagEmoji,
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(width: 6),
              Text(
                currentLanguage.shortLabel,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(width: 2),
              const Icon(
                Icons.arrow_drop_down_rounded,
                size: 18,
                color: Color(0xFF64748B),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
