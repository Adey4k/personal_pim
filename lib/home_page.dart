import 'package:flutter/material.dart';
import 'app_drawer.dart';
import 'contact_page.dart';
import 'firestore_service.dart';
import 'contact_model.dart';
import 'app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirestoreService _dbService = FirestoreService();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedGroupFilter; // Змінна для зберігання обраного фільтру групи

  final List<String> _columns = [AppKeys.name, AppKeys.phone, AppKeys.email, AppKeys.birthday, AppKeys.groups];
  final Set<String> _knownKeys = {AppKeys.name, AppKeys.phone, AppKeys.email, AppKeys.birthday, AppKeys.groups};

  final Map<String, double> _columnWidthCache = {};
  late Stream<List<Contact>> _contactsStream;

  final TextPainter _textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    maxLines: 1,
  );

  @override
  void initState() {
    super.initState();
    _contactsStream = _dbService.getContactsStream();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Set<String> _getAllAvailableKeys(List<Contact> contacts) {
    Set<String> keys = {};
    for (var contact in contacts) {
      keys.addAll(contact.fields.keys);
    }
    return keys;
  }

  void _updateKnownKeysIfNeeded(Set<String> allKeys) {
    bool hasChanges = false;
    for (String key in allKeys) {
      if (!_knownKeys.contains(key)) {
        _knownKeys.add(key);
        _columns.add(key);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  MaterialColor _getGroupColor(String groupName) {
    final List<MaterialColor> colors = [
      Colors.blue, Colors.green, Colors.orange, Colors.purple,
      Colors.teal, Colors.pink, Colors.indigo, Colors.brown,
      Colors.cyan, Colors.deepOrange
    ];
    return colors[groupName.hashCode.abs() % colors.length];
  }

  double _calculateColumnWidth(String columnName, List<Contact> contacts) {
    if (_columnWidthCache.containsKey(columnName)) {
      return _columnWidthCache[columnName]!;
    }

    double maxWidth = 0.0;
    const textStyle = TextStyle(fontSize: 14);
    const headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    _textPainter.text = TextSpan(text: columnName, style: headerStyle);
    _textPainter.layout();
    maxWidth = _textPainter.size.width;

    final contactsToCheck = contacts.take(40);

    for (var contact in contactsToCheck) {
      final value = contact.fields[columnName]?.toString() ?? '';
      final isName = columnName == AppKeys.name;

      _textPainter.text = TextSpan(text: value, style: isName ? headerStyle : textStyle);
      _textPainter.layout();

      if (_textPainter.size.width > maxWidth) {
        maxWidth = _textPainter.size.width;
      }
    }

    if (columnName == AppKeys.groups) {
      maxWidth += 60.0;
    }

    maxWidth += 36.0;

    final maxAllowedWidth = columnName == AppKeys.groups ? 250.0 : 150.0;
    final finalWidth = maxWidth > maxAllowedWidth ? maxAllowedWidth : maxWidth;

    _columnWidthCache[columnName] = finalWidth;
    return finalWidth;
  }

  void _invalidateCache() {
    _columnWidthCache.clear();
  }

  void _showColumnSettings(Set<String> allKeys) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
            builder: (context, setModalState) {
              List<String> unselectedKeys = allKeys.difference(_columns.toSet()).toList();

              return Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Налаштування таблиці', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Тягніть, щоб змінити порядок. Натисніть ❌, щоб сховати колонку.'),
                    const SizedBox(height: 16),

                    Expanded(
                      child: ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          setModalState(() {
                            if (newIndex > oldIndex) newIndex -= 1;
                            final String item = _columns.removeAt(oldIndex);
                            _columns.insert(newIndex, item);
                          });
                          setState(() {});
                        },
                        children: [
                          for (int index = 0; index < _columns.length; index += 1)
                            ListTile(
                              key: ValueKey(_columns[index]),
                              title: Text(_columns[index]),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.red),
                                    onPressed: () {
                                      setModalState(() {
                                        _columns.removeAt(index);
                                      });
                                      setState(() {});
                                    },
                                  ),
                                  const Icon(Icons.drag_handle),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 32, thickness: 2),

                    const Text('Доступні поля для додавання:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: unselectedKeys.map((key) {
                        return ActionChip(
                          label: Text('+ $key'),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          onPressed: () {
                            setModalState(() {
                              _columns.add(key);
                            });
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    if (unselectedKeys.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text('Всі існуючі поля вже в таблиці', style: TextStyle(color: Colors.grey)),
                      ),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Contact>>(
      stream: _contactsStream,
      builder: (context, snapshot) {
        final contacts = snapshot.data ?? [];
        final allKeys = _getAllAvailableKeys(contacts);
        final existingNames = contacts.map((c) => c.name).toSet();

        Set<String> existingGroups = {};
        for (var c in contacts) {
          final groupStr = c.fields[AppKeys.groups]?.toString();
          if (groupStr != null) {
            existingGroups.addAll(Contact.parseGroups(groupStr));
          }
        }

        _updateKnownKeysIfNeeded(allKeys);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            actions: [
              if (snapshot.hasData && contacts.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.view_column),
                  tooltip: 'Налаштувати колонки',
                  onPressed: () => _showColumnSettings(allKeys),
                ),
            ],
          ),
          drawer: const AppDrawer(),
          body: _buildBody(snapshot, contacts, existingNames, existingGroups),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContactPage(
                      existingFields: _knownKeys,
                      existingNames: existingNames,
                      existingGroups: existingGroups,
                    )
                ),
              );
              _invalidateCache();
              setState((){});
            },
            tooltip: 'Додати контакт',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Contact>> snapshot, List<Contact> contacts, Set<String> existingNames, Set<String> existingGroups) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Помилка: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
    }

    // ЛОГІКА ПОШУКУ ТА ФІЛЬТРАЦІЇ
    bool isFilteringActive = _searchQuery.isNotEmpty || _selectedGroupFilter != null;

    List<Contact> filteredContacts = contacts.where((contact) {
      // 1. Перевірка фільтру по групі
      if (_selectedGroupFilter != null) {
        final groupStr = contact.fields[AppKeys.groups]?.toString();
        final groups = Contact.parseGroups(groupStr);
        if (!groups.contains(_selectedGroupFilter)) {
          return false; // Контакт не належить до обраної групи
        }
      }

      // 2. Перевірка текстового пошуку (ігноруючи колонку "Групи")
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        bool matchesText = false;

        for (String colName in _columns) {
          if (colName == AppKeys.groups) continue; // ПРОПУСКАЄМО ГРУПИ В ТЕКСТОВОМУ ПОШУКУ

          final value = contact.fields[colName]?.toString().toLowerCase() ?? '';
          if (value.contains(query)) {
            matchesText = true;
            break;
          }
        }
        if (!matchesText) return false;
      }

      return true; // Контакт пройшов всі активні фільтри
    }).toList();

    Widget content;

    if (contacts.isEmpty) {
      content = const Center(child: Text('Список контактів порожній', style: TextStyle(fontSize: 18)));
    } else if (_columns.isEmpty) {
      content = const Center(
          child: Text(
              'Виберіть хоча б одну колонку в налаштуваннях',
              style: TextStyle(fontSize: 16, color: Colors.grey)
          )
      );
    } else if (filteredContacts.isEmpty) {
      content = const Center(child: Text('За вашим запитом нічого не знайдено', style: TextStyle(fontSize: 18)));
    } else {
      Map<String, double> columnWidths = {};
      double totalWidth = 50.0;

      for (String colName in _columns) {
        double width = _calculateColumnWidth(colName, contacts);
        columnWidths[colName] = width;
        totalWidth += width;
      }

      content = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: totalWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 2)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    ..._columns.map((colName) => SizedBox(
                      width: columnWidths[colName],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(colName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    )),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: ReorderableListView(
                  // Вимикаємо сортування, якщо активний пошук або фільтр
                  buildDefaultDragHandles: !isFilteringActive,
                  onReorder: (oldIndex, newIndex) {
                    if (isFilteringActive) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Сортування вимкнено під час пошуку або фільтрації')),
                      );
                      return;
                    }
                    setState(() {
                      if (newIndex > oldIndex) newIndex -= 1;
                      final contact = contacts.removeAt(oldIndex);
                      contacts.insert(newIndex, contact);
                    });
                    _dbService.updateContactsOrder(contacts, oldIndex, newIndex);
                  },
                  children: filteredContacts.map((contact) {
                    return InkWell(
                      key: ValueKey(contact.id),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ContactPage(
                                existingFields: _knownKeys,
                                existingNames: existingNames,
                                existingGroups: existingGroups,
                                contact: contact,
                              )
                          ),
                        );
                        _invalidateCache();
                        setState((){});
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          children: _columns.map((colName) {
                            final value = contact.fields[colName]?.toString() ?? '';
                            Widget cellContent;

                            if (colName == AppKeys.groups && value.isNotEmpty) {
                              List<String> groups = Contact.parseGroups(value);
                              cellContent = SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: groups.map((g) {
                                    final color = _getGroupColor(g);
                                    return Container(
                                      margin: const EdgeInsets.only(right: 6.0),
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8.0),
                                        border: Border.all(color: color.withValues(alpha: 0.5)),
                                      ),
                                      child: Text(
                                        g,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: color.shade800,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            } else if (value.toLowerCase() == 'true') {
                              cellContent = const Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                              );
                            } else if (value.toLowerCase() == 'false') {
                              cellContent = const Align(
                                alignment: Alignment.centerLeft,
                                child: Icon(Icons.cancel, color: Colors.red, size: 20),
                              );
                            } else {
                              cellContent = Text(
                                value,
                                style: colName == AppKeys.name ? const TextStyle(fontWeight: FontWeight.bold) : null,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              );
                            }

                            return SizedBox(
                              width: columnWidths[colName],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: cellContent,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Рядок текстового пошуку
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 4.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Пошук...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                  FocusScope.of(context).unfocus();
                },
              )
                  : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),

        // Панель з фільтрами груп
        if (existingGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Всі'),
                    selected: _selectedGroupFilter == null,
                    onSelected: (bool selected) {
                      if (selected) setState(() => _selectedGroupFilter = null);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...existingGroups.map((group) {
                    final color = _getGroupColor(group);
                    final isSelected = _selectedGroupFilter == group;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(
                            group,
                            style: TextStyle(
                                color: isSelected ? Colors.white : color.shade900,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                            )
                        ),
                        selected: isSelected,
                        selectedColor: color,
                        backgroundColor: color.withValues(alpha: 0.1),
                        side: BorderSide(color: color.withValues(alpha: 0.5)),
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedGroupFilter = selected ? group : null;
                          });
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

        // Тіло таблиці
        Expanded(child: content),
      ],
    );
  }
}