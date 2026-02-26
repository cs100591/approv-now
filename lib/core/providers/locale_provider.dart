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
    final scriptCode = prefs.getString('script_code');
    if (languageCode != null) {
      _locale = Locale.fromSubtags(
        languageCode: languageCode,
        scriptCode: scriptCode,
      );
      notifyListeners();
    }
  }

  void setLocale(Locale loc) async {
    if (!L10n.all.contains(loc)) return;

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

class L10n {
  static final all = [
    const Locale('en'),
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    const Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    const Locale('ja'),
    const Locale('ko'),
    const Locale('id'),
    const Locale('vi'),
    const Locale('th'),
    const Locale('ms'),
    const Locale('es'),
  ];

  static String getLanguageName(Locale locale) {
    final tag = locale.toLanguageTag(); // e.g. 'zh-Hans', 'zh-Hant', 'en', 'ja'

    switch (tag) {
      case 'zh-Hans':
        return '简体中文';
      case 'zh-Hant':
        return '繁體中文';
      case 'en':
        return 'English';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'id':
        return 'Bahasa Indonesia';
      case 'vi':
        return 'Tiếng Việt';
      case 'th':
        return 'ภาษาไทย';
      case 'ms':
        return 'Bahasa Melayu';
      case 'es':
        return 'Español';
      default:
        return 'English';
    }
  }
}
