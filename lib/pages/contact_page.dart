import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:personal_pim/services/gemini_service.dart';
import 'package:personal_pim/services/speech_service.dart';
import '../models/contact.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/contact/dynamic_field_widget.dart';
import '../widgets/contact/intelligent_input_sheet.dart';
import '../widgets/contact/group_manager_sheet.dart';
import '../l10n/app_localizations.dart';
import '../providers/tutorial_provider.dart';

class DynamicField {
  final String id;
  final TextEditingController keyController;
  final TextEditingController valueController;
  FieldType type;
  bool isAiGenerated;
  bool remindYearly;
  List<String> remindBefore;

  DynamicField({
    required this.id,
    required String key,
    required String value,
    this.type = FieldType.text,
    this.isAiGenerated = false,
    this.remindYearly = false,
    this.remindBefore = const ['today'],
  })  : keyController = TextEditingController(text: key),
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
  final Map<String, FieldType> existingFieldTypes;
  final Contact? contact;

  const ContactPage({
    super.key,
    required this.existingFields,
    required this.existingNames,
    required this.existingGroups,
    this.existingFieldTypes = const {},
    this.contact,
  });

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final GlobalKey _aiKey = GlobalKey();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _groupInputController = TextEditingController();
  final _uuid = const Uuid();

  final List<DynamicField> _fields = [];
  final Set<String> _deletedFields = {};
  bool _showEmptyFields = true;
  bool _isNameAiGenerated = false;
  bool _isSaving = false;

  Set<String> _availableGroups = {};
  List<String> _selectedGroups = [];

  final List<MaterialColor> _availableColors = [
    Colors.blue, Colors.green, Colors.orange, Colors.purple, Colors.teal,
    Colors.pink, Colors.indigo, Colors.brown, Colors.cyan, Colors.deepOrange
  ];

