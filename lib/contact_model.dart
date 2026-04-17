class Contact {
  String? id; // ID в базі даних (може бути null, поки не зберегли)
  final String name;
  final String phone;

  Contact({this.id, required this.name, required this.phone});

  //Перетворюємо об'єкт в формат, який розуміє Firebase (Словник/Map)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
    };
  }

  //Створюємо об'єкт контакта з даних, що прийшли з Firebase
  factory Contact.fromMap(Map<String, dynamic> map, String documentId) {
    return Contact(
      id: documentId,
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
    );
  }
}