import 'package:personal_pim/models/contact.dart';

class AiParsedField {
  final String key;
  final String value;
  final FieldType type;

  AiParsedField({
    required this.key,
    required this.value,
    this.type = FieldType.text,
  });
}

class AiParsedContact {
  final String? name;
  final List<String> groups;
  final List<AiParsedField> fields;

  AiParsedContact({
    this.name,
    this.groups = const [],
    this.fields = const [],
  });

  factory AiParsedContact.fromJson(Map<String, dynamic> json) {
    final String? name = json['name']?.toString();
    
    final List<String> groups = [];
    if (json['groups'] != null && json['groups'] is List) {
      groups.addAll(List<String>.from(json['groups']));
    }

    final List<AiParsedField> fields = [];
    if (json['fields'] != null && json['fields'] is List) {
      for (var f in json['fields']) {
        if (f is! Map) continue;
        String key = (f['key'] ?? '').toString().toLowerCase();
        String value = (f['value'] ?? '').toString();
        String typeStr = (f['type'] ?? 'text').toString();

        if (key.contains('reason') || key.contains('analys') || key.contains('note')) continue;

        FieldType type = FieldType.text;
        if (typeStr == 'number') {
          type = FieldType.number;
        } else if (typeStr == 'date') {
          type = FieldType.date;
        } else if (typeStr == 'boolean') {
          type = FieldType.boolean;
        }

        if (value.isNotEmpty) {
          fields.add(AiParsedField(key: key, value: value, type: type));
        }
      }
    }

    return AiParsedContact(name: name, groups: groups, fields: fields);
  }
}
