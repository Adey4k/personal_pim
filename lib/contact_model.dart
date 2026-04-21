class Contact {
  String? id;
  // Тепер ми зберігаємо всі поля тут (наприклад: {"Ім'я": "Максим", "Instagram": "@max"})
  Map<String, dynamic> fields;

  Contact({this.id, required this.fields});

  // Залишимо швидкий доступ до імені (щоб малювати першу літеру на аватарках)
  String get name => fields["Ім'я"]?.toString() ?? 'Без імені';

  // Перетворюємо об'єкт у формат для Firebase (просто віддаємо мапу!)
  Map<String, dynamic> toMap() {
    return fields;
  }

  // Створюємо об'єкт з даних, які прийшли від Firebase
  factory Contact.fromMap(Map<String, dynamic> map, String documentId) {
    return Contact(
      id: documentId,
      fields: map,
    );
  }
}