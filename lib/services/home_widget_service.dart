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
        'date': dateStr,
        'age': age > 0 ? '$age' : '',
      };
    }).toList();

    await HomeWidget.saveWidgetData<String>('birthdays_data', jsonEncode(data));
    await HomeWidget.updateWidget(
      name: _androidBirthdayWidgetName,
      androidName: _androidBirthdayWidgetName,
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
    try {
      final separator = bdayStr.contains('.') ? '.' : '-';
      final parts = bdayStr.split(separator);
      
      if (parts.length != 3) return 0;

      int day, month, year;
      if (separator == '.') {
        day = int.parse(parts[0]);
        month = int.parse(parts[1]);
        year = int.parse(parts[2]);
      } else {
        year = int.parse(parts[0]);
        month = int.parse(parts[1]);
        day = int.parse(parts[2]);
      }

      if (year < 100) {
        year += (year > DateTime.now().year % 100) ? 1900 : 2000;
      }

      if (year < 1850 || year > 2100) return 0;

      var nextBday = DateTime(today.year, month, day);
      if (nextBday.isBefore(today)) {
        nextBday = DateTime(today.year + 1, month, day);
      }

      return nextBday.year - year;
    } catch (_) {
      return 0;
    }
  }

  static List<Contact> _getUpcomingBirthdays(List<Contact> contacts) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final birthdayContacts = contacts.where((c) {
      final bdayDate = _extractBirthdayDate(c.fields[AppKeys.birthday]);
      return bdayDate.isNotEmpty;
    }).toList();

    birthdayContacts.sort((a, b) {
      final dateA = _getNextBirthday(_extractBirthdayDate(a.fields[AppKeys.birthday]), today);
      final dateB = _getNextBirthday(_extractBirthdayDate(b.fields[AppKeys.birthday]), today);
      return dateA.compareTo(dateB);
    });

    return birthdayContacts.take(20).toList();
  }

  static DateTime _getNextBirthday(String bdayStr, DateTime today) {
    try {
      final separator = bdayStr.contains('.') ? '.' : '-';
      final parts = bdayStr.split(separator);
      if (parts.length < 2) return DateTime(2100);
      
      int day, month;
      if (separator == '.') {
        day = int.parse(parts[0]);
        month = int.parse(parts[1]);
      } else {
        month = int.parse(parts[1]);
        day = int.parse(parts[2]);
      }
      
      var nextBday = DateTime(today.year, month, day);
      if (nextBday.isBefore(today)) {
        nextBday = DateTime(today.year + 1, month, day);
      }
      return nextBday;
    } catch (_) {
      return DateTime(2100);
    }
  }
}