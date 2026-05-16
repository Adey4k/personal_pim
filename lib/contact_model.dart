import 'package:flutter/material.dart';
import 'app_constants.dart';

enum FieldType { text, number, date, boolean }

class DynamicField {
  final TextEditingController keyController;
  final TextEditingController valueController;
  FieldType type;

  DynamicField({required String key, required String value, this.type = FieldType.text})
      : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class Contact {
  String? id;
  Map<String, dynamic> fields;
  int orderIndex;

  Contact({this.id, required this.fields, this.orderIndex = 0});

  String get name => fields[AppKeys.name]?.toString() ?? 'Без імені';

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>.from(fields);
    map[AppKeys.orderIndex] = orderIndex;
    return map;
  }

  factory Contact.fromMap(Map<String, dynamic> map, String documentId) {
    int orderIndex = map[AppKeys.orderIndex] as int? ?? 0;

    final fieldsMap = Map<String, dynamic>.from(map);
    fieldsMap.remove(AppKeys.orderIndex);

    return Contact(
      id: documentId,
      fields: fieldsMap,
      orderIndex: orderIndex,
    );
  }
}