import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/contact.dart';
import '../../models/todo.dart';
import '../../services/firestore_service.dart';

class TodoEditSheet extends StatefulWidget {
  final Todo? todo;
  final DateTime? initialDate;
  final Function(Todo) onSave;

  const TodoEditSheet({
    super.key,
    this.todo,
    this.initialDate,
    required this.onSave,
  });

  @override
  State<TodoEditSheet> createState() => _TodoEditSheetState();
}

class _TodoEditSheetState extends State<TodoEditSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedContactId;
  String? _selectedContactName;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );

    final initialDate =
        widget.todo?.dueDate ?? widget.initialDate ?? DateTime.now();
    _selectedDate = _dateOnly(initialDate);
    _selectedTime = widget.todo?.hasDueTime == true
        ? TimeOfDay.fromDateTime(widget.todo!.dueDate)
        : null;
    _selectedContactId = widget.todo?.contactId;
    _selectedContactName = widget.todo?.contactName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = _dateOnly(picked);
      });
    }
  }

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _pickContact() async {
    final contacts = await Provider.of<FirestoreService>(
      context,
      listen: false,
    ).getAllContacts();
    if (!mounted) return;

    final Contact? picked = await showDialog<Contact>(
      context: context,
      builder: (context) {
        String searchQuery = "";
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final filteredContacts = contacts
                .where(
                  (c) =>
                      c.name.toLowerCase().contains(searchQuery.toLowerCase()),
                )
                .toList();

            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.selectContacts),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      maxLength: 64,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.search,
                        prefixIcon: const Icon(Icons.search),
                        counterText: "",
                      ),
                      onChanged: (value) {
                        setDialogState(() => searchQuery = value);
                      },
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = filteredContacts[index];
                          return ListTile(
                            title: Text(contact.name),
                            onTap: () => Navigator.pop(context, contact),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(context, Contact(fields: {}, id: null)),
                  child: const Text("-"),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.cancel),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (picked.id == null) {
          _selectedContactId = null;
          _selectedContactName = null;
        } else {
          _selectedContactId = picked.id;
          _selectedContactName = picked.name;
        }
      });
    }
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime _selectedDueDate() {
    final time = _selectedTime;
    if (time == null) {
      return _selectedDate;
    }

    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      time.hour,
      time.minute,
    );
  }

  String _formatSelectedDate(BuildContext context) {
    return DateFormat.yMMMMd(
      Localizations.localeOf(context).toString(),
    ).format(_selectedDate);
  }

  String _formatSelectedTime(BuildContext context) {
    final time = _selectedTime;
    if (time == null) {
      return AppLocalizations.of(context)!.noDueTime;
    }

    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.todo == null ? l10n.addTodo : l10n.editTodo,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                maxLength: 64,
                decoration: InputDecoration(
                  labelText: l10n.todoTitle,
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.enterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                maxLength: 64,
                decoration: InputDecoration(
                  labelText: l10n.todoDescription,
                  border: const OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(l10n.dueDate),
                subtitle: Text(_formatSelectedDate(context)),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(l10n.dueTime),
                subtitle: Text(_formatSelectedTime(context)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedTime != null)
                      IconButton(
                        tooltip: l10n.noDueTime,
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _selectedTime = null;
                          });
                        },
                      ),
                    const Icon(Icons.access_time),
                  ],
                ),
                onTap: _pickTime,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(l10n.name),
                subtitle: Text(_selectedContactName ?? "-"),
                trailing: const Icon(Icons.person_add_outlined),
                onTap: _pickContact,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final todo = Todo(
                      id: widget.todo?.id,
                      title: _titleController.text,
                      description: _descriptionController.text,
                      dueDate: _selectedDueDate(),
                      hasDueTime: _selectedTime != null,
                      isCompleted: widget.todo?.isCompleted ?? false,
                      contactId: _selectedContactId,
                      contactName: _selectedContactName,
                    );
                    widget.onSave(todo);
                    Navigator.pop(context);
                  }
                },
                child: Text(l10n.save),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
