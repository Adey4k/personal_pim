import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'contact_model.dart';
import 'firestore_service.dart';
import 'app_constants.dart';
import 'validators.dart';
import 'env.dart';

/* * Модель динамічного поля з підтримкою стану генерації ІІ.
 * isAiGenerated використовується для підсвічування поля зеленим кольором.
 */
class DynamicField {
  final TextEditingController keyController;
  final TextEditingController valueController;
  FieldType type;
  bool isAiGenerated;

  DynamicField({
    required String key,
    required String value,
    this.type = FieldType.text,
    this.isAiGenerated = false,
  })
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
  final Set<String> existingGroups;
  final Contact? contact;

  const ContactPage({
    super.key,
    required this.existingFields,
    required this.existingNames,
    required this.existingGroups,
    this.contact
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final FirestoreService _dbService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _groupInputController = TextEditingController();

  final stt.SpeechToText _speech = stt.SpeechToText();

  final List<DynamicField> _fields = [];
  bool _showEmptyFields = true;
  bool _isNameAiGenerated = false;

  Set<String> _availableGroups = {};
  List<String> _selectedGroups = [];

  final List<MaterialColor> _availableColors = [
    Colors.blue, Colors.green, Colors.orange, Colors.purple,
    Colors.teal, Colors.pink, Colors.indigo, Colors.brown,
    Colors.cyan, Colors.deepOrange
  ];

  @override
  void initState() {
    super.initState();

    _availableGroups = Set.from(widget.existingGroups);

    if (widget.contact != null) {
      _nameController.text = widget.contact!.name;
    }

    Set<String> allPossibleKeys = {
      AppKeys.phone,
      AppKeys.email,
      AppKeys.birthday,
      AppKeys.groups,
    };

    allPossibleKeys.addAll(widget.existingFields);
    if (widget.contact != null) {
      allPossibleKeys.addAll(widget.contact!.fields.keys);
    }
    allPossibleKeys.remove(AppKeys.name);

    Map<String, dynamic> currentValues = widget.contact?.fields ?? {};

    for (String key in allPossibleKeys) {
      String valStr = currentValues[key]?.toString() ?? "";
      FieldType inferredType = Validators.inferType(valStr);

      if (key == AppKeys.birthday) {
        inferredType = FieldType.date;
      }

      if (key == AppKeys.groups && valStr.isNotEmpty) {
        _selectedGroups = Contact.parseGroups(valStr);
        _availableGroups.addAll(_selectedGroups);
      }

      _fields.add(DynamicField(key: key, value: valStr, type: inferredType));
    }
  }

  MaterialColor _getGroupColor(String groupName) {
    return _availableColors[groupName.hashCode.abs() % _availableColors.length];
  }

  IconData _getIconForType(FieldType type) {
    switch (type) {
      case FieldType.number: return Icons.numbers;
      case FieldType.date: return Icons.calendar_today;
      case FieldType.boolean: return Icons.check_box;
      case FieldType.text: return Icons.text_fields;
    }
  }

  /* * Обробка тексту через Gemini API з поверненням структурованого JSON.
   */
  Future<void> _processAiInput(String text) async {
    try {
      final apiKey = Env.geminiApiKey;
      if (apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY не знайдено');
      }

      final model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'name': Schema.string(),
              'groups': Schema.array(items: Schema.string()),
              'fields': Schema.array(
                items: Schema.object(
                  properties: {
                    'key': Schema.string(),
                    'value': Schema.string(),
                    'type': Schema.string(description: 'Повертати тільки: number, date, boolean, text'),
                  },
                ),
              ),
            },
          ),
        ),
      );

      final prompt = '''
      Проаналізуй текст та витягни контактні дані.
      ПРАВИЛА, ЯКІ НЕ МОЖНА ПОРУШУВАТИ:
      1. ІМ'Я: Використовуй лише поле "name" для імені контакту. КАТЕГОРИЧНО ЗАБОРОНЕНО створювати властивості з назвою "Ім'я", "Имя", "Name", "ПІБ" у масиві fields.
      2. ВЛАСТИВОСТІ: Існуючі поля в системі: ${widget.existingFields.join(', ')}. Максимально використовуй їх. Не створюй синоніми (наприклад, якщо є "Телефон", не створюй "Мобільний" чи "Номер").
      3. ГРУПИ: Існуючі групи: ${_availableGroups.join(', ')}. Намагайся віднести контакт до однієї з існуючих груп, якщо вона підходить за змістом. НЕ створюй нові вузьконаправлені групи (наприклад, "юристи", "водії"), якщо є більш загальна існуюча група (наприклад, "Робота", "Колеги").

      Текст для аналізу: $text
      ''';

