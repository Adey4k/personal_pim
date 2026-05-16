import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'contact_model.dart';
import 'firestore_service.dart';
import 'app_constants.dart';
import 'validators.dart';

// Класс перенесен сюда для чистоты архитектуры
class DynamicField {
  final TextEditingController keyController;
  final TextEditingController valueController;
  FieldType type;

  DynamicField({required String key, required String value, this.type = FieldType.text})
      : keyController = TextEditingController(text: key),
        valueController = TextEditingController(text: value);

  void dispose() {
    keyController.dispose();
    valueController.dispose();
  }
}

class ContactPage extends StatefulWidget {
  final Set<String> existingFields;
  final Set<String> existingNames;
  final Contact? contact;

  const ContactPage({
    super.key,
    required this.existingFields,
    required this.existingNames,
    this.contact
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final FirestoreService _dbService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final List<DynamicField> _fields = [];

  bool _showEmptyFields = true;

  @override
  void initState() {
    super.initState();

    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
    }

    Set<String> allPossibleKeys = {AppKeys.phone};
    allPossibleKeys.addAll(widget.existingFields);
    if (widget.contact != null) {
      allPossibleKeys.addAll(widget.contact!.fields.keys);
    }
    allPossibleKeys.remove(AppKeys.name);

    Map<String, dynamic> currentValues = widget.contact?.fields ?? {};

    for (String key in allPossibleKeys) {
      String valStr = currentValues[key]?.toString() ?? "";
      FieldType inferredType = Validators.inferType(valStr);
      _fields.add(DynamicField(key: key, value: valStr, type: inferredType));
    }
  }

  IconData _getIconForType(FieldType type) {
    switch (type) {
      case FieldType.number: return Icons.numbers;
      case FieldType.date: return Icons.calendar_today;
      case FieldType.boolean: return Icons.check_box;
      case FieldType.text: default: return Icons.text_fields;
    }
  }

  void _showAddFieldDialog() {
    TextEditingController newNameController = TextEditingController();
    FieldType selectedType = FieldType.text;

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setDialogState) {
                return AlertDialog(
                  title: const Text('Нова властивість'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: newNameController,
                        autofocus: true,
                        minLines: 1,
                        maxLines: 4,
                        decoration: const InputDecoration(hintText: 'Назва (напр. Telegram)'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Тип даних:', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      DropdownButton<FieldType>(
                        value: selectedType,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: FieldType.text, child: Text('Текст')),
                          DropdownMenuItem(value: FieldType.number, child: Text('Число/Телефон')),
                          DropdownMenuItem(value: FieldType.date, child: Text('Дата')),
                          DropdownMenuItem(value: FieldType.boolean, child: Text('Логічне (Так/Ні)')),
                        ],
                        onChanged: (FieldType? newValue) {
                          if (newValue != null) {
                            setDialogState(() => selectedType = newValue);
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Скасувати'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        final name = newNameController.text.trim();
                        final error = Validators.validateFieldName(name);

                        if (error == null) {
                          setState(() {
                            _fields.add(DynamicField(key: name, value: "", type: selectedType));
                            _showEmptyFields = true;
                          });
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Помилка: $error'), backgroundColor: Colors.red),
                          );
                        }
                      },
                      child: const Text('Додати'),
                    ),
                  ],
                );
              }
          );
        }
    );
  }

  void _changeFieldType(int index) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Оберіть тип властивості'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Текст'),
                  onTap: () {
                    setState(() => _fields[index].type = FieldType.text);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.numbers),
                  title: const Text('Число/Телефон'),
                  onTap: () {
                    setState(() => _fields[index].type = FieldType.number);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Дата'),
                  onTap: () {
                    setState(() => _fields[index].type = FieldType.date);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check_box),
                  title: const Text('Логічне (Так/Ні)'),
                  onTap: () {
                    setState(() {
                      _fields[index].type = FieldType.boolean;
                      if (_fields[index].valueController.text.isEmpty) {
                        _fields[index].valueController.text = "false";
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  void _confirmDeleteField(int index) {
    final fieldName = _fields[index].keyController.text.isEmpty
        ? 'Властивість'
        : _fields[index].keyController.text;

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Видалення поля'),
            content: Text('Ви впевнені, що хочете видалити поле "$fieldName" для усіх контактів?\nЦю дію неможливо скасувати.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Скасувати'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _fields[index].dispose();
                    _fields.removeAt(index);
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Поле видалено')),
                  );
                },
                child: const Text('Видалити'),
              ),
            ],
          );
        }
    );
  }

  // НОВИЙ МЕТОД: Підтвердження видалення всього контакту
  void _confirmDeleteContact() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Видалення контакту'),
            content: Text('Ви впевнені, що хочете видалити "${widget.contact?.name}"?\nЦю дію неможливо скасувати.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Скасувати'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (widget.contact?.id != null) {
                    _dbService.deleteContact(widget.contact!.id!);
                  }
                  Navigator.pop(context); // Закриваємо діалог
                  Navigator.pop(context); // Закриваємо сторінку контакту
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Контакт видалено')),
                  );
                },
                child: const Text('Видалити'),
              ),
            ],
          );
        }
    );
  }

  void _showFieldOptions(int index) {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('Змінити тип поля'),
                  onTap: () {
                    Navigator.pop(context);
                    _changeFieldType(index);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Перейменувати'),
                  onTap: () {
                    Navigator.pop(context);
                    _renameField(index);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy),
                  title: const Text('Скопіювати значення'),
                  onTap: () {
                    Navigator.pop(context);
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
                    _confirmDeleteField(index);
                  },
                ),
              ],
            ),
          );
        }
    );
  }

  void _renameField(int index) {
    TextEditingController renameController = TextEditingController(text: _fields[index].keyController.text);

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Назва властивості'),
            content: TextField(
              controller: renameController,
              autofocus: true,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Введіть назву'),
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

    final nameError = Validators.validateContactName(name, widget.existingNames, widget.contact?.name);
    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Помилка: $nameError'), backgroundColor: Colors.red),
      );
      return;
    }

    Map<String, dynamic> contactData = {
      AppKeys.name: name,
    };

    for (var field in _fields) {
      final key = field.keyController.text.trim();
      final value = field.valueController.text.trim();

      if (key.isNotEmpty && value.isNotEmpty) {
        contactData[key] = value;
      }
    }

    final savedContact = Contact(id: widget.contact?.id, fields: contactData);

    if (widget.contact == null) {
      _dbService.addContact(savedContact);
    } else {
      _dbService.updateContact(savedContact);
    }

    Navigator.pop(context);
  }

  Widget _buildDynamicInput(int index) {
    final field = _fields[index];

    switch (field.type) {
      case FieldType.number:
        return TextField(
          controller: field.valueController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          ),
        );
      case FieldType.date:
        return InkWell(
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() {
                field.valueController.text = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}";
              });
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              field.valueController.text.isEmpty ? 'Обрати дату' : field.valueController.text,
              style: TextStyle(
                color: field.valueController.text.isEmpty ? Colors.grey : Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        );
      case FieldType.boolean:
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 36,
            child: Switch(
              value: field.valueController.text == 'true',
              onChanged: (bool val) {
                setState(() {
                  field.valueController.text = val.toString();
                });
              },
            ),
          ),
        );
      case FieldType.text:
      default:
        return TextField(
          controller: field.valueController,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Текст',
            hintStyle: TextStyle(color: Colors.grey),
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0),
          ),
        );
    }
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
          // Кнопка видалення (тільки якщо контакт вже існує)
          if (widget.contact != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Видалити контакт',
              onPressed: _confirmDeleteContact,
            ),
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
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 4,
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                  hintText: AppKeys.name,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.grey)
              ),
            ),
          ),
          const Divider(),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _fields.length,
              itemBuilder: (context, index) {
                bool isEmpty = _fields[index].valueController.text.trim().isEmpty;

                if (isEmpty && !_showEmptyFields) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          onTap: () => _showFieldOptions(index),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 2.0),
                                  child: Icon(_getIconForType(_fields[index].type), size: 16, color: Colors.grey),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _fields[index].keyController.text.isEmpty
                                        ? 'Властивість'
                                        : _fields[index].keyController.text,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 3,
                        child: _buildDynamicInput(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          Center(
            child: TextButton(
              onPressed: () {
                setState(() {
                  _showEmptyFields = !_showEmptyFields;
                });
              },
              child: Text(
                _showEmptyFields ? 'Сховати пусті поля' : 'Відобразити пусті поля',
                style: const TextStyle(color: Colors.grey),
              ),
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
                    onPressed: _showAddFieldDialog,
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
                        const SnackBar(content: Text('В розробці')),
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