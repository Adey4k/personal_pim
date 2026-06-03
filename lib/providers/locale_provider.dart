import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  Locale? _locale;
  static const String _prefsKey = 'selected_language';

  Locale? get locale => _locale;

  LocaleProvider() {
    // We will call loadLocale manually from main.dart to pass the system locale
  }

  Future<void> loadLocale(Locale systemLocale) async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_prefsKey);

    if (languageCode != null) {
      _locale = Locale(languageCode);
    } else {
      // Automatic detection logic
      String code = systemLocale.languageCode;
      if (code == 'ru' || code == 'uk') {
        _locale = const Locale('uk');
      } else if (['de', 'fr', 'es', 'pl', 'en'].contains(code)) {
        _locale = Locale(code);
      } else {
        _locale = const Locale('en');
      }
    }
    notifyListeners();
  }

  Future<void> _loadLocale() async {
    // Keep this for backward compatibility or internal use if needed, 
    // but the main initialization now happens in loadLocale(systemLocale)
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_prefsKey);
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (!['en', 'uk', 'de', 'fr', 'es', 'pl'].contains(locale.languageCode)) return;

    _locale = locale;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
