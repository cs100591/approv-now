import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;

  Locale? get locale => _locale;

  LocaleProvider() {
    _loadSavedLocale();
  }

  void _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');
    var scriptCode = prefs.getString('script_code');
    if (languageCode != null) {
      // Convert generic 'zh' to 'zh_Hans' for backward compatibility
      if (languageCode == 'zh' && scriptCode == null) {
        scriptCode = 'Hans';
      }
      _locale = Locale.fromSubtags(
        languageCode: languageCode,
        scriptCode: scriptCode,
      );
      notifyListeners();
    }
  }

  void setLocale(Locale loc) async {
    // Use manual check since Locale.fromSubtags equality may not work with List.contains
    final isValid = L10n.options.any(
      (o) =>
          o.locale.languageCode == loc.languageCode &&
          o.locale.scriptCode == loc.scriptCode,
    );
    if (!isValid) return;

    _locale = loc;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', loc.languageCode);
    if (loc.scriptCode != null) {
      await prefs.setString('script_code', loc.scriptCode!);
    } else {
      await prefs.remove('script_code');
    }
    notifyListeners();
  }

  void clearLocale() async {
    _locale = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('language_code');
    notifyListeners();
  }
}

class LanguageOption {
  final Locale locale;
  final String displayName;

  const LanguageOption({required this.locale, required this.displayName});
}

class L10n {
  static final options = [
    const LanguageOption(locale: Locale('en'), displayName: 'English'),
    const LanguageOption(
      locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      displayName: '简体中文',
    ),
    const LanguageOption(
      locale: Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      displayName: '繁體中文',
    ),
    const LanguageOption(locale: Locale('ja'), displayName: '日本語'),
    const LanguageOption(locale: Locale('ko'), displayName: '한국어'),
    const LanguageOption(locale: Locale('id'), displayName: 'Bahasa Indonesia'),
    const LanguageOption(locale: Locale('vi'), displayName: 'Tiếng Việt'),
    const LanguageOption(locale: Locale('th'), displayName: 'ภาษาไทย'),
    const LanguageOption(locale: Locale('ms'), displayName: 'Bahasa Melayu'),
    const LanguageOption(locale: Locale('es'), displayName: 'Español'),
  ];

  static List<Locale> get all => options.map((o) => o.locale).toList();

  static String getLanguageName(Locale locale) {
    // Match by languageCode + scriptCode
    for (final option in options) {
      if (option.locale.languageCode == locale.languageCode &&
          option.locale.scriptCode == locale.scriptCode) {
        return option.displayName;
      }
    }
    // Fallback: match by languageCode only (for non-script locales)
    for (final option in options) {
      if (option.locale.languageCode == locale.languageCode &&
          option.locale.scriptCode == null) {
        return option.displayName;
      }
    }
    // Special handling for zh without script code - default to Simplified Chinese
    if (locale.languageCode == 'zh') {
      return '简体中文';
    }
    return 'English';
  }
}
