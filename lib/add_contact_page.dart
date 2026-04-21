import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ДОДАНО: Для копіювання в буфер обміну
import 'contact_model.dart';
import 'firestore_service.dart';

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
  final Set<String> existingFields;

  const AddContactPage({super.key, required this.existingFields});

  @override
  State<AddContactPage> createState() => _AddContactPageState();
}

class _AddContactPageState extends State<AddContactPage> {
  final FirestoreService _dbService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final List<DynamicField> _fields = [];

  @override
  void initState() {
    super.initState();
    Set<String> initialKeys = {"Телефон"};
    initialKeys.addAll(widget.existingFields);
    initialKeys.remove("Ім'я");

    for (String key in initialKeys) {
      _fields.add(DynamicField(key: key, value: ""));
    }
  }

  void _addField() {
    setState(() {
      _fields.add(DynamicField(key: "Нова властивість", value: ""));
    });
    // Автоматично відкриваємо вікно перейменування для щойно створеного поля
    _renameField(_fields.length - 1);
  }

  // === НОВЕ: Нижня шторка з опціями поля ===
  void _showFieldOptions(int index) {
    // Ховаємо клавіатуру, якщо вона була відкрита
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Перейменувати'),
                  onTap: () {
                    Navigator.pop(context); // Закриваємо меню
                    _renameField(index);    // Відкриваємо вікно зміни назви
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Скопіювати значення'),
                  onTap: () {
                    Navigator.pop(context);
                    // Копіюємо значення в буфер обміну
                    Clipboard.setData(ClipboardData(text: _fields[index].valueController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Значення скопійовано!')),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Видалити', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _fields[index].dispose();
                      _fields.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  // === НОВЕ: Вікно для перейменування поля ===
  void _renameField(int index) {
    TextEditingController renameController = TextEditingController(text: _fields[index].keyController.text);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Назва властивості'),
            content: TextField(
              controller: renameController,
              autofocus: true, // Одразу відкриває клавіатуру
              decoration: const InputDecoration(
                hintText: 'Введіть назву (напр. Telegram)',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Скасувати'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _fields[index].keyController.text = renameController.text.trim();
                  });
                  Navigator.pop(context);
                },
                child: const Text('Зберегти'),
              ),
            ],
          );
        }
    );
  }

  void _saveContact() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Помилка: Введіть ім'я контакту!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Map<String, dynamic> contactData = {
      "Ім'я": name,
    };

    for (var field in _fields) {
      final key = field.keyController.text.trim();
      final value = field.valueController.text.trim();

      if (key.isNotEmpty && value.isNotEmpty) {
        contactData[key] = value;
      }
    }

    final newContact = Contact(fields: contactData);
    _dbService.addContact(newContact);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var field in _fields) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          TextButton(
            onPressed: _saveContact,
            child: const Text('Зберегти', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _nameController,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                  hintText: "Ім'я",
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey)
              ),
            ),
          ),
          const Divider(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _fields.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0), // Трохи збільшив відступ для зручності
                  child: Row(
                    children: [
                      // === ОНОВЛЕНА КОЛОНКА КЛЮЧА ===
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () => _showFieldOptions(index), // Виклик меню
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.menu, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _fields[index].keyController.text.isEmpty
                                        ? 'Властивість'
                                        : _fields[index].keyController.text,
                                    style: const TextStyle(
                                      color: Colors.black, // Як ти і просив - жорстко чорний колір
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Колонка значення
                      Expanded(
                        flex: 3,
                        child: TextField(
                          controller: _fields[index].valueController,
                          decoration: const InputDecoration(
                            hintText: 'Порожньо',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _addField,
                    icon: const Icon(Icons.add),
                    label: const Text('Додати властивість'),
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