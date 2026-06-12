import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialProvider extends ChangeNotifier {
  bool _isHomeTutorialShown = false;
  bool _isContactTutorialShown = false;

  static const String _homeKey = 'tutorial_home_shown';
  static const String _contactKey = 'tutorial_contact_shown';

  bool get isHomeTutorialShown => _isHomeTutorialShown;
  bool get isContactTutorialShown => _isContactTutorialShown;

  TutorialProvider() {
    _loadTutorialState();
  }

  Future<void> _loadTutorialState() async {
    final prefs = await SharedPreferences.getInstance();
    _isHomeTutorialShown = prefs.getBool(_homeKey) ?? false;
    _isContactTutorialShown = prefs.getBool(_contactKey) ?? false;
    notifyListeners();
  }

  Future<void> markHomeTutorialAsShown() async {
    _isHomeTutorialShown = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_homeKey, true);
  }

  Future<void> markContactTutorialAsShown() async {
    _isContactTutorialShown = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_contactKey, true);
  }

  Future<void> resetTutorials() async {
    _isHomeTutorialShown = false;
    _isContactTutorialShown = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_homeKey);
    await prefs.remove(_contactKey);
  }
}