  @override
  void initState() {
    super.initState();
    _availableGroups = Set.from(widget.existingGroups);

    if (widget.contact != null) {
      _nameController.text = widget.contact!.fields[AppKeys.name]?.toString() ?? "";
    }

    Set<String> allPossibleKeys = {
      AppKeys.phone, AppKeys.email, AppKeys.birthday, AppKeys.groups,
    };
    allPossibleKeys.addAll(widget.existingFields);
    if (widget.contact != null) allPossibleKeys.addAll(widget.contact!.fields.keys);
    allPossibleKeys.remove(AppKeys.name);

    Map<String, dynamic> currentValues = widget.contact?.fields ?? {};
    for (String key in allPossibleKeys) {
      dynamic val = currentValues[key];
      String valStr = "";
      bool remindYearly = false;
      List<String> remindBefore = key == AppKeys.birthday ? ["today"] : ["today"];

      if (val is Map) {
        valStr = val['date']?.toString() ?? "";
        remindYearly = val['remindYearly'] as bool? ?? (key == AppKeys.birthday);
        final rb = val['remindBefore'];
        if (rb is List) {
          remindBefore = List<String>.from(rb);
        } else if (rb is String) {
          remindBefore = [rb];
        }
      } else {
        valStr = val?.toString() ?? "";
        if (key == AppKeys.birthday) {
          remindYearly = true;
          remindBefore = ["today"];
        }
      }

      FieldType inferredType;
      
      if (key == AppKeys.birthday) {
        inferredType = FieldType.date;
      } else if (key == AppKeys.phone) {
        inferredType = FieldType.number;
      } else if (widget.existingFieldTypes.containsKey(key)) {
        inferredType = widget.existingFieldTypes[key]!;
      } else {
        inferredType = Validators.inferType(valStr);
      }

      if (key == AppKeys.groups && valStr.isNotEmpty) {
        _selectedGroups = Contact.parseGroups(valStr);
        _availableGroups.addAll(_selectedGroups);
      }
      _fields.add(DynamicField(
        id: _uuid.v4(), 
        key: key, 
        value: valStr, 
        type: inferredType,
        remindYearly: remindYearly,
        remindBefore: remindBefore,
      ));
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTutorialIfNeeded();
    });
  }

  void _startTutorialIfNeeded() {
    final tutorialProvider = Provider.of<TutorialProvider>(context, listen: false);
    if (!tutorialProvider.isContactTutorialShown) {
      ShowcaseView.get().startShowCase([_aiKey]);
      tutorialProvider.markContactTutorialAsShown();
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

  MaterialColor _getGroupColor(String groupName) => _availableColors[groupName.hashCode.abs() % _availableColors.length];

  IconData _getIconForType(FieldType type) {
    switch (type) {
      case FieldType.number: return Icons.numbers;
      case FieldType.date: return Icons.calendar_today;
      case FieldType.boolean: return Icons.check_box;
      case FieldType.text: return Icons.text_fields;
    }
  }

  Future<void> _processAiInput(String text) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final geminiService = Provider.of<GeminiService>(context, listen: false);
      final aiContact = await geminiService.processInput(text, existingGroups: _availableGroups.toList());

      bool hasUsefulData = false;

      setState(() {
        if (aiContact.name != null && aiContact.name!.isNotEmpty) {
          _nameController.text = aiContact.name!;
          _isNameAiGenerated = true;
          hasUsefulData = true;
        }

        if (aiContact.groups.isNotEmpty) {
          for (String g in aiContact.groups) {
            // Case-insensitive check for existing group
            String? existingMatch;
            try {
              existingMatch = _availableGroups.firstWhere(
                (element) => element.toLowerCase() == g.toLowerCase()
              );
            } catch (_) {}

            final groupToAdd = existingMatch ?? g;

            if (!_availableGroups.contains(groupToAdd) && _availableGroups.length < 10) {
              _availableGroups.add(groupToAdd);
            }
            if (!_selectedGroups.contains(groupToAdd) && _selectedGroups.length < 10) {
              _selectedGroups.add(groupToAdd);
            }
          }
          final gIdx = _fields.indexWhere((f) => f.keyController.text == AppKeys.groups);
          if (gIdx != -1) {
            _fields[gIdx].valueController.text = _selectedGroups.join(', ');
            _fields[gIdx].isAiGenerated = true;
            hasUsefulData = true;
          }
        }

        if (aiContact.fields.isNotEmpty) {
          for (var f in aiContact.fields) {
            final idx = _fields.indexWhere((ex) => ex.keyController.text.toLowerCase() == f.key.toLowerCase());
            if (idx != -1) {
              _fields[idx].valueController.text = f.value;
              _fields[idx].isAiGenerated = true;
              hasUsefulData = true;
            } else if (f.value.isNotEmpty) {
              _fields.add(DynamicField(id: _uuid.v4(), key: f.key, value: f.value, type: f.type, isAiGenerated: true));
              hasUsefulData = true;
            }
          }
        }
        if (hasUsefulData) _showEmptyFields = true;
      });

      if (!hasUsefulData) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.failedToRecognizeAi), backgroundColor: Colors.orange));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.recognitionError}: $e'), backgroundColor: Colors.red));
    }
  }

  void _showIntelligentInput() {
    final aiInputController = TextEditingController();
    bool isLoading = false;
    bool isListening = false;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => IntelligentInputSheet(
          aiInputController: aiInputController,
          isLoading: isLoading,
          isListening: isListening,
          onToggleListening: () async {
            if (!isListening) {
              try {
                final speechService = Provider.of<SpeechService>(context, listen: false);
                bool available = await speechService.initialize(
                  onError: (error) {
                    debugPrint('STT Error: $error');
                    if (!mounted) return;
                    setModalState(() => isListening = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.error}: ${error.errorMsg}'), backgroundColor: Colors.red),
                    );
                  },
                  onStatus: (status) {
                    debugPrint('STT Status: $status');
                    if (status == 'notListening' && mounted) {
                      setModalState(() => isListening = false);
                    }
                  },
                );

                if (available) {
                  if (!mounted) return;
                  setModalState(() => isListening = true);
                  
                  final currentContext = context;
                  if (!currentContext.mounted) return;
                  String localeId = Localizations.localeOf(currentContext).toString();
                  
                  await speechService.listen(
                    localeId: localeId,
                    onResult: (resultText) {
                      setModalState(() {
                        aiInputController.text = resultText;
                      });
                    },
                  );
                } else {
                  if (!mounted) return;
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.recognitionError), backgroundColor: Colors.red),
                    );
                  }
                }
              } catch (e) {
                if (!mounted) return;
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            } else {
              await Provider.of<SpeechService>(context, listen: false).stop();
              if (!mounted) return;
              setModalState(() => isListening = false);
            }
          },
          onProcessInput: (text) async {
            setModalState(() => isLoading = true);
            await Provider.of<SpeechService>(context, listen: false).stop();
            await _processAiInput(text);
            if (!mounted) return;
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showAddFieldDialog() {
    TextEditingController newNameController = TextEditingController();
    FieldType selectedType = FieldType.text;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        title: Text(l10n.newField),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: newNameController, 
              autofocus: true, 
              maxLength: 64,
              decoration: InputDecoration(
                hintText: l10n.fieldNameHint,
                counterText: "",
              ),
              onChanged: (val) {
                final trimmed = val.trim();
                if (widget.existingFieldTypes.containsKey(trimmed)) {
                  setDialogState(() {
                    selectedType = widget.existingFieldTypes[trimmed]!;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Text(l10n.dataType, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            DropdownButton<FieldType>(
              value: selectedType,
              isExpanded: true,
              items: [
                DropdownMenuItem(value: FieldType.text, child: Text(l10n.textType)),
                DropdownMenuItem(value: FieldType.number, child: Text(l10n.numberType)),
                DropdownMenuItem(value: FieldType.date, child: Text(l10n.dateType)),
                DropdownMenuItem(value: FieldType.boolean, child: Text(l10n.booleanType)),
              ],
              onChanged: (val) {
                if (val != null) {
                  setDialogState(() => selectedType = val);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () {
              final name = newNameController.text.trim();
              final error = Validators.validateFieldName(name);
              if (error == null) {
                setState(() {
                  _fields.add(DynamicField(id: _uuid.v4(), key: name, value: "", type: selectedType));
                  _showEmptyFields = true;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${l10n.error}: $error'), backgroundColor: Colors.red));
              }
            },
            child: Text(l10n.add),
          ),
        ],
      )),
    );
  }

  void _changeFieldType(int index) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.chooseFieldType),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: Text(l10n.textType),
              onTap: () {
                setState(() => _fields[index].type = FieldType.text);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.numbers),
              title: Text(l10n.numberType),
              onTap: () {
                setState(() => _fields[index].type = FieldType.number);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.dateType),
              onTap: () {
                setState(() => _fields[index].type = FieldType.date);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_box),
              title: Text(l10n.booleanType),
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
      ),
    );
  }

  Future<void> _confirmDeleteField(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final key = _fields[index].keyController.text.trim();
    final fieldName = key.isEmpty ? l10n.newField : AppKeys.getLocalizedLabel(key, l10n);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteFieldTitle),
        content: Text(l10n.deleteFieldConfirmation(fieldName)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    if (key.isNotEmpty) {
      setState(() => _isSaving = true);
      try {
        final dbService = Provider.of<FirestoreService>(context, listen: false);
        final usageCount = await dbService.getFieldUsageCount(key);
        
        if (usageCount > 0) {
          if (!mounted) return;
          final globalConfirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n.deleteFieldTitle),
              content: Text(l10n.deleteFieldUsageWarning(usageCount)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l10n.delete),
                ),
              ],
            ),
          );

          if (globalConfirm != true) {
            setState(() => _isSaving = false);
            return;
          }

          await dbService.deleteFieldGlobal(key);
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (key.isNotEmpty) _deletedFields.add(key);
      _fields[index].dispose();
      _fields.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.fieldDeleted)));
  }


  Future<void> _confirmDeleteContact() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteContactTitle),
        content: Text(l10n.deleteContactConfirmation(widget.contact?.name ?? l10n.noName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (result == true) {
      if (!mounted) return;
      setState(() => _isSaving = true);
      try {
        final dbService = Provider.of<FirestoreService>(context, listen: false);
        if (widget.contact?.id != null) {
          await dbService.deleteContact(widget.contact!.id!);
        }
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.contactDeleted)),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showFieldOptions(int index) async {
    FocusScope.of(context).unfocus();
    final l10n = AppLocalizations.of(context)!;
    final key = _fields[index].keyController.text;
    final isCoreField = key == AppKeys.groups || 
                        key == AppKeys.phone || 
                        key == AppKeys.email || 
                        key == AppKeys.birthday;

    final dbService = Provider.of<FirestoreService>(context, listen: false);
    int usageCount = 0;
    if (key.isNotEmpty && !isCoreField) {
      usageCount = await dbService.getFieldUsageCount(key);
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCoreField) ...[
              if (usageCount == 0)
                ListTile(
                  leading: const Icon(Icons.settings), 
                  title: Text(l10n.changeFieldType), 
                  onTap: () { Navigator.pop(context); _changeFieldType(index); }
                ),
              ListTile(leading: const Icon(Icons.edit), title: Text(l10n.rename), onTap: () { Navigator.pop(context); _renameField(index); }),
            ],
            ListTile(leading: const Icon(Icons.copy), title: Text(l10n.copyValue), onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: _fields[index].valueController.text));
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.valueCopied)));
            }),
            if (!isCoreField)
              ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: Text(l10n.delete, style: const TextStyle(color: Colors.red)), onTap: () { Navigator.pop(context); _confirmDeleteField(index); }),
          ],
        ),
      ),
    );
  }

  void _renameField(int index) {
    final l10n = AppLocalizations.of(context)!;
    final renameController = TextEditingController(text: _fields[index].keyController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.fieldName),
        content: TextField(
          controller: renameController, 
          autofocus: true, 
          maxLength: 64,
          decoration: InputDecoration(
            hintText: l10n.enterName,
            counterText: "",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _fields[index].keyController.text = renameController.text.trim();
                _fields[index].isAiGenerated = false;
              });
              Navigator.pop(context);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  Future<void> _saveContact() async {
    final l10n = AppLocalizations.of(context)!;
    final name = _nameController.text.trim();
    final nameError = Validators.validateContactName(name, widget.existingNames, widget.contact?.name);
    if (nameError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $nameError'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      Map<String, dynamic> contactData = { AppKeys.name: name };
      for (var field in _fields) {
        final key = field.keyController.text.trim();
        final value = field.valueController.text.trim();
        if (key.isNotEmpty) {
          if (value.isNotEmpty) {
            if (field.type == FieldType.date) {
              contactData[key] = {
                'date': value,
                'remindYearly': field.remindYearly,
                'remindBefore': field.remindBefore,
              };
            } else {
              contactData[key] = value;
            }
          } else if (widget.contact != null) {
            contactData[key] = FieldValue.delete();
          }
        }
      }
      if (widget.contact != null) {
        for (var key in _deletedFields) {
          contactData[key] = FieldValue.delete();
        }
      }
      final dbService = Provider.of<FirestoreService>(context, listen: false);
      final savedContact = Contact(id: widget.contact?.id, fields: contactData, orderIndex: widget.contact?.orderIndex ?? 0);
      if (widget.contact == null) {
        await dbService.addContact(savedContact);
      } else {
        await dbService.updateContact(savedContact);
      }
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.error}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showGroupEditDialog(String oldGroup, DynamicField field, StateSetter setBottomSheetState) {
    final renameCtrl = TextEditingController(text: oldGroup);
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.groupSettings, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.groupName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            TextField(
              controller: renameCtrl, 
              maxLength: 64, 
              decoration: InputDecoration(counterText: "", hintText: l10n.nameWithoutCommas),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), padding: const EdgeInsets.symmetric(vertical: 12)),
                icon: const Icon(Icons.delete_forever),
                label: Text(l10n.deleteGroupFromSystem),
                onPressed: () async {
                  Navigator.pop(ctx);
                  if (!mounted) return;
                  setState(() { _availableGroups.remove(oldGroup); _selectedGroups.remove(oldGroup); field.valueController.text = _selectedGroups.join(', '); field.isAiGenerated = false; });
                  setBottomSheetState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.groupDeleted)));
                  final dbService = Provider.of<FirestoreService>(context, listen: false);
                  await dbService.deleteGroupGlobal(oldGroup);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              final newName = renameCtrl.text.trim();
              if (newName.isEmpty || newName == oldGroup) { Navigator.pop(ctx); return; }
              if (newName.contains(',')) { 
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.groupNameNoCommas), backgroundColor: Colors.red)); 
                return; 
              }
              if (!mounted) return;
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
              setBottomSheetState(() {});
              Navigator.pop(ctx);
              final dbService = Provider.of<FirestoreService>(context, listen: false);
              await dbService.renameGroupGlobal(oldGroup, newName);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showManageGroupsBottomSheet(DynamicField field) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => GroupManagerSheet(
        availableGroups: _availableGroups,
        selectedGroups: _selectedGroups,
        groupInputController: _groupInputController,
        onAddGroup: (val, setModalState) {
          String newGroup = val.trim();
          if (newGroup.isEmpty) return;
          if (newGroup.contains(',')) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.groupNameNoCommas),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          if (!_availableGroups.contains(newGroup) && _availableGroups.length >= 10) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.max10Groups)),
            );
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
          setModalState(() {});
          _groupInputController.clear();
        },
        onToggleGroup: (group, val, setModalState) {
          setState(() {
            if (val == true) {
              if (_selectedGroups.length < 10) {
                _selectedGroups.add(group);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.max10SelectedGroups)),
                );
              }
            } else {
              _selectedGroups.remove(group);
            }
            field.valueController.text = _selectedGroups.join(', ');
            field.isAiGenerated = false;
          });
          setModalState(() {});
        },
        onEditGroup: (group, setModalState) => _showGroupEditDialog(group, field, setModalState),
        getGroupColor: _getGroupColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurface),
        actions: [
          if (widget.contact != null) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), tooltip: l10n.deleteContact, onPressed: _isSaving ? null : _confirmDeleteContact),
          if (_isSaving) const Padding(padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)))
          else TextButton(onPressed: _saveContact, child: Text(l10n.save, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))
        ],
      ),
      body: AbsorbPointer(
        absorbing: _isSaving,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: _isNameAiGenerated
                  ? Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3)
                  : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: _nameController,
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 4,
                onChanged: (_) {
                  if (_isNameAiGenerated) setState(() => _isNameAiGenerated = false);
                },
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                maxLength: 64,
                decoration: InputDecoration(
                  hintText: l10n.name,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(color: Colors.grey),
                  counterText: "",
                ),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                children: _fields.map((field) {
                  if (field.valueController.text.trim().isEmpty && !_showEmptyFields) return const SizedBox.shrink();
                  return DynamicFieldWidget(
                    key: ValueKey(field.id),
                    field: field,
                    onTapField: () => _showFieldOptions(_fields.indexOf(field)),
                    onManageGroups: () => _showManageGroupsBottomSheet(field),
                    getGroupColor: _getGroupColor,
                    getIconForType: _getIconForType,
                    onDatePicked: (picked) => setState(() { field.valueController.text = "${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}"; field.isAiGenerated = false; }),
                    onBooleanChanged: (val) => setState(() { field.valueController.text = val.toString(); field.isAiGenerated = false; }),
                    onRemindYearlyChanged: (val) => setState(() => field.remindYearly = val),
                    onWithoutYearChanged: (val) => setState(() {
                      if (val) {
                        String current = field.valueController.text;
                        if (current.length == 10) {
                          field.valueController.text = "${current.substring(0, 6)}0000";
                        }
                      } else {
                        String current = field.valueController.text;
                        if (current.length == 10 && current.endsWith('0000')) {
                          field.valueController.text = "${current.substring(0, 6)}${DateTime.now().year}";
                        }
                      }
                      field.isAiGenerated = false;
                    }),
                    onRemindBeforeChanged: (val) => setState(() => field.remindBefore = val),
                  );
                }).toList(),
              ),
            ),
            Center(child: TextButton(onPressed: () => setState(() => _showEmptyFields = !_showEmptyFields), child: Text(_showEmptyFields ? l10n.hideEmptyFields : l10n.showEmptyFields, style: const TextStyle(color: Colors.grey)))),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)))),
              child: Column(
                children: [
                  SizedBox(width: double.infinity, child: OutlinedButton.icon(onPressed: _showAddFieldDialog, icon: const Icon(Icons.add), label: Text(l10n.addField))),
                  const SizedBox(height: 8),
                  SizedBox(
                      width: double.infinity,
                      child: Showcase(
                        key: _aiKey,
                        title: l10n.onboardingIntelligentInputTitle,
                        description: l10n.onboardingIntelligentInputDesc,
                        child: ElevatedButton.icon(
                            onPressed: _showIntelligentInput,
                            icon: const Icon(Icons.auto_awesome),
                            label: Text(l10n.intelligentInput),
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.tertiary,
                                foregroundColor: Theme.of(context).colorScheme.onTertiary)),
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
