class CalendarEvent {
  final String contactId;
  final String contactName;
  final String fieldName;
  final DateTime date;
  final bool isBirthday;
  final bool remindYearly;
  final List<String> remindBefore;
  final int? age;

  CalendarEvent({
    required this.contactId,
    required this.contactName,
    required this.fieldName,
    required this.date,
    this.isBirthday = false,
    this.remindYearly = false,
    this.remindBefore = const ['day'],
    this.age,
  });
}
