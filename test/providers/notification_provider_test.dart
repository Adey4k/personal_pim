import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mockito/annotations.dart';
import 'package:personal_pim/models/contact.dart';
import 'package:personal_pim/providers/notification_provider.dart';
import 'package:personal_pim/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

@GenerateMocks([SharedPreferences])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const notificationsChannel = MethodChannel(
    'dexterous.com/flutter/local_notifications',
  );
  late List<MethodCall> notificationCalls;
  late NotificationProvider notificationProvider;

  setUp(() {
    notificationCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, (methodCall) async {
          notificationCalls.add(methodCall);
          return null;
        });

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Kyiv'));
    SharedPreferences.setMockInitialValues({});
    notificationProvider = NotificationProvider();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(notificationsChannel, null);
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

      await notificationProvider.init();

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

    test(
      'scheduleContactEventNotifications schedules birthday reminders',
      () async {
        notificationProvider = NotificationProvider(
          now: () => DateTime(2098, 6, 14, 9),
        );

        await notificationProvider.scheduleContactEventNotifications([
          Contact(
            id: 'contact-1',
            fields: {
              AppKeys.name: 'Alex',
              AppKeys.birthday: {
                'date': '15.06.1990',
                'remindYearly': true,
                'remindBefore': ['day', 'today'],
              },
            },
          ),
        ]);

        final scheduleCalls = notificationCalls
            .where((call) => call.method == 'zonedSchedule')
            .toList();

        expect(scheduleCalls, hasLength(2));

        final firstArgs =
            scheduleCalls.first.arguments as Map<dynamic, dynamic>;
        expect(firstArgs['title'], 'Birthday - Alex');
        expect(firstArgs['body'], 'June 15 (1 day)');
        expect(firstArgs['scheduledDateTime'], startsWith('2098-06-14T'));
        expect(
          firstArgs['matchDateTimeComponents'],
          DateTimeComponents.dateAndTime.index,
        );
      },
    );

    test('yearless contact events are scheduled as yearly reminders', () async {
      notificationProvider = NotificationProvider(
        now: () => DateTime(2098, 6, 14, 9),
      );

      await notificationProvider.scheduleContactEventNotifications([
        Contact(
          id: 'contact-1',
          fields: {
            AppKeys.name: 'Alex',
            'Anniversary': {
              'date': '20.06.0000',
              'remindYearly': false,
              'remindBefore': ['today'],
            },
          },
        ),
      ]);

      final scheduleCalls = notificationCalls
          .where((call) => call.method == 'zonedSchedule')
          .toList();

      expect(scheduleCalls, hasLength(1));
      final args = scheduleCalls.single.arguments as Map<dynamic, dynamic>;
      expect(args['title'], 'Anniversary - Alex');
      expect(args['body'], 'June 20 (on the day)');
      expect(args['scheduledDateTime'], startsWith('2098-06-20T'));
      expect(
        args['matchDateTimeComponents'],
        DateTimeComponents.dateAndTime.index,
      );
    });

    test(
      'missed same-day reminders are caught up once and kept yearly',
      () async {
        notificationProvider = NotificationProvider(
          now: () => DateTime(2098, 6, 14, 10, 30),
        );

        await notificationProvider.scheduleContactEventNotifications([
          Contact(
            id: 'contact-1',
            fields: {
              AppKeys.name: 'Alex',
              AppKeys.birthday: {
                'date': '14.06.1990',
                'remindYearly': true,
                'remindBefore': ['today'],
              },
            },
          ),
        ]);

        final scheduleCalls = notificationCalls
            .where((call) => call.method == 'zonedSchedule')
            .toList();

        expect(scheduleCalls, hasLength(2));

        final catchUpArgs =
            scheduleCalls.first.arguments as Map<dynamic, dynamic>;
        final yearlyArgs =
            scheduleCalls.last.arguments as Map<dynamic, dynamic>;

        expect(catchUpArgs['scheduledDateTime'], startsWith('2098-06-14T'));
        expect(catchUpArgs['body'], 'June 14 (on the day)');
        expect(catchUpArgs['scheduledDateTime'], endsWith(':31:00'));
        expect(catchUpArgs.containsKey('matchDateTimeComponents'), isFalse);
        expect(yearlyArgs['scheduledDateTime'], startsWith('2099-06-14T'));
        expect(
          yearlyArgs['matchDateTimeComponents'],
          DateTimeComponents.dateAndTime.index,
        );
      },
    );
  });
}
