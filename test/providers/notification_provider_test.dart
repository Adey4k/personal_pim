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
        expect(
          firstArgs['body'],
          "Tomorrow is Alex's birthday. Alex turns 108.",
        );
        expect(firstArgs['scheduledDateTime'], startsWith('2098-06-14T'));
        expect(
          firstArgs['matchDateTimeComponents'],
          DateTimeComponents.dateAndTime.index,
        );
      },
    );

    test('uses supported German notification text', () async {
      SharedPreferences.setMockInitialValues({'selected_language': 'de'});
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
              'remindBefore': ['day'],
            },
          },
        ),
      ]);

      final scheduleCalls = notificationCalls
          .where((call) => call.method == 'zonedSchedule')
          .toList();

      expect(scheduleCalls, hasLength(1));
      final args = scheduleCalls.single.arguments as Map<dynamic, dynamic>;
      expect(args['title'], 'Geburtstag - Alex');
      expect(args['body'], 'Morgen hat Alex Geburtstag. Alex wird 108.');
    });

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
      expect(args['body'], 'Today: Anniversary for Alex.');
      expect(args['scheduledDateTime'], startsWith('2098-06-20T'));
      expect(
        args['matchDateTimeComponents'],
        DateTimeComponents.dateAndTime.index,
      );
    });

    test('custom contact event reminder text explains tomorrow', () async {
      notificationProvider = NotificationProvider(
        now: () => DateTime(2098, 6, 19, 9),
      );

      await notificationProvider.scheduleContactEventNotifications([
        Contact(
          id: 'contact-1',
          fields: {
            AppKeys.name: 'Alex',
            'Anniversary': {
              'date': '20.06.0000',
              'remindYearly': true,
              'remindBefore': ['day'],
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
      expect(args['body'], 'Tomorrow: Anniversary for Alex.');
    });

    test(
      'missed same-day yearly reminders wait for the next yearly slot',
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

        expect(scheduleCalls, hasLength(1));

        final yearlyArgs =
            scheduleCalls.single.arguments as Map<dynamic, dynamic>;

        expect(yearlyArgs['scheduledDateTime'], startsWith('2099-06-14T'));
        expect(yearlyArgs['body'], "Today is Alex's birthday. Alex turns 109.");
        expect(
          yearlyArgs['matchDateTimeComponents'],
          DateTimeComponents.dateAndTime.index,
        );
        expect(
          notificationCalls.where((call) => call.method == 'show'),
          isEmpty,
        );
      },
    );

    test(
      'changing reminder time catches up a missed same-day reminder once',
      () async {
        notificationProvider = NotificationProvider(
          now: () => DateTime(2098, 6, 14, 10, 30),
        );
        final contacts = [
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
        ];

        await notificationProvider.scheduleContactEventNotifications(contacts);
        notificationCalls.clear();

        await notificationProvider.setReminderTime(
          const TimeOfDay(hour: 10, minute: 0),
        );

        final showCalls = notificationCalls
            .where((call) => call.method == 'show')
            .toList();
        expect(showCalls, hasLength(1));

        final showArgs = showCalls.single.arguments as Map<dynamic, dynamic>;
        expect(showArgs['title'], 'Birthday - Alex');
        expect(showArgs['body'], "Today is Alex's birthday. Alex turns 108.");

        final scheduleCalls = notificationCalls
            .where((call) => call.method == 'zonedSchedule')
            .toList();
        expect(scheduleCalls, hasLength(1));
        final scheduleArgs =
            scheduleCalls.single.arguments as Map<dynamic, dynamic>;
        expect(scheduleArgs['scheduledDateTime'], startsWith('2099-06-14T'));

        notificationCalls.clear();

        await notificationProvider.setReminderTime(
          const TimeOfDay(hour: 9, minute: 45),
        );

        expect(
          notificationCalls.where((call) => call.method == 'show'),
          isEmpty,
        );
      },
    );

    test('changing reminder time does not catch up stale reminders', () async {
      notificationProvider = NotificationProvider(
        now: () => DateTime(2098, 6, 15, 10, 30),
      );
      final contacts = [
        Contact(
          id: 'contact-1',
          fields: {
            AppKeys.name: 'Alex',
            'Anniversary': {
              'date': '14.06.2098',
              'remindYearly': false,
              'remindBefore': ['today'],
            },
          },
        ),
      ];

      await notificationProvider.scheduleContactEventNotifications(contacts);
      notificationCalls.clear();

      await notificationProvider.setReminderTime(
        const TimeOfDay(hour: 10, minute: 0),
      );

      expect(notificationCalls.where((call) => call.method == 'show'), isEmpty);
      expect(
        notificationCalls.where((call) => call.method == 'zonedSchedule'),
        isEmpty,
      );
    });

    test(
      'changing reminder time catches up on the next contact sync if needed',
      () async {
        notificationProvider = NotificationProvider(
          now: () => DateTime(2098, 6, 14, 10, 30),
        );
        final contacts = [
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
        ];

        await notificationProvider.setReminderTime(
          const TimeOfDay(hour: 10, minute: 0),
        );

        expect(
          notificationCalls.where((call) => call.method == 'show'),
          isEmpty,
        );
        notificationCalls.clear();

        await notificationProvider.scheduleContactEventNotifications(
          const <Contact>[],
        );

        expect(
          notificationCalls.where((call) => call.method == 'show'),
          isEmpty,
        );
        notificationCalls.clear();

        await notificationProvider.scheduleContactEventNotifications(contacts);

        expect(
          notificationCalls.where((call) => call.method == 'show'),
          hasLength(1),
        );

        notificationCalls.clear();

        await notificationProvider.scheduleContactEventNotifications(contacts);

        expect(
          notificationCalls.where((call) => call.method == 'show'),
          isEmpty,
        );
      },
    );
  });
}
