import '../models/contact.dart';

class Validators {
  static FieldType inferType(String valStr) {
    if (valStr.toLowerCase() == 'true' || valStr.toLowerCase() == 'false') {
      return FieldType.boolean;
    } else if (RegExp(r'^\d{2}\.\d{2}\.\d{4}$').hasMatch(valStr)) {
      return FieldType.date;
    } else if (RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(valStr) && valStr.trim().isNotEmpty) {
      return FieldType.number;
    }
    return FieldType.text;
  }

  static String? validateContactName(String name, Set<String> existingNames, String? currentName) {
    if (name.isEmpty) {
      return "Введіть ім'я контакту!";
    }
    if (name != currentName && existingNames.contains(name)) {
      return "Контакт з таким ім'ям вже існує!";
    }
    return null;
  }

  static String? validateFieldName(String name) {
    if (name.isEmpty) {
      return "Введіть назву властивості!";
    }
    return null;
  }
}