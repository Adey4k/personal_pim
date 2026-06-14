import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/contact.dart';
import '../utils/constants.dart';

class HomeWidgetService {
  static const String _androidBirthdayWidgetName = 'BirthdayWidgetProvider';

  static Future<void> updateBirthdays(List<Contact> contacts) async {
    final upcomingBirthdays = _getUpcomingBirthdays(contacts);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final List<Map<String, String>> data = upcomingBirthdays.map((c) {
      final dateStr = _extractBirthdayDate(c.fields[AppKeys.birthday]);
      final age = _calculateUpcomingAge(dateStr, today);

      return {
        'id': c.id ?? '',
        'name': c.name,
        'date': dateStr.endsWith('.0000') ? dateStr.substring(0, 5) : dateStr,
        'age': age > 0 ? '$age' : '',
      };
    }).toList();

    await HomeWidget.saveWidgetData<String>('birthdays_data', jsonEncode(data));
    await HomeWidget.updateWidget(
      name: _androidBirthdayWidgetName,
      androidName: _androidBirthdayWidgetName,
    );
  }

  static Future<void> updateCustomEvents(List<Contact> contacts) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Group upcoming events by field name
    // Event format: { eventType: [ { id, name, date, age }, ... ] }
    Map<String, List<Map<String, String>>> groupedEvents = {};

    for (var c in contacts) {
      c.fields.forEach((key, value) {
        if (key == AppKeys.birthday) return; // Skip birthdays

        String? dateStr = _extractBirthdayDate(value);
        if (dateStr.isEmpty) return;

        if (_parseStoredDate(dateStr) != null) {
          final age = _calculateUpcomingAge(dateStr, today);

          if (!groupedEvents.containsKey(key)) {
            groupedEvents[key] = [];
          }

          groupedEvents[key]!.add({
            'id': c.id ?? '',
            'name': c.name,
            'date': dateStr.endsWith('.0000')
                ? dateStr.substring(0, 5)
                : dateStr,
            'age': age > 0 ? '$age' : '',
          });
        }
      });
    }

    // Sort events within each group
    for (var key in groupedEvents.keys) {
      groupedEvents[key]!.sort((a, b) {
        final dateA = _getNextBirthday(a['date'] ?? '', today);
        final dateB = _getNextBirthday(b['date'] ?? '', today);
        return dateA.compareTo(dateB);
      });
      // take top 20
      groupedEvents[key] = groupedEvents[key]!.take(20).toList();
    }

    // Also pass available event types as a list to the widget
    final eventTypes = groupedEvents.keys.toList();
    eventTypes.sort();

    final payload = {'eventTypes': eventTypes, 'events': groupedEvents};

    await HomeWidget.saveWidgetData<String>(
      'custom_events_data',
      jsonEncode(payload),
    );
    await HomeWidget.updateWidget(
      name: 'CustomEventWidgetProvider',
      androidName: 'CustomEventWidgetProvider',
    );
  }

  static String _extractBirthdayDate(dynamic value) {
    if (value == null) return '';
    if (value is Map) {
      return value['date']?.toString() ?? '';
    }
    return value.toString();
  }

  static int _calculateUpcomingAge(String bdayStr, DateTime today) {
    final parsedDate = _parseStoredDate(bdayStr);
    if (parsedDate == null) return 0;
    var year = parsedDate.year;

    if (year < 100) {
      year += (year > DateTime.now().year % 100) ? 1900 : 2000;
    }

    if (year < 1850 || year > 2100) return 0;

    var nextBday = DateTime(today.year, parsedDate.month, parsedDate.day);
    if (nextBday.isBefore(today)) {
      nextBday = DateTime(today.year + 1, parsedDate.month, parsedDate.day);
    }

    return nextBday.year - year;
  }

  static List<Contact> _getUpcomingBirthdays(List<Contact> contacts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final birthdayContacts = contacts.where((c) {
      final bdayDate = _extractBirthdayDate(c.fields[AppKeys.birthday]);
      return bdayDate.isNotEmpty;
    }).toList();

    birthdayContacts.sort((a, b) {
      final dateA = _getNextBirthday(
        _extractBirthdayDate(a.fields[AppKeys.birthday]),
        today,
      );
      final dateB = _getNextBirthday(
        _extractBirthdayDate(b.fields[AppKeys.birthday]),
        today,
      );
      return dateA.compareTo(dateB);
    });

    return birthdayContacts.take(20).toList();
  }

  static DateTime _getNextBirthday(String bdayStr, DateTime today) {
    final parsedDate = _parseStoredDate(bdayStr);
    if (parsedDate == null) return DateTime(2100);

    var nextBday = DateTime(today.year, parsedDate.month, parsedDate.day);
    if (nextBday.isBefore(today)) {
      nextBday = DateTime(today.year + 1, parsedDate.month, parsedDate.day);
    }
    return nextBday;
  }

  static _ParsedWidgetDate? _parseStoredDate(String value) {
    final text = value.trim();
    final dayMonthYear = RegExp(
      r'^(\d{1,2})[\.\-\/](\d{1,2})[\.\-\/](\d{4})$',
    ).firstMatch(text);
    if (dayMonthYear != null) {
      return _validDate(
        year: int.parse(dayMonthYear.group(3)!),
        month: int.parse(dayMonthYear.group(2)!),
        day: int.parse(dayMonthYear.group(1)!),
      );
    }

    final yearMonthDay = RegExp(
      r'^(\d{4})[\.\-\/](\d{1,2})[\.\-\/](\d{1,2})$',
    ).firstMatch(text);
    if (yearMonthDay != null) {
      return _validDate(
        year: int.parse(yearMonthDay.group(1)!),
        month: int.parse(yearMonthDay.group(2)!),
        day: int.parse(yearMonthDay.group(3)!),
      );
    }

    return null;
  }

  static _ParsedWidgetDate? _validDate({
    required int year,
    required int month,
    required int day,
  }) {
    if (month < 1 || month > 12 || day < 1) return null;
    final validationYear = year == 0 ? 2000 : year;
    final date = DateTime(validationYear, month, day);
    if (date.year != validationYear || date.month != month || date.day != day) {
      return null;
    }

    return _ParsedWidgetDate(year: year, month: month, day: day);
  }
}

class _ParsedWidgetDate {
  final int year;
  final int month;
  final int day;

  const _ParsedWidgetDate({
    required this.year,
    required this.month,
    required this.day,
  });
}
