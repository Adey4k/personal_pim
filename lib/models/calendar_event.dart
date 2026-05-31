class CalendarEvent {
  final String contactName;
  final String fieldName;
  final DateTime date;
  final bool isBirthday;

  CalendarEvent({
    required this.contactName,
    required this.fieldName,
    required this.date,
    this.isBirthday = false,
  });
}
