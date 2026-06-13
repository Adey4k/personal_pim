import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 10, minute: 0);
  final NotificationService _notificationService = NotificationService();

  static const String _timeHourKey = 'reminder_hour';
  static const String _timeMinuteKey = 'reminder_minute';

  TimeOfDay get reminderTime => _reminderTime;

  NotificationProvider();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    final hour = prefs.getInt(_timeHourKey);
    final minute = prefs.getInt(_timeMinuteKey);
    
    if (hour != null && minute != null) {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    }
    
    await _notificationService.requestPermissions();
    _updateNotification();
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    _updateNotification();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeHourKey, time.hour);
    await prefs.setInt(_timeMinuteKey, time.minute);
  }

  Future<void> _updateNotification() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lang = prefs.getString('selected_language') ?? 'en';
      // Load localizations
      final l10n = await AppLocalizations.delegate.load(Locale(lang));

      await _notificationService.scheduleDailyNotification(
        id: 0,
        title: l10n.dailyReminderTitle,
        body: l10n.dailyReminderBody,
        hour: _reminderTime.hour,
        minute: _reminderTime.minute,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}
