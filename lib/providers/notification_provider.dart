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
  static const String _contactReminderScheduledOccurrenceKeysKey =
      'contact_reminder_scheduled_occurrence_keys';
  static const String _contactReminderCatchUpKeysKey =
      'contact_reminder_catch_up_keys';
  static const int _dailyReminderId = 0;
  static const int _testNotificationId = 999;
  static const int _contactReminderIdStart = 10000;
  static const int _contactReminderCatchUpIdStart = 20000;
  static const int _maxContactReminderNotifications = 500;
  static const int _maxContactReminderCatchUpNotifications = 10;
  static const int _maxStoredContactReminderCatchUpKeys = 500;

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
      await scheduleContactEventNotifications(
        _lastContactReminderSnapshot,
        allowCatchUp: true,
      );
    }
  }

  Future<void> scheduleContactEventNotifications(
    List<Contact> contacts, {
    bool allowCatchUp = true,
  }) async {
    _lastContactReminderSnapshot = List<Contact>.unmodifiable(contacts);

    try {
      final prefs = await SharedPreferences.getInstance();
      final previouslyScheduledOccurrenceKeys =
          _storedContactReminderScheduledOccurrenceKeys(prefs);
      await _cancelStoredContactReminderNotifications(prefs);

      final lang = _supportedLanguageCode(prefs.getString('selected_language'));
      final l10n = await AppLocalizations.delegate.load(Locale(lang));
      await initializeDateFormatting(lang);
      final schedules = _buildContactReminderSchedules(contacts, l10n, lang);
      final catchUpSchedules = allowCatchUp
          ? _buildContactReminderCatchUpSchedules(
              contacts,
              l10n,
              lang,
              previouslyScheduledOccurrenceKeys,
            )
          : const <_ContactReminderSchedule>[];
      final scheduledIds = <String>[];
      final scheduledOccurrenceKeys = <String>[];

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
          scheduledOccurrenceKeys.add(schedule.occurrenceKey);
        } catch (e) {
          debugPrint('Error scheduling contact reminder "$id": $e');
        }
      }

      await prefs.setStringList(_contactReminderIdsKey, scheduledIds);
      await prefs.setStringList(
        _contactReminderScheduledOccurrenceKeysKey,
        scheduledOccurrenceKeys,
      );
      await _showContactReminderCatchUps(prefs, catchUpSchedules);
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

  Set<String> _storedContactReminderScheduledOccurrenceKeys(
    SharedPreferences prefs,
  ) {
    final storedKeys =
        prefs.getStringList(_contactReminderScheduledOccurrenceKeysKey) ??
        const <String>[];
    return storedKeys.toSet();
  }

  Future<void> _showContactReminderCatchUps(
    SharedPreferences prefs,
    List<_ContactReminderSchedule> schedules,
  ) async {
    if (schedules.isEmpty) return;

    final storedKeys = prefs.getStringList(_contactReminderCatchUpKeysKey);
    final shownKeys = List<String>.from(storedKeys ?? const <String>[]);
    final shownKeySet = shownKeys.toSet();
    var shownCount = 0;

    for (final schedule in schedules) {
      if (shownCount >= _maxContactReminderCatchUpNotifications) break;
      if (shownKeySet.contains(schedule.catchUpKey)) continue;

      final id =
          _contactReminderCatchUpIdStart +
          (shownKeys.length % _maxContactReminderNotifications);

      try {
        await _notificationService.showContactReminderNow(
          id: id,
          title: schedule.title,
          body: schedule.body,
        );
        shownKeys.add(schedule.catchUpKey);
        shownKeySet.add(schedule.catchUpKey);
        shownCount++;
      } catch (e) {
        debugPrint('Error showing contact reminder catch-up "$id": $e');
      }
    }

    if (shownCount == 0) return;

    if (shownKeys.length > _maxStoredContactReminderCatchUpKeys) {
      shownKeys.removeRange(
        0,
        shownKeys.length - _maxStoredContactReminderCatchUpKeys,
      );
    }

    await prefs.setStringList(_contactReminderCatchUpKeysKey, shownKeys);
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
          final occurrence = dateField.remindYearly
              ? _nextYearlyReminderOccurrence(dateField, reminderKey, now)
              : _oneTimeReminderOccurrence(dateField, reminderKey, now);

          if (occurrence == null) continue;

          schedules.add(
            _buildContactReminderSchedule(
              contact: contact,
              fieldKey: field.key,
              dateField: dateField,
              reminderKey: reminderKey,
              occurrence: occurrence,
              l10n: l10n,
              localeName: localeName,
            ),
          );
        }
      }
    }

    schedules.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return schedules;
  }

  List<_ContactReminderSchedule> _buildContactReminderCatchUpSchedules(
    List<Contact> contacts,
    AppLocalizations l10n,
    String localeName,
    Set<String> previouslyScheduledOccurrenceKeys,
  ) {
    final now = _now();
    final schedules = <_ContactReminderSchedule>[];

    for (final contact in contacts) {
      for (final field in contact.fields.entries) {
        final dateField = _parseContactDateField(field.key, field.value);
        if (dateField == null || dateField.remindBefore.isEmpty) continue;

        for (final reminderKey in dateField.remindBefore.toSet()) {
          final occurrence = dateField.remindYearly
              ? _sameDayYearlyCatchUpOccurrence(dateField, reminderKey, now)
              : _sameDayOneTimeCatchUpOccurrence(dateField, reminderKey, now);

          if (occurrence == null) continue;

          final schedule = _buildContactReminderSchedule(
            contact: contact,
            fieldKey: field.key,
            dateField: dateField,
            reminderKey: reminderKey,
            occurrence: occurrence,
            l10n: l10n,
            localeName: localeName,
          );

          if (previouslyScheduledOccurrenceKeys.contains(
            schedule.occurrenceKey,
          )) {
            continue;
          }

          schedules.add(schedule);
        }
      }
    }

    schedules.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
    return schedules;
  }

  _ContactReminderSchedule _buildContactReminderSchedule({
    required Contact contact,
    required String fieldKey,
    required _ContactDateField dateField,
    required String reminderKey,
    required _ReminderOccurrence occurrence,
    required AppLocalizations l10n,
    required String localeName,
  }) {
    final fieldLabel = fieldKey == AppKeys.birthday
        ? l10n.birthdayEvent
        : AppKeys.getLocalizedLabel(fieldKey, l10n);
    final isBirthday = fieldKey == AppKeys.birthday;

    return _ContactReminderSchedule(
      title: '$fieldLabel - ${contact.name}',
      body: _buildReminderBody(
        contactName: contact.name,
        fieldLabel: fieldLabel,
        eventDate: occurrence.eventDate,
        scheduledDate: occurrence.scheduledDate,
        originalYear: dateField.year,
        repeatsYearly: dateField.remindYearly,
        isBirthday: isBirthday,
        localeName: localeName,
      ),
      scheduledDate: occurrence.scheduledDate,
      repeatsYearly: occurrence.repeatsYearly,
      occurrenceKey: _contactReminderOccurrenceKey(
        contact: contact,
        fieldKey: fieldKey,
        dateField: dateField,
        reminderKey: reminderKey,
        occurrence: occurrence,
      ),
      catchUpKey: _contactReminderCatchUpKey(
        contact: contact,
        fieldKey: fieldKey,
        dateField: dateField,
        reminderKey: reminderKey,
        occurrence: occurrence,
      ),
    );
  }

  Future<void> _cancelUnconfiguredNotifications() async {
    await _notificationService.cancel(_dailyReminderId);
    await _notificationService.cancel(_testNotificationId);
  }

  String _buildReminderBody({
    required String contactName,
    required String fieldLabel,
    required DateTime eventDate,
    required DateTime scheduledDate,
    required int originalYear,
    required bool repeatsYearly,
    required bool isBirthday,
    required String localeName,
  }) {
    final formatter = repeatsYearly
        ? DateFormat.MMMMd(localeName)
        : DateFormat.yMMMMd(localeName);
    final eventDateText = formatter.format(eventDate);
    final daysUntil = _dateOnly(
      eventDate,
    ).difference(_dateOnly(scheduledDate)).inDays.clamp(0, 100000).toInt();
    final age = isBirthday && originalYear > 0
        ? eventDate.year - originalYear
        : null;

    switch (_languageCode(localeName)) {
      case 'de':
        return isBirthday
            ? _buildGermanBirthdayBody(
                contactName,
                eventDateText,
                daysUntil,
                age,
              )
            : _buildGermanEventBody(
                contactName,
                fieldLabel,
                eventDateText,
                daysUntil,
              );
      case 'es':
        return isBirthday
            ? _buildSpanishBirthdayBody(
                contactName,
                eventDateText,
                daysUntil,
                age,
              )
            : _buildSpanishEventBody(
                contactName,
                fieldLabel,
                eventDateText,
                daysUntil,
              );
      case 'fr':
        return isBirthday
            ? _buildFrenchBirthdayBody(
                contactName,
                eventDateText,
                daysUntil,
                age,
              )
            : _buildFrenchEventBody(
                contactName,
                fieldLabel,
                eventDateText,
                daysUntil,
              );
      case 'pl':
        return isBirthday
            ? _buildPolishBirthdayBody(
                contactName,
                eventDateText,
                daysUntil,
                age,
              )
            : _buildPolishEventBody(
                contactName,
                fieldLabel,
                eventDateText,
                daysUntil,
              );
      case 'uk':
        return isBirthday
            ? _buildUkrainianBirthdayBody(
                contactName,
                eventDateText,
                daysUntil,
                age,
              )
            : _buildUkrainianEventBody(
                contactName,
                fieldLabel,
                eventDateText,
                daysUntil,
              );
      default:
        return isBirthday
            ? _buildEnglishBirthdayBody(
                contactName,
                eventDateText,
                daysUntil,
                age,
              )
            : _buildEnglishEventBody(
                contactName,
                fieldLabel,
                eventDateText,
                daysUntil,
              );
    }
  }

  String _buildEnglishBirthdayBody(
    String contactName,
    String eventDateText,
    int daysUntil,
    int? age,
  ) {
    final ageText = age == null ? '' : ' $contactName turns $age.';
    if (daysUntil == 0) return "Today is $contactName's birthday.$ageText";
    if (daysUntil == 1) return "Tomorrow is $contactName's birthday.$ageText";
    if (daysUntil <= 14) {
      return "In $daysUntil days, $contactName has a birthday.$ageText";
    }
    return "$contactName's birthday is on $eventDateText.$ageText";
  }

  String _buildEnglishEventBody(
    String contactName,
    String fieldLabel,
    String eventDateText,
    int daysUntil,
  ) {
    if (daysUntil == 0) return 'Today: $fieldLabel for $contactName.';
    if (daysUntil == 1) return 'Tomorrow: $fieldLabel for $contactName.';
    if (daysUntil <= 14) {
      return 'In $daysUntil days: $fieldLabel for $contactName.';
    }
    return '$fieldLabel for $contactName is on $eventDateText.';
  }

  String _buildGermanBirthdayBody(
    String contactName,
    String eventDateText,
    int daysUntil,
    int? age,
  ) {
    final ageText = age == null ? '' : ' $contactName wird $age.';
    if (daysUntil == 0) return 'Heute hat $contactName Geburtstag.$ageText';
    if (daysUntil == 1) return 'Morgen hat $contactName Geburtstag.$ageText';
    if (daysUntil <= 14) {
      return 'In $daysUntil Tagen hat $contactName Geburtstag.$ageText';
    }
    return '$contactName hat am $eventDateText Geburtstag.$ageText';
  }

  String _buildGermanEventBody(
    String contactName,
    String fieldLabel,
    String eventDateText,
    int daysUntil,
  ) {
    if (daysUntil == 0) return 'Heute: $fieldLabel für $contactName.';
    if (daysUntil == 1) return 'Morgen: $fieldLabel für $contactName.';
    if (daysUntil <= 14) {
      return 'In $daysUntil Tagen: $fieldLabel für $contactName.';
    }
    return '$fieldLabel für $contactName ist am $eventDateText.';
  }

  String _buildSpanishBirthdayBody(
    String contactName,
    String eventDateText,
    int daysUntil,
    int? age,
  ) {
    final ageText = age == null ? '' : ' $contactName cumple $age.';
    if (daysUntil == 0) return 'Hoy es el cumpleaños de $contactName.$ageText';
    if (daysUntil == 1) {
      return 'Mañana es el cumpleaños de $contactName.$ageText';
    }
    if (daysUntil <= 14) {
      return 'En $daysUntil días es el cumpleaños de $contactName.$ageText';
    }
    return 'El cumpleaños de $contactName es el $eventDateText.$ageText';
  }

  String _buildSpanishEventBody(
    String contactName,
    String fieldLabel,
    String eventDateText,
    int daysUntil,
  ) {
    if (daysUntil == 0) return 'Hoy: $fieldLabel de $contactName.';
    if (daysUntil == 1) return 'Mañana: $fieldLabel de $contactName.';
    if (daysUntil <= 14) {
      return 'En $daysUntil días: $fieldLabel de $contactName.';
    }
    return '$fieldLabel de $contactName es el $eventDateText.';
  }

  String _buildFrenchBirthdayBody(
    String contactName,
    String eventDateText,
    int daysUntil,
    int? age,
  ) {
    final ageText = age == null ? '' : ' $contactName fête ses $age ans.';
    if (daysUntil == 0) {
      return "Aujourd'hui, c'est l'anniversaire de $contactName.$ageText";
    }
    if (daysUntil == 1) {
      return "Demain, c'est l'anniversaire de $contactName.$ageText";
    }
    if (daysUntil <= 14) {
      return "Dans $daysUntil jours, c'est l'anniversaire de $contactName.$ageText";
    }
    return "L'anniversaire de $contactName est le $eventDateText.$ageText";
  }

  String _buildFrenchEventBody(
    String contactName,
    String fieldLabel,
    String eventDateText,
    int daysUntil,
  ) {
    if (daysUntil == 0) return "Aujourd'hui : $fieldLabel pour $contactName.";
    if (daysUntil == 1) return 'Demain : $fieldLabel pour $contactName.';
    if (daysUntil <= 14) {
      return 'Dans $daysUntil jours : $fieldLabel pour $contactName.';
    }
    return '$fieldLabel pour $contactName est le $eventDateText.';
  }

  String _buildPolishBirthdayBody(
    String contactName,
    String eventDateText,
    int daysUntil,
    int? age,
  ) {
    final ageText = age == null ? '' : ' $contactName kończy $age lat.';
    if (daysUntil == 0) return 'Dzisiaj $contactName ma urodziny.$ageText';
    if (daysUntil == 1) return 'Jutro $contactName ma urodziny.$ageText';
    if (daysUntil <= 14) {
      return 'Za $daysUntil ${_polishDayWord(daysUntil)} $contactName ma urodziny.$ageText';
    }
    return '$contactName ma urodziny $eventDateText.$ageText';
  }

  String _buildPolishEventBody(
    String contactName,
    String fieldLabel,
    String eventDateText,
    int daysUntil,
  ) {
    if (daysUntil == 0) return 'Dzisiaj: $fieldLabel u $contactName.';
    if (daysUntil == 1) return 'Jutro: $fieldLabel u $contactName.';
    if (daysUntil <= 14) {
      return 'Za $daysUntil ${_polishDayWord(daysUntil)}: $fieldLabel u $contactName.';
    }
    return '$fieldLabel u $contactName jest $eventDateText.';
  }

  String _buildUkrainianBirthdayBody(
    String contactName,
    String eventDateText,
    int daysUntil,
    int? age,
  ) {
    final ageText = age == null ? '' : ', виповнюється $age';
    if (daysUntil == 0) {
      return 'Сьогодні у $contactName день народження$ageText.';
    }
    if (daysUntil == 1) {
      return 'Завтра у $contactName день народження$ageText.';
    }
    if (daysUntil <= 14) {
      return 'Через $daysUntil ${_ukrainianDayWord(daysUntil)} у $contactName день народження$ageText.';
    }
    return 'У $contactName день народження $eventDateText$ageText.';
  }

  String _buildUkrainianEventBody(
    String contactName,
    String fieldLabel,
    String eventDateText,
    int daysUntil,
  ) {
    if (daysUntil == 0) return 'Сьогодні у $contactName: $fieldLabel.';
    if (daysUntil == 1) return 'Завтра у $contactName: $fieldLabel.';
    if (daysUntil <= 14) {
      return 'Через $daysUntil ${_ukrainianDayWord(daysUntil)} у $contactName: $fieldLabel.';
    }
    return 'У $contactName подія "$fieldLabel" $eventDateText.';
  }

  String _languageCode(String localeName) {
    return localeName.split(RegExp(r'[-_]')).first.toLowerCase();
  }

  String _ukrainianDayWord(int days) {
    final mod10 = days % 10;
    final mod100 = days % 100;
    if (mod10 == 1 && mod100 != 11) return 'день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'дні';
    }
    return 'днів';
  }

  String _polishDayWord(int days) {
    return days == 1 ? 'dzień' : 'dni';
  }

  String _supportedLanguageCode(String? languageCode) {
    if (['de', 'en', 'es', 'fr', 'pl', 'uk'].contains(languageCode)) {
      return languageCode!;
    }
    return 'en';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _dateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  String _dateTimeKey(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${_dateKey(date)}T$hour:$minute';
  }

  String _keyPart(Object? value) {
    return Uri.encodeComponent(value?.toString() ?? '');
  }

  String _contactReminderOccurrenceKey({
    required Contact contact,
    required String fieldKey,
    required _ContactDateField dateField,
    required String reminderKey,
    required _ReminderOccurrence occurrence,
  }) {
    final contactKey = contact.id?.isNotEmpty == true
        ? contact.id!
        : contact.name;

    return [
      'v1',
      _keyPart(contactKey),
      _keyPart(fieldKey),
      dateField.year.toString(),
      dateField.month.toString(),
      dateField.day.toString(),
      dateField.remindYearly ? 'yearly' : 'once',
      _keyPart(reminderKey),
      _dateTimeKey(occurrence.scheduledDate),
      _dateKey(occurrence.eventDate),
    ].join('|');
  }

  String _contactReminderCatchUpKey({
    required Contact contact,
    required String fieldKey,
    required _ContactDateField dateField,
    required String reminderKey,
    required _ReminderOccurrence occurrence,
  }) {
    final contactKey = contact.id?.isNotEmpty == true
        ? contact.id!
        : contact.name;

    return [
      'v1',
      _keyPart(contactKey),
      _keyPart(fieldKey),
      dateField.year.toString(),
      dateField.month.toString(),
      dateField.day.toString(),
      dateField.remindYearly ? 'yearly' : 'once',
      _keyPart(reminderKey),
      _dateKey(occurrence.scheduledDate),
      _dateKey(occurrence.eventDate),
    ].join('|');
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

    if (!scheduledDate.isAfter(now)) return null;

    return _ReminderOccurrence(
      scheduledDate: scheduledDate,
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

  _ReminderOccurrence? _sameDayOneTimeCatchUpOccurrence(
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

    if (scheduledDate.isAfter(now) || !_isSameDay(scheduledDate, now)) {
      return null;
    }

    return _ReminderOccurrence(
      scheduledDate: scheduledDate,
      eventDate: eventDate,
      repeatsYearly: false,
    );
  }

  _ReminderOccurrence? _sameDayYearlyCatchUpOccurrence(
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

      if (!_isSameDay(scheduledDate, now)) continue;
      if (scheduledDate.isAfter(now)) return null;

      return _ReminderOccurrence(
        scheduledDate: scheduledDate,
        eventDate: eventDate,
        repeatsYearly: true,
      );
    }

    return null;
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
  final String occurrenceKey;
  final String catchUpKey;

  const _ContactReminderSchedule({
    required this.title,
    required this.body,
    required this.scheduledDate,
    required this.repeatsYearly,
    required this.occurrenceKey,
    required this.catchUpKey,
  });
}
