import 'package:flutter/foundation.dart';

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

/// Controller terpusat untuk sinkronisasi bahasa aplikasi secara global.
/// Ketika bahasa diubah di Dashboard, seluruh modul/tab akan otomatis memperbarui tampilan.
class AppLanguageController extends ValueNotifier<AppLanguage> {
  static final AppLanguageController instance = AppLanguageController._();
  AppLanguageController._() : super(AppLanguage.id);

  static AppLanguage get currentLanguage => instance.value;

  static void setLanguage(AppLanguage language) {
    if (instance.value != language) {
      instance.value = language;
    }
  }

  static void reset() {
    instance.value = AppLanguage.id;
  }
}