      /* * Exponential backoff retry logic.
       * Handles 503 (Service Unavailable) and 429 (Too Many Requests) errors
       * by retrying with exponentially increasing delays.
       */
      GenerateContentResponse? response;
      int maxRetries = 3;
      int delayMs = 1500;

      for (int i = 0; i < maxRetries; i++) {
        try {
          response = await model.generateContent([Content.text(prompt)]);
          break;
        } catch (e) {
          final errorStr = e.toString();
          if (errorStr.contains('503') || errorStr.contains('429')) {
            if (i == maxRetries - 1) throw Exception("Сервер перевантажений. Спробуйте пізніше.");
            await Future.delayed(Duration(milliseconds: delayMs));
            delayMs *= 2;
          } else {
            rethrow;
          }
        }
      }

      final jsonStr = response?.text;
      if (jsonStr == null) {
        throw Exception("ІІ повернув порожню відповідь");
      }

      final data = jsonDecode(jsonStr);
      bool hasUsefulData = false;

      setState(() {
        if (data['name'] != null && data['name'].toString().trim().isNotEmpty) {
          _nameController.text = data['name'];
          _isNameAiGenerated = true;
          hasUsefulData = true;
        }

        if (data['groups'] != null && (data['groups'] as List).isNotEmpty) {
          List<String> aiGroups = List<String>.from(data['groups']);
          for (String g in aiGroups) {
            if (!_availableGroups.contains(g) && _availableGroups.length < 10) _availableGroups.add(g);
            if (!_selectedGroups.contains(g) && _selectedGroups.length < 10) _selectedGroups.add(g);
          }
          final groupIdx = _fields.indexWhere((f) => f.keyController.text == AppKeys.groups);
          if (groupIdx != -1) {
            _fields[groupIdx].valueController.text = _selectedGroups.join(', ');
            _fields[groupIdx].isAiGenerated = true;
            hasUsefulData = true;
          }
        }

        if (data['fields'] != null && (data['fields'] as List).isNotEmpty) {
          for (var f in data['fields']) {
            final String key = f['key'];
            final String value = f['value'];
            final String typeStr = f['type'] ?? 'text';

            FieldType type = FieldType.text;
            if (typeStr == 'number') type = FieldType.number;
            if (typeStr == 'date') type = FieldType.date;
            if (typeStr == 'boolean') type = FieldType.boolean;

            final existingIdx = _fields.indexWhere((existing) => existing.keyController.text == key);

            if (existingIdx != -1) {
              _fields[existingIdx].valueController.text = value;
              _fields[existingIdx].isAiGenerated = true;
            } else {
              _fields.add(DynamicField(key: key, value: value, type: type, isAiGenerated: true));
            }
          }
          hasUsefulData = true;
        }

        if (hasUsefulData) {
          _showEmptyFields = true;
        }
      });

