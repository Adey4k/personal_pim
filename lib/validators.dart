import 'contact_model.dart';

class Validators {
  // Логіка визначення типу поля на основі введеного тексту
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

  // Валідація імені (перевірка на пустий рядок та унікальність)
  static String? validateContactName(String name, Set<String> existingNames, String? currentName) {
    if (name.isEmpty) {
      return "Введіть ім'я контакту!";
    }
    // Якщо ім'я змінили і таке ім'я вже є у когось іншого — видаємо помилку
    if (name != currentName && existingNames.contains(name)) {
      return "Контакт з таким ім'ям вже існує!";
    }
    return null; // Помилок немає
  }

  // Валідація назви нової колонки/властивості
  static String? validateFieldName(String name) {
    if (name.isEmpty) {
      return "Введіть назву властивості!";
    }
    return null;
  }
}