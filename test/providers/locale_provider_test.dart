import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_pim/providers/locale_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'locale_provider_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late LocaleProvider localeProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    localeProvider = LocaleProvider();
  });

  group('LocaleProvider Tests', () {
    test('Initial locale should be null', () {
      expect(localeProvider.locale, isNull);
    });

    test('loadLocale should use saved preference if available', () async {
      SharedPreferences.setMockInitialValues({'selected_language': 'uk'});
      await localeProvider.loadLocale(const Locale('en'));
      expect(localeProvider.locale?.languageCode, 'uk');
    });

    test('loadLocale should detect uk from system locale ru or uk', () async {
      await localeProvider.loadLocale(const Locale('ru'));
      expect(localeProvider.locale?.languageCode, 'uk');

      await localeProvider.loadLocale(const Locale('uk'));
      expect(localeProvider.locale?.languageCode, 'uk');
    });

    test('loadLocale should use system locale if supported', () async {
      await localeProvider.loadLocale(const Locale('de'));
      expect(localeProvider.locale?.languageCode, 'de');
      
      await localeProvider.loadLocale(const Locale('fr'));
      expect(localeProvider.locale?.languageCode, 'fr');
    });

    test('loadLocale should default to en if system locale not supported', () async {
      await localeProvider.loadLocale(const Locale('it'));
      expect(localeProvider.locale?.languageCode, 'en');
    });

    test('setLocale should update locale and persist', () async {
      await localeProvider.setLocale(const Locale('pl'));
      expect(localeProvider.locale?.languageCode, 'pl');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('selected_language'), 'pl');
    });

    test('setLocale should ignore unsupported locales', () async {
      await localeProvider.setLocale(const Locale('uk')); // set valid first
      await localeProvider.setLocale(const Locale('it')); // try invalid
      
      expect(localeProvider.locale?.languageCode, 'uk');
    });
  });
}
