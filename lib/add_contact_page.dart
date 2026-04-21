import 'package:flutter/material.dart';
import 'contact_model.dart';
import 'firestore_service.dart';

// Допоміжний клас для зберігання контролерів кожного рядка
class DynamicField {
  final TextEditingController keyController;
  final TextEditingController valueController;

  DynamicField({required String key, required String value})
      : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final FirestoreService _dbService = FirestoreService();

  // Початкові стандартні поля
  final List<DynamicField> _fields = [
    DynamicField(key: "Ім'я", value: ""),
    DynamicField(key: "Телефон", value: ""),
  ];

  // Метод для додавання нового порожнього рядка
  void _addField() {
    setState(() {
      _fields.add(DynamicField(key: "", value: ""));
    });
  }

  // Метод збереження
  void _saveContact() {
    Map<String, dynamic> contactData = {};
    bool hasValidName = false; // Прапорець для перевірки імені

    // Проходимось по всіх полях і збираємо ті, де ключ не порожній
    for (var field in _fields) {
      final key = field.keyController.text.trim();
      final value = field.valueController.text.trim();

      if (key.isNotEmpty) {
        contactData[key] = value;

        // Перевіряємо, чи є поле "Ім'я" і чи воно не порожнє
        if (key == "Ім'я" && value.isNotEmpty) {
          hasValidName = true;
        }
      }
    }

    // Якщо імені немає, показуємо помилку і зупиняємо збереження
    if (!hasValidName) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Помилка: Контакт повинен мати заповнене поле \"Ім'я\"!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (contactData.isNotEmpty) {
      final newContact = Contact(fields: contactData);
      _dbService.addContact(newContact);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    for (var field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новий контакт'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveContact,
            tooltip: 'Зберегти',
          )
        ],
      ),
      body: Column(
        children: [
          // Основний список полів
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _fields.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      // Колонка ключа (Назва поля)
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _fields[index].keyController,
                          decoration: const InputDecoration(
                            hintText: 'Поле',
                            border: InputBorder.none,
                            icon: Icon(Icons.label_outline, size: 20, color: Colors.grey),
                          ),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Колонка значення
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _fields[index].valueController,
                          decoration: const InputDecoration(
                            hintText: 'Порожньо',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      // Кнопка видалення (забороняємо видаляти перші 2 базові поля)
                      if (index > 1)
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _fields.removeAt(index).dispose();
                            });
                          },
                        )
                    ],
                  ),
                );
              },
            ),
          ),
          // Нижня панель з кнопками
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 8,
                  )
                ]
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addField,
                    icon: const Icon(Icons.add),
                    label: const Text('Додати поле'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Тут буде магія ШІ! ✨')),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Інтелектуальний ввід'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}