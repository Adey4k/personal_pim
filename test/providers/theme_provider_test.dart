import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_pim/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ThemeProvider themeProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    themeProvider = ThemeProvider();
  });

  group('ThemeProvider Tests', () {
    test('Initial values should be system and green', () {
      expect(themeProvider.themeMode, ThemeMode.system);
      expect(themeProvider.seedColor, Colors.green);
    });

    test('setThemeMode should update themeMode and notify listeners', () async {
      bool notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      await themeProvider.setThemeMode(ThemeMode.dark);

      expect(themeProvider.themeMode, ThemeMode.dark);
      expect(notified, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_mode'), ThemeMode.dark.index);
    });

    test('setSeedColor should update seedColor and notify listeners', () async {
      bool notified = false;
      themeProvider.addListener(() {
        notified = true;
      });

      const newColor = Colors.blue;
      await themeProvider.setSeedColor(newColor);

      expect(themeProvider.seedColor, newColor);
      expect(notified, true);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('theme_color'), newColor.toARGB32());
    });
  });
}
