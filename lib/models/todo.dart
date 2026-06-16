import 'package:cloud_firestore/cloud_firestore.dart';

class Todo {
  final String? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool hasDueTime;
  final bool isCompleted;
  final String? contactId;
  final String? contactName;

  Todo({
    this.id,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.hasDueTime = false,
    this.isCompleted = false,
    this.contactId,
    this.contactName,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'dueDate': Timestamp.fromDate(dueDate),
      'hasDueTime': hasDueTime,
      'isCompleted': isCompleted,
      'contactId': contactId,
      'contactName': contactName,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map, String id) {
    final dueDate = (map['dueDate'] as Timestamp).toDate();
    final hasDueTime =
        map['hasDueTime'] as bool? ??
        dueDate.hour != 0 ||
            dueDate.minute != 0 ||
            dueDate.second != 0 ||
            dueDate.millisecond != 0 ||
            dueDate.microsecond != 0;

    return Todo(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate: dueDate,
      hasDueTime: hasDueTime,
      isCompleted: map['isCompleted'] ?? false,
      contactId: map['contactId'],
      contactName: map['contactName'],
    );
  }

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? hasDueTime,
    bool? isCompleted,
    String? contactId,
    String? contactName,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      hasDueTime: hasDueTime ?? this.hasDueTime,
      isCompleted: isCompleted ?? this.isCompleted,
      contactId: contactId ?? this.contactId,
      contactName: contactName ?? this.contactName,
    );
  }
}