      if (!hasUsefulData && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Не вдалося розпізнати контактні дані у тексті.'),
                backgroundColor: Colors.orange
            )
        );
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Помилка розпізнавання: ${e.toString().replaceAll('Exception: ', '')}'),
                backgroundColor: Colors.red
            )
        );
      }
    }
  }

  /* * UI-компонент інтелектуального вводу (Bottom Sheet).
   */
  void _showIntelligentInput() {
    final TextEditingController aiInputController = TextEditingController();
    bool isLoading = false;
    bool isListening = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Інтелектуальний ввід', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  if (isLoading)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(color: Colors.green),
                    ))
                  else ...[
                    TextField(
                      controller: aiInputController,
                      maxLines: 6,
                      minLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Вставте скопійований текст або надиктуйте...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(isListening ? Icons.mic : Icons.mic_none, size: 32),
                          color: isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                          onPressed: () async {
                            if (!isListening) {
                              bool available = await _speech.initialize();
                              if (available) {
                                setModalState(() => isListening = true);
                                _speech.listen(
                                  localeId: 'uk-UA',
                                  onResult: (result) {
                                    setModalState(() {
                                      aiInputController.text = result.recognizedWords;
                                    });
                                  },
                                );
                              }
                            } else {
                              setModalState(() => isListening = false);
                              _speech.stop();
                            }
                          },
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () async {
                            if (aiInputController.text.trim().isEmpty) return;
                            setModalState(() {
                              isLoading = true;
                              isListening = false;
                            });
                            await _speech.stop();
                            await _processAiInput(aiInputController.text.trim());
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Розпізнати', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            );
          },
        );
      },
    );
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
                  Navigator.pop(context);
                  Navigator.pop(context);
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

    final isGroupsField = _fields[index].keyController.text == AppKeys.groups;

    showModalBottomSheet(
        context: context,
        builder: (context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isGroupsField) ...[
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
                ],
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
                if (!isGroupsField)
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
                    _fields[index].isAiGenerated = false;
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

      if (key.isNotEmpty) {
        if (value.isNotEmpty) {
          contactData[key] = value;
        } else if (widget.contact != null && widget.contact!.fields.containsKey(key)) {
          contactData[key] = FieldValue.delete();
        }
      }
    }

    final savedContact = Contact(
      id: widget.contact?.id,
      fields: contactData,
      orderIndex: widget.contact?.orderIndex ?? 0,
    );

    if (widget.contact == null) {
      _dbService.addContact(savedContact);
    } else {
      _dbService.updateContact(savedContact);
    }

    Navigator.pop(context);
  }

  void _showGroupEditDialog(String oldGroup, DynamicField field, StateSetter setBottomSheetState) {
    TextEditingController renameCtrl = TextEditingController(text: oldGroup);

    showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            title: const Text('Налаштування групи', style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Назва групи', style: TextStyle(color: Colors.grey, fontSize: 12)),
                TextField(
                  controller: renameCtrl,
                  maxLength: 16,
                  decoration: const InputDecoration(
                    counterText: "",
                    hintText: "Назва без ком",
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12)
                    ),
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Видалити групу із системи'),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      setState(() {
                        _availableGroups.remove(oldGroup);
                        _selectedGroups.remove(oldGroup);
                        field.valueController.text = _selectedGroups.join(', ');
                        field.isAiGenerated = false;
                      });
                      setBottomSheetState((){});
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Групу видалено')));
                      await _dbService.deleteGroupGlobal(oldGroup);
                    },
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Скасувати')),
              ElevatedButton(
                onPressed: () async {
                  final newName = renameCtrl.text.trim();
                  if (newName.isEmpty || newName == oldGroup) {
                    Navigator.pop(ctx);
                    return;
                  }

                  if (newName.contains(',')) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Назва групи не може містити кому!'), backgroundColor: Colors.red));
                    return;
                  }

                  setState(() {
                    List<String> avail = _availableGroups.toList();
                    int iA = avail.indexOf(oldGroup);
                    if (iA != -1) avail[iA] = newName;
                    _availableGroups = avail.toSet();

                    int iS = _selectedGroups.indexOf(oldGroup);
                    if (iS != -1) _selectedGroups[iS] = newName;

                    field.valueController.text = _selectedGroups.join(', ');
                    field.isAiGenerated = false;
                  });

                  setBottomSheetState((){});
                  Navigator.pop(ctx);
                  await _dbService.renameGroupGlobal(oldGroup, newName);
                },
                child: const Text('Зберегти'),
              ),
            ],
          );
        }
    );
  }

  void _showManageGroupsBottomSheet(DynamicField field) {
    void tryAddGroup(String val, StateSetter setModalState) {
      String newGroup = val.trim();
      if (newGroup.isEmpty) return;

      if (newGroup.contains(',')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Назва групи не може містити кому!'), backgroundColor: Colors.red));
        return;
      }

      if (!_availableGroups.contains(newGroup) && _availableGroups.length >= 10) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Максимум 10 груп!')));
        return;
      }

      setState(() {
        _availableGroups.add(newGroup);
        if (!_selectedGroups.contains(newGroup) && _selectedGroups.length < 10) {
          _selectedGroups.add(newGroup);
        }
        field.valueController.text = _selectedGroups.join(', ');
        field.isAiGenerated = false;
      });
      setModalState((){});
      _groupInputController.clear();
    }

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setModalState) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 16, right: 16, top: 12,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(2))
                      ),
                      const SizedBox(height: 16),
                      const Text('Керування групами', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _groupInputController,
                              maxLength: 16,
                              decoration: InputDecoration(
                                hintText: 'Створити нову групу...',
                                counterText: '',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(color: Colors.grey.shade300)
                                ),
                              ),
                              onSubmitted: (val) => tryAddGroup(val, setModalState),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary, size: 36),
                            onPressed: () => tryAddGroup(_groupInputController.text, setModalState),
                          )
                        ],
                      ),
                      const Divider(height: 24),

                      if (_availableGroups.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Text('Поки що немає жодної групи', style: TextStyle(color: Colors.grey)),
                        ),

                      ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _availableGroups.length,
                          itemBuilder: (context, index) {
                            final group = _availableGroups.elementAt(index);
                            final isSelected = _selectedGroups.contains(group);
                            final color = _getGroupColor(group);

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Checkbox(
                                value: isSelected,
                                activeColor: color,
                                onChanged: (bool? val) {
                                  setState(() {
                                    if (val == true) {
                                      if (_selectedGroups.length < 10) {
                                        _selectedGroups.add(group);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Можна обрати не більше 10 груп')));
                                      }
                                    } else {
                                      _selectedGroups.remove(group);
                                    }
                                    field.valueController.text = _selectedGroups.join(', ');
                                    field.isAiGenerated = false;
                                  });
                                  setModalState((){});
                                },
                              ),
                              title: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: color.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: color.withValues(alpha: 0.5))
                                      ),
                                      child: Text(group, style: TextStyle(fontSize: 13, color: color.shade900, fontWeight: FontWeight.bold)),
                                    ),
                                  ]
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                tooltip: 'Налаштувати',
                                onPressed: () => _showGroupEditDialog(group, field, setModalState),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              }
          );
        }
    );
  }

  Widget _buildDynamicInput(int index) {
    final field = _fields[index];

    if (field.keyController.text == AppKeys.groups) {
      return InkWell(
        onTap: () => _showManageGroupsBottomSheet(field),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _selectedGroups.isEmpty
              ? const Text('Натисніть, щоб обрати...', style: TextStyle(color: Colors.grey, fontSize: 16))
              : Wrap(
            spacing: 6.0,
            runSpacing: 6.0,
            children: _selectedGroups.map((group) {
              final color = _getGroupColor(group);
              return Chip(
                label: Text(group, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color.shade900)),
                backgroundColor: color.withValues(alpha: 0.2),
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                visualDensity: VisualDensity.compact,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 0.0),
              );
            }).toList(),
          ),
        ),
      );
    }

    switch (field.type) {
      case FieldType.number:
        return TextField(
          controller: field.valueController,
          keyboardType: TextInputType.phone,
          onChanged: (_) => setState(() => field.isAiGenerated = false),
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
                field.isAiGenerated = false;
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
                  field.isAiGenerated = false;
                });
              },
            ),
          ),
        );
      case FieldType.text:
        return TextField(
          controller: field.valueController,
          keyboardType: TextInputType.multiline,
          minLines: 1,
          maxLines: 4,
          onChanged: (_) => setState(() => field.isAiGenerated = false),
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
    _groupInputController.dispose();
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
          Container(
            color: _isNameAiGenerated ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _nameController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 4,
              onChanged: (_) => setState(() => _isNameAiGenerated = false),
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
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _fields.length,
              itemBuilder: (context, index) {
                bool isEmpty = _fields[index].valueController.text.trim().isEmpty;

                if (isEmpty && !_showEmptyFields) {
                  return const SizedBox.shrink();
                }

                return Container(
                  color: _fields[index].isAiGenerated ? Colors.green.withValues(alpha: 0.1) : Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
                                    child: Icon(
                                      _fields[index].keyController.text == AppKeys.groups
                                          ? Icons.label_outline
                                          : _getIconForType(_fields[index].type),
                                      size: 16,
                                      color: Colors.grey,
                                    ),
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
                    onPressed: _showIntelligentInput,
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Інтелектуальний ввід'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
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