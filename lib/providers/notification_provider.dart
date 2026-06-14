import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../models/contact.dart';
import '../services/notification_service.dart';
import '../utils/constants.dart';

class NotificationProvider extends ChangeNotifier {
  TimeOfDay _reminderTime = const TimeOfDay(hour: 10, minute: 0);
  final NotificationService _notificationService = NotificationService();
  final DateTime Function() _now;
  List<Contact> _lastContactReminderSnapshot = const [];

  static const String _timeHourKey = 'reminder_hour';
  static const String _timeMinuteKey = 'reminder_minute';
  static const String _contactReminderIdsKey =
      'contact_reminder_notification_ids';
  static const int _dailyReminderId = 0;
  static const int _testNotificationId = 999;
  static const int _contactReminderIdStart = 10000;
  static const int _maxContactReminderNotifications = 500;
  static const Duration _missedReminderGrace = Duration(hours: 24);

  TimeOfDay get reminderTime => _reminderTime;

  NotificationProvider({DateTime Function()? now}) : _now = now ?? DateTime.now;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final hour = prefs.getInt(_timeHourKey);
    final minute = prefs.getInt(_timeMinuteKey);

    if (hour != null && minute != null) {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    }

    await _notificationService.requestPermissions();
    await _cancelUnconfiguredNotifications();
    notifyListeners();
  }

  Future<void> setReminderTime(TimeOfDay time) async {
    _reminderTime = time;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeHourKey, time.hour);
    await prefs.setInt(_timeMinuteKey, time.minute);

    await _cancelUnconfiguredNotifications();
    if (_lastContactReminderSnapshot.isNotEmpty) {
      await scheduleContactEventNotifications(_lastContactReminderSnapshot);
    }
  }

  Future<void> scheduleContactEventNotifications(List<Contact> contacts) async {
    _lastContactReminderSnapshot = List<Contact>.unmodifiable(contacts);

    try {
      final prefs = await SharedPreferences.getInstance();
      await _cancelStoredContactReminderNotifications(prefs);

      final lang = prefs.getString('selected_language') ?? 'en';
      final l10n = await AppLocalizations.delegate.load(Locale(lang));
      await initializeDateFormatting(lang);
      final schedules = _buildContactReminderSchedules(contacts, l10n, lang);
      final scheduledIds = <String>[];

      for (
        var i = 0;
        i < schedules.length && i < _maxContactReminderNotifications;
        i++
      ) {
        final schedule = schedules[i];
        final id = _contactReminderIdStart + i;

        try {
          await _notificationService.scheduleDateNotification(
            id: id,
            title: schedule.title,
            body: schedule.body,
            scheduledDate: schedule.scheduledDate,
            repeatsYearly: schedule.repeatsYearly,
          );
          scheduledIds.add(id.toString());
        } catch (e) {
          debugPrint('Error scheduling contact reminder "$id": $e');
        }
      }

      await prefs.setStringList(_contactReminderIdsKey, scheduledIds);
    } catch (e) {
      debugPrint('Error scheduling contact event notifications: $e');
    }
  }

  Future<void> _cancelStoredContactReminderNotifications(
    SharedPreferences prefs,
  ) async {
    final previousIds = prefs.getStringList(_contactReminderIdsKey) ?? const [];

    for (final storedId in previousIds) {
      final id = int.tryParse(storedId);
      if (id != null) {
        await _notificationService.cancel(id);
      }
    }

    await prefs.remove(_contactReminderIdsKey);
  }

  List<_ContactReminderSchedule> _buildContactReminderSchedules(
    List<Contact> contacts,
    AppLocalizations l10n,
    String localeName,
  ) {
    final now = _now();
    final schedules = <_ContactReminderSchedule>[];

    for (final contact in contacts) {
      for (final field in contact.fields.entries) {
        final dateField = _parseContactDateField(field.key, field.value);
        if (dateField == null || dateField.remindBefore.isEmpty) continue;

        for (final reminderKey in dateField.remindBefore.toSet()) {
          final occurrences = dateField.remindYearly
              ? _yearlyReminderOccurrences(dateField, reminderKey, now)
              : [_oneTimeReminderOccurrence(dateField, reminderKey, now)];

          for (final occurrence
              in occurrences.whereType<_ReminderOccurrence>()) {
            final fieldLabel = field.key == AppKeys.birthday
                ? l10n.birthdayEvent
                : AppKeys.getLocalizedLabel(field.key, l10n);
            schedules.add(
              _ContactReminderSchedule(
                title: '$fieldLabel - ${contact.name}',
                body: _buildReminderBody(
                  occurrence.eventDate,
                  reminderKey,
                  dateField.remindYearly,
                  l10n,
                  localeName,
                ),
                scheduledDate: occurrence.scheduledDate,
                repeatsYearly: occurrence.repeatsYearly,
              ),
            );
          }
        }
      }
    }

    schedules.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return schedules;
  }

  Future<void> _cancelUnconfiguredNotifications() async {
    await _notificationService.cancel(_dailyReminderId);
    await _notificationService.cancel(_testNotificationId);
  }

  String _buildReminderBody(
    DateTime eventDate,
    String reminderKey,
    bool repeatsYearly,
    AppLocalizations l10n,
    String localeName,
  ) {
    final formatter = repeatsYearly
        ? DateFormat.MMMMd(localeName)
        : DateFormat.yMMMMd(localeName);
    final reminderTiming = _localizedReminderTiming(reminderKey, l10n);

    return '${formatter.format(eventDate)} ($reminderTiming)';
  }

  String _localizedReminderTiming(String reminderKey, AppLocalizations l10n) {
    switch (reminderKey) {
      case 'halfYear':
        return l10n.halfYear;
      case 'threeMonths':
        return l10n.threeMonths;
      case 'month':
        return l10n.month;
      case 'twoWeeks':
        return l10n.twoWeeks;
      case 'week':
        return l10n.week;
      case 'threeDays':
        return l10n.threeDays;
      case 'day':
        return '1 ${l10n.day}';
      case 'today':
      default:
        return l10n.today;
    }
  }

  _ContactDateField? _parseContactDateField(String key, dynamic value) {
    String dateText = '';
    bool remindYearly = key == AppKeys.birthday;
    List<String> remindBefore = const ['today'];

    if (value is Map) {
      dateText = value['date']?.toString() ?? '';
      remindYearly =
          value['remindYearly'] as bool? ?? (key == AppKeys.birthday);

      final rawRemindBefore = value['remindBefore'];
      if (rawRemindBefore is List) {
        remindBefore = rawRemindBefore
            .map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .toList();
      } else if (rawRemindBefore is String && rawRemindBefore.isNotEmpty) {
        remindBefore = [rawRemindBefore];
      }
    } else {
      dateText = value?.toString() ?? '';
    }

    final parsedDate = _parseStoredDate(dateText);
    if (parsedDate == null) return null;
    if (parsedDate.year == 0) {
      remindYearly = true;
    }

    return _ContactDateField(
      year: parsedDate.year,
      month: parsedDate.month,
      day: parsedDate.day,
      remindYearly: remindYearly,
      remindBefore: remindBefore,
    );
  }

  _ParsedContactDate? _parseStoredDate(String value) {
    final dateText = value.trim();
    final dayMonthYear = RegExp(
      r'^(\d{1,2})[\.\-\/](\d{1,2})[\.\-\/](\d{4})$',
    ).firstMatch(dateText);
    if (dayMonthYear != null) {
      final day = int.parse(dayMonthYear.group(1)!);
      final month = int.parse(dayMonthYear.group(2)!);
      final year = int.parse(dayMonthYear.group(3)!);
      if (_isValidStoredDate(year, month, day)) {
        return _ParsedContactDate(year: year, month: month, day: day);
      }
      return null;
    }

    final yearMonthDay = RegExp(
      r'^(\d{4})[\.\-\/](\d{1,2})[\.\-\/](\d{1,2})$',
    ).firstMatch(dateText);
    if (yearMonthDay != null) {
      final year = int.parse(yearMonthDay.group(1)!);
      final month = int.parse(yearMonthDay.group(2)!);
      final day = int.parse(yearMonthDay.group(3)!);
      if (_isValidStoredDate(year, month, day)) {
        return _ParsedContactDate(year: year, month: month, day: day);
      }
    }

    return null;
  }

  bool _isValidStoredDate(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1) return false;
    final validationYear = year == 0 ? 2000 : year;
    final date = DateTime(validationYear, month, day);
    return date.year == validationYear &&
        date.month == month &&
        date.day == day;
  }

  _ReminderOccurrence? _oneTimeReminderOccurrence(
    _ContactDateField field,
    String reminderKey,
    DateTime now,
  ) {
    if (field.year == 0) return null;

    final eventDate = _dateWithClampedDay(field.year, field.month, field.day);
    final reminderDate = _applyReminderOffset(eventDate, reminderKey);
    final scheduledDate = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      _reminderTime.hour,
      _reminderTime.minute,
    );

    if (!scheduledDate.isAfter(now)) {
      if (!_canCatchUpReminder(
        scheduledDate: scheduledDate,
        eventDate: eventDate,
        now: now,
      )) {
        return null;
      }

      return _ReminderOccurrence(
        scheduledDate: _catchUpDate(now),
        eventDate: eventDate,
        repeatsYearly: false,
      );
    }

    return _ReminderOccurrence(
      scheduledDate: scheduledDate,
      eventDate: eventDate,
      repeatsYearly: false,
    );
  }

  List<_ReminderOccurrence> _yearlyReminderOccurrences(
    _ContactDateField field,
    String reminderKey,
    DateTime now,
  ) {
    final occurrences = <_ReminderOccurrence>[];
    final catchUp = _missedYearlyReminderOccurrence(field, reminderKey, now);
    if (catchUp != null) {
      occurrences.add(catchUp);
    }

    final next = _nextYearlyReminderOccurrence(field, reminderKey, now);
    if (next != null) {
      occurrences.add(next);
    }

    return occurrences;
  }

  _ReminderOccurrence? _missedYearlyReminderOccurrence(
    _ContactDateField field,
    String reminderKey,
    DateTime now,
  ) {
    final eventDate = _dateWithClampedDay(now.year, field.month, field.day);
    final reminderDate = _applyReminderOffset(eventDate, reminderKey);
    final scheduledDate = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      _reminderTime.hour,
      _reminderTime.minute,
    );

    if (scheduledDate.isAfter(now)) return null;
    if (!_canCatchUpReminder(
      scheduledDate: scheduledDate,
      eventDate: eventDate,
      now: now,
    )) {
      return null;
    }

    return _ReminderOccurrence(
      scheduledDate: _catchUpDate(now),
      eventDate: eventDate,
      repeatsYearly: false,
    );
  }

  _ReminderOccurrence? _nextYearlyReminderOccurrence(
    _ContactDateField field,
    String reminderKey,
    DateTime now,
  ) {
    for (var year = now.year; year <= now.year + 5; year++) {
      final eventDate = _dateWithClampedDay(year, field.month, field.day);
      final reminderDate = _applyReminderOffset(eventDate, reminderKey);
      final scheduledDate = DateTime(
        reminderDate.year,
        reminderDate.month,
        reminderDate.day,
        _reminderTime.hour,
        _reminderTime.minute,
      );

      if (scheduledDate.isAfter(now)) {
        return _ReminderOccurrence(
          scheduledDate: scheduledDate,
          eventDate: eventDate,
          repeatsYearly: true,
        );
      }
    }

    return null;
  }

  bool _canCatchUpReminder({
    required DateTime scheduledDate,
    required DateTime eventDate,
    required DateTime now,
  }) {
    final today = _dateOnly(now);
    final eventDay = _dateOnly(eventDate);

    return !eventDay.isBefore(today) &&
        now.difference(scheduledDate) <= _missedReminderGrace;
  }

  DateTime _catchUpDate(DateTime now) {
    final catchUp = now.add(const Duration(minutes: 1));
    return DateTime(
      catchUp.year,
      catchUp.month,
      catchUp.day,
      catchUp.hour,
      catchUp.minute,
      catchUp.second,
    );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _applyReminderOffset(DateTime eventDate, String reminderKey) {
    switch (reminderKey) {
      case 'halfYear':
        return _subtractCalendarMonths(eventDate, 6);
      case 'threeMonths':
        return _subtractCalendarMonths(eventDate, 3);
      case 'month':
        return _subtractCalendarMonths(eventDate, 1);
      case 'twoWeeks':
        return eventDate.subtract(const Duration(days: 14));
      case 'week':
        return eventDate.subtract(const Duration(days: 7));
      case 'threeDays':
        return eventDate.subtract(const Duration(days: 3));
      case 'day':
        return eventDate.subtract(const Duration(days: 1));
      case 'today':
      default:
        return eventDate;
    }
  }

  DateTime _subtractCalendarMonths(DateTime date, int months) {
    return _dateWithClampedDay(date.year, date.month - months, date.day);
  }

  DateTime _dateWithClampedDay(int year, int month, int day) {
    final normalizedMonth = DateTime(year, month);
    final lastDay = DateTime(
      normalizedMonth.year,
      normalizedMonth.month + 1,
      0,
    ).day;
    final clampedDay = day.clamp(1, lastDay).toInt();

    return DateTime(normalizedMonth.year, normalizedMonth.month, clampedDay);
  }
}

class _ParsedContactDate {
  final int year;
  final int month;
  final int day;

  const _ParsedContactDate({
    required this.year,
    required this.month,
    required this.day,
  });
}

class _ContactDateField {
  final int year;
  final int month;
  final int day;
  final bool remindYearly;
  final List<String> remindBefore;

  const _ContactDateField({
    required this.year,
    required this.month,
    required this.day,
    required this.remindYearly,
    required this.remindBefore,
  });
}

class _ReminderOccurrence {
  final DateTime scheduledDate;
  final DateTime eventDate;
  final bool repeatsYearly;

  const _ReminderOccurrence({
    required this.scheduledDate,
    required this.eventDate,
    required this.repeatsYearly,
  });
}

class _ContactReminderSchedule {
  final String title;
  final String body;
  final DateTime scheduledDate;
  final bool repeatsYearly;

  const _ContactReminderSchedule({
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.repeatsYearly,
  });
}
