import 'package:flutter_test/flutter_test.dart';
import 'package:personal_pim/models/calendar_event.dart';

void main() {
  group('CalendarEvent Model Tests', () {
    test('Constructor should initialize all properties correctly', () {
      final testDate = DateTime(2023, 12, 25);
      final event = CalendarEvent(
        contactId: 'c1',
        contactName: 'John Doe',
        fieldName: 'Birthday',
        date: testDate,
        isBirthday: true,
        remindYearly: true,
        remindBefore: ['day', 'week'],
        age: 30,
      );

      expect(event.contactId, 'c1');
      expect(event.contactName, 'John Doe');
      expect(event.fieldName, 'Birthday');
      expect(event.date, testDate);
      expect(event.isBirthday, true);
      expect(event.remindYearly, true);
      expect(event.remindBefore, ['day', 'week']);
      expect(event.age, 30);
    });

    test('Default values should be applied', () {
      final testDate = DateTime(2023, 12, 25);
      final event = CalendarEvent(
        contactId: 'c1',
        contactName: 'John Doe',
        fieldName: 'Event',
        date: testDate,
      );

      expect(event.isBirthday, false);
      expect(event.remindYearly, false);
      expect(event.remindBefore, ['day']);
      expect(event.age, isNull);
    });
  });
}
