import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_pim/providers/notification_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_provider_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late NotificationProvider notificationProvider;

  setUp(() {
    const MethodChannel('dexterous.com/flutter/local_notifications')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      return null;
    });

    tz.initializeTimeZones();
    SharedPreferences.setMockInitialValues({});
    notificationProvider = NotificationProvider();
  });

  group('NotificationProvider Tests', () {
    test('Initial reminder time should be 10:00', () {
      expect(notificationProvider.reminderTime.hour, 10);
      expect(notificationProvider.reminderTime.minute, 0);
    });

    test('loadSettings should use saved time if available', () async {
      SharedPreferences.setMockInitialValues({
        'reminder_hour': 8,
        'reminder_minute': 30,
      });
      notificationProvider = NotificationProvider();
      
      await Future.delayed(Duration.zero); 

      expect(notificationProvider.reminderTime.hour, 8);
      expect(notificationProvider.reminderTime.minute, 30);
    });

    test('setReminderTime should update time and persist', () async {
      const newTime = TimeOfDay(hour: 14, minute: 15);
      await notificationProvider.setReminderTime(newTime);

      expect(notificationProvider.reminderTime.hour, 14);
      expect(notificationProvider.reminderTime.minute, 15);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('reminder_hour'), 14);
      expect(prefs.getInt('reminder_minute'), 15);
    });
  });
}
