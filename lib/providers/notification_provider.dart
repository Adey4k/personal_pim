import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 10, minute: 0);
  final NotificationService _notificationService = NotificationService();

  static const String _timeHourKey = 'reminder_hour';
  static const String _timeMinuteKey = 'reminder_minute';

  TimeOfDay get reminderTime => _reminderTime;

  NotificationProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final hour = prefs.getInt(_timeHourKey);
    final minute = prefs.getInt(_timeMinuteKey);
    
    if (hour != null && minute != null) {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    }
    
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
    await _notificationService.scheduleDailyNotification(
      id: 0,
      title: 'Mnemo PIM',
      body: 'Don\'t forget to check your tasks today!',
      hour: _reminderTime.hour,
      minute: _reminderTime.minute,
    );
  }
}
