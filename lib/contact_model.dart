class Contact {
  String? id;
  Map<String, dynamic> fields;
  int orderIndex; // Нове поле для збереження порядку

  Contact({this.id, required this.fields, this.orderIndex = 0});

  String get name => fields["Ім'я"]?.toString() ?? 'Без імені';

  Map<String, dynamic> toMap() {
    // Копіюємо всі поля і додаємо orderIndex для бази даних
    final map = Map<String, dynamic>.from(fields);
    map['orderIndex'] = orderIndex;
    return map;
  }

  factory Contact.fromMap(Map<String, dynamic> map, String documentId) {
    // Витягуємо orderIndex, якщо він є (для старих записів буде 0)
    int orderIndex = map['orderIndex'] as int? ?? 0;

    // Створюємо копію полів, але видаляємо orderIndex,
    // щоб він не відображався як звичайна властивість контакту
    final fieldsMap = Map<String, dynamic>.from(map);
    fieldsMap.remove('orderIndex');

    return Contact(
      id: documentId,
      fields: fieldsMap,
      orderIndex: orderIndex, // Зберігаємо окремо
    );
  }
}