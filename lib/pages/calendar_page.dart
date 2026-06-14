import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../models/contact.dart';
import '../models/calendar_event.dart';
import '../models/todo.dart';
import '../services/firestore_service.dart';
import '../pages/contact_page.dart';
import '../widgets/todo/todo_edit_sheet.dart';
import '../utils/constants.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late final FirestoreService _dbService;
  late final Stream<List<Contact>> _contactsStream;
  late final Stream<List<Todo>> _todosStream;

  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
    _dbService = Provider.of<FirestoreService>(context, listen: false);
    _contactsStream = _dbService.getContactsStream();
    _todosStream = _dbService.getTodosStream();
  }

  List<dynamic> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<dynamic>> events,
  ) {
    final date = DateTime(day.year, day.month, day.day);
    final recurringDate = DateTime(0, day.month, day.day);

    final List<dynamic> dayEvents = [];
    if (events.containsKey(date)) dayEvents.addAll(events[date]!);
    if (events.containsKey(recurringDate)) {
      dayEvents.addAll(events[recurringDate]!);
    }

    return dayEvents;
  }

  Map<DateTime, List<dynamic>> _parseToEvents(
    List<Contact> contacts,
    List<Todo> todos,
  ) {
    debugPrint(
      "Parsing events: ${contacts.length} contacts, ${todos.length} todos",
    );
    final Map<DateTime, List<dynamic>> newEvents = {};

    // Parse Contacts
    final dateRegex = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$');
    for (var contact in contacts) {
      contact.fields.forEach((key, value) {
        String valStr = "";
        bool remindYearly = key == AppKeys.birthday;
        List<String> remindBefore = ["day"];

        if (value is Map) {
          valStr = value['date']?.toString() ?? "";
          remindYearly =
              value['remindYearly'] as bool? ?? (key == AppKeys.birthday);
          final rb = value['remindBefore'];
          if (rb is List) {
            remindBefore = List<String>.from(rb);
          } else if (rb is String) {
            remindBefore = [rb];
          }
        } else {
          valStr = value.toString();
        }

        final match = dateRegex.firstMatch(valStr);
        if (match != null) {
          final day = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final year = int.parse(match.group(3)!);

          final eventDate = DateTime(year, month, day);
          final isBirthday = key == AppKeys.birthday;

          int? calculatedAge;
          if (year != 0) {
            calculatedAge = DateTime.now().year - year;
          }

          final event = CalendarEvent(
            contactId: contact.id ?? "",
            contactName: contact.name,
            fieldName: key,
            date: eventDate,
            isBirthday: isBirthday,
            remindYearly: remindYearly,
            remindBefore: remindBefore,
            age: calculatedAge,
          );

          if (remindYearly) {
            final normalizedDate = DateTime(0, month, day);
            newEvents.putIfAbsent(normalizedDate, () => []).add(event);
          } else {
            final eventDateNormalized = DateTime(year, month, day);
            newEvents.putIfAbsent(eventDateNormalized, () => []).add(event);
          }
        }
      });
    }

    // Parse Todos
    for (var todo in todos) {
      final date = DateTime(
        todo.dueDate.year,
        todo.dueDate.month,
        todo.dueDate.day,
      );
      debugPrint("Adding todo event for date: $date - ${todo.title}");
      newEvents.putIfAbsent(date, () => []).add(todo);
    }

    return newEvents;
  }

  Color _getEventColor(dynamic event) {
    if (event is Todo) {
      return Colors.blue;
    }

    final calendarEvent = event as CalendarEvent;
    if (calendarEvent.isBirthday) {
      return Colors.pink;
    }
    return Theme.of(context).colorScheme.primary;
  }

  Future<void> _showMonthYearPicker() async {
    final l10n = AppLocalizations.of(context)!;
    int selectedYear = _focusedDay.year;
    int selectedMonth = _focusedDay.month;

    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.selectDate),
              content: SizedBox(
                width: 300,
                height: 300,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                          onPressed: () => setDialogState(() => selectedYear--),
                        ),
                        Text(
                          "$selectedYear",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          onPressed: () => setDialogState(() => selectedYear++),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: GridView.builder(
                        itemCount: 12,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.5,
                            ),
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = month == selectedMonth;
                          final monthName = DateFormat.MMM(
                            Localizations.localeOf(context).toString(),
                          ).format(DateTime(2024, month));

                          return InkWell(
                            onTap: () =>
                                setDialogState(() => selectedMonth = month),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(
                                          context,
                                        ).colorScheme.outlineVariant,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  monthName,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Theme.of(
                                            context,
                                          ).colorScheme.onPrimary
                                        : Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(
                    context,
                    DateTime(selectedYear, selectedMonth),
                  ),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        _focusedDay = picked;
      });
    }
  }

  Future<void> _showReminderSettings(CalendarEvent event) async {
    final l10n = AppLocalizations.of(context)!;
    bool remindYearly = event.remindYearly;
    List<String> remindBefore = List<String>.from(event.remindBefore);

    final Map<String, String> options = {
      'halfYear': l10n.halfYear,
      'threeMonths': l10n.threeMonths,
      'month': l10n.month,
      'twoWeeks': l10n.twoWeeks,
      'week': l10n.week,
      'threeDays': l10n.threeDays,
      'day': l10n.day,
      'today': l10n.today,
    };

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(l10n.reminderSettings),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: Text(l10n.remindEveryYear),
                    value: remindYearly,
                    onChanged: (val) =>
                        setDialogState(() => remindYearly = val),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.remindBefore,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...options.entries.map((entry) {
                    final isSelected = remindBefore.contains(entry.key);
                    return CheckboxListTile(
                      title: Text(entry.value),
                      value: isSelected,
                      dense: true,
                      onChanged: (val) {
                        setDialogState(() {
                          if (val == true) {
                            remindBefore.add(entry.key);
                          } else {
                            remindBefore.remove(entry.key);
                          }
                        });
                      },
                    );
                  }),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, {
                    'remindYearly': remindYearly,
                    'remindBefore': remindBefore,
                  }),
                  child: Text(l10n.save),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      try {
        final contact = await _dbService.getContact(event.contactId);
        if (contact == null) return;

        final dateStr = event.date.year == 0
            ? "${event.date.day.toString().padLeft(2, '0')}.${event.date.month.toString().padLeft(2, '0')}.0000"
            : DateFormat('dd.MM.yyyy').format(event.date);

        contact.fields[event.fieldName] = {
          'date': dateStr,
          'remindYearly': result['remindYearly'],
          'remindBefore': result['remindBefore'],
        };

        await _dbService.updateContact(contact);

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.save)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('${l10n.error}: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return StreamBuilder<List<Contact>>(
      stream: _contactsStream,
      builder: (context, contactsSnapshot) {
        return StreamBuilder<List<Todo>>(
          stream: _todosStream,
          builder: (context, todosSnapshot) {
            if (todosSnapshot.hasError) {
              debugPrint("Todos stream error: ${todosSnapshot.error}");
            }
            if ((contactsSnapshot.connectionState == ConnectionState.waiting &&
                    !contactsSnapshot.hasData) ||
                (todosSnapshot.connectionState == ConnectionState.waiting &&
                    !todosSnapshot.hasData)) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final contacts = contactsSnapshot.data ?? [];
            final todos = todosSnapshot.data ?? [];
            final events = _parseToEvents(contacts, todos);
            final selectedEvents = _getEventsForDay(_selectedDay!, events);

            return Scaffold(
              appBar: AppBar(
                title: Text(l10n.calendar),
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () => _showAddTodoSheet(),
                tooltip: l10n.addTodo,
                child: const Icon(Icons.add_task),
              ),
              body: Column(
                children: [
                  TableCalendar<dynamic>(
                    firstDay: DateTime.utc(2000, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      if (!isSameDay(_selectedDay, selectedDay)) {
                        setState(() {
                          _selectedDay = DateTime(
                            selectedDay.year,
                            selectedDay.month,
                            selectedDay.day,
                          );
                          _focusedDay = focusedDay;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                    eventLoader: (day) => _getEventsForDay(day, events),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: false,
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;
                        return Positioned(
                          bottom: 1,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: events.take(4).map((event) {
                              final bool isTodo = event is Todo;
                              return Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 0.5,
                                ),
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isTodo ? null : _getEventColor(event),
                                  border: isTodo
                                      ? Border.all(
                                          color: _getEventColor(event),
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      },
                    ),
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    onHeaderTapped: (focusedDay) => _showMonthYearPicker(),
                  ),
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedDay != null
                                ? "${l10n.eventsOnThisDay}: ${DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(_selectedDay!)}"
                                : l10n.eventsOnThisDay,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: selectedEvents.isEmpty
                                ? Center(
                                    child: Text(
                                      l10n.noEventsOnThisDay,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: selectedEvents.length,
                                    itemBuilder: (context, index) {
                                      final event = selectedEvents[index];
                                      if (event is Todo) {
                                        return _buildTodoTile(event);
                                      }
                                      return _buildContactEventTile(
                                        event as CalendarEvent,
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTodoTile(Todo todo) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: () => _showEditTodoSheet(todo),
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (val) {
            _dbService.updateTodo(todo.copyWith(isCompleted: val ?? false));
          },
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.description.isNotEmpty) Text(todo.description),
            if (todo.contactName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: InkWell(
                  onTap: todo.contactId != null
                      ? () async {
                          final contact = await _dbService.getContact(
                            todo.contactId!,
                          );
                          if (contact != null && mounted) {
                            final allContacts = await _dbService
                                .getAllContacts();
                            final Set<String> allFields = {};
                            final Set<String> allNames = {};
                            final Set<String> allGroups = {};
                            for (var c in allContacts) {
                              allFields.addAll(c.fields.keys);
                              allNames.add(c.name);
                              final gStr = c.fields[AppKeys.groups]?.toString();
                              if (gStr != null) {
                                allGroups.addAll(Contact.parseGroups(gStr));
                              }
                            }
                            if (!mounted) return;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ContactPage(
                                  contact: contact,
                                  existingFields: allFields,
                                  existingNames: allNames,
                                  existingGroups: allGroups,
                                ),
                              ),
                            );
                          }
                        }
                      : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        todo.contactName!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _confirmDeleteTodo(todo),
        ),
      ),
    );
  }

  Widget _buildContactEventTile(CalendarEvent event) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surface,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: () => _showReminderSettings(event),
        leading: Icon(
          event.isBirthday ? Icons.cake : Icons.event,
          color: event.isBirthday
              ? Colors.pink
              : Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          event.age != null
              ? "${event.contactName} (${event.age})"
              : event.contactName,
        ),
        subtitle: Text(
          event.isBirthday
              ? l10n.birthdayEvent
              : AppKeys.getLocalizedLabel(event.fieldName, l10n),
        ),
        trailing: Text(
          event.date.year == 0
              ? DateFormat.MMMMd(
                  Localizations.localeOf(context).toString(),
                ).format(event.date)
              : DateFormat.yMMMMd(
                  Localizations.localeOf(context).toString(),
                ).format(event.date),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }

  void _showAddTodoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TodoEditSheet(
        initialDate: _selectedDay,
        onSave: (todo) => _dbService.addTodo(todo),
      ),
    );
  }

  void _showEditTodoSheet(Todo todo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => TodoEditSheet(
        todo: todo,
        onSave: (updatedTodo) => _dbService.updateTodo(updatedTodo),
      ),
    );
  }

  void _confirmDeleteTodo(Todo todo) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteTodoConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              _dbService.deleteTodo(todo.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.todoDeleted)));
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
