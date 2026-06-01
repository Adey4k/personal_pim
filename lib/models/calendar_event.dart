class CalendarEvent {
  final String contactId;
  final String contactName;
  final String fieldName;
  final DateTime date;
  final bool isBirthday;

  CalendarEvent({
    required this.contactId,
    required this.contactName,
    required this.fieldName,
    required this.date,
    this.isBirthday = false,
  });
}
