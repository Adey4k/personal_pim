import '../utils/constants.dart';

enum FieldType { text, number, date, boolean }

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

  static List<String> parseGroups(String? groupsStr) {
    if (groupsStr == null || groupsStr.isEmpty) return [];
    return groupsStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }
}