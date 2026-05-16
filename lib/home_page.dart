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

  final List<String> _columns = [AppKeys.name, AppKeys.phone];
  final Set<String> _knownKeys = {AppKeys.name, AppKeys.phone};

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

    maxWidth += 36.0;
    final finalWidth = maxWidth > 150.0 ? 150.0 : maxWidth;

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
          body: _buildBody(snapshot, contacts, existingNames),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContactPage(
                      existingFields: _knownKeys,
                      existingNames: existingNames,
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

  Widget _buildBody(AsyncSnapshot<List<Contact>> snapshot, List<Contact> contacts, Set<String> existingNames) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Помилка: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
    }

    if (contacts.isEmpty) {
      return const Center(child: Text('Список контактів порожній', style: TextStyle(fontSize: 18)));
    }

    if (_columns.isEmpty) {
      return const Center(
          child: Text(
              'Виберіть хоча б одну колонку в налаштуваннях',
              style: TextStyle(fontSize: 16, color: Colors.grey)
          )
      );
    }

    Map<String, double> columnWidths = {};
    double totalWidth = 50.0;

    for (String colName in _columns) {
      double width = _calculateColumnWidth(colName, contacts);
      columnWidths[colName] = width;
      totalWidth += width;
    }

    return SingleChildScrollView(
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
                buildDefaultDragHandles: true, // ВЕРНУЛИ обычное зажатие для сортировки
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final contact = contacts.removeAt(oldIndex);
                    contacts.insert(newIndex, contact);
                  });
                  _dbService.updateContactsOrder(contacts, oldIndex, newIndex);
                },
                children: contacts.map((contact) {
                  return InkWell(
                    key: ValueKey(contact.id),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContactPage(
                              existingFields: _knownKeys,
                              existingNames: existingNames,
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
                          return SizedBox(
                            width: columnWidths[colName],
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                value,
                                style: colName == AppKeys.name ? const TextStyle(fontWeight: FontWeight.bold) : null,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
}