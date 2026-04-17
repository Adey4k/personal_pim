import 'package:flutter/material.dart';
import 'contact_model.dart';
import 'firestore_service.dart';

class AddContactPage extends StatefulWidget {
  const AddContactPage({super.key});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  // Контроллеры для считывания текста из полей ввода
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  // Создаем экземпляр нашего сервиса базы данных
  final FirestoreService _dbService = FirestoreService();

  void _saveContact() {
    final String name = _nameController.text.trim();
    final String phone = _phoneController.text.trim();

    if (name.isNotEmpty && phone.isNotEmpty) {
      // 1. Создаем объект контакта
      final newContact = Contact(name: name, phone: phone);

      // 2. Отправляем в базу
      _dbService.addContact(newContact);

      // 3. Закрываем экран и возвращаемся назад
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Очищаем память, когда закрываем экран
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Додати контакт'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Ім'я",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Телефон',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveContact,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50), // Широкая кнопка
              ),
              child: const Text('Зберегти', style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}