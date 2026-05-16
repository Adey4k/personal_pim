import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'app_drawer.dart';
import 'contact_page.dart';
import 'firestore_service.dart';
import 'contact_model.dart';
import 'login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snapshot.hasData) {
            return const MyHomePage(title: 'Мої контакти');
          }
          return const LoginPage();
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirestoreService _dbService = FirestoreService();

  List<String> _columns = ["Ім'я", "Телефон"];
  final Set<String> _knownKeys = {"Ім'я", "Телефон"};

  // Змінна для збереження нашого потоку
  late Stream<List<Contact>> _contactsStream;

  @override
  void initState() {
    super.initState();
    // Ініціалізуємо потік лише ОДИН РАЗ при завантаженні сторінки
    _contactsStream = _dbService.getContactsStream();
  }

  Set<String> _getAllAvailableKeys(List<Contact> contacts) {
    Set<String> keys = {};
    for (var contact in contacts) {
      keys.addAll(contact.fields.keys);
    }
    return keys;
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

  // Розраховує оптимальну ширину для конкретної колонки
  double _calculateColumnWidth(String columnName, List<Contact> contacts) {
    double maxWidth = 0.0;

    final textStyle = const TextStyle(fontSize: 14);
    final headerStyle = const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);

    final headerPainter = TextPainter(
      text: TextSpan(text: columnName, style: headerStyle),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    maxWidth = headerPainter.size.width;

    for (var contact in contacts) {
      final value = contact.fields[columnName]?.toString() ?? '';
      final isName = columnName == "Ім'я";

      final cellPainter = TextPainter(
        text: TextSpan(text: value, style: isName ? headerStyle : textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (cellPainter.size.width > maxWidth) {
        maxWidth = cellPainter.size.width;
      }
    }

    maxWidth += 36.0;

    return maxWidth > 150.0 ? 150.0 : maxWidth;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Contact>>(
      // Використовуємо збережений потік замість постійного виклику функції
      stream: _contactsStream,
      builder: (context, snapshot) {
        final contacts = snapshot.data ?? [];
        final allKeys = _getAllAvailableKeys(contacts);

        for (String key in allKeys) {
          if (!_knownKeys.contains(key)) {
            _knownKeys.add(key);
            _columns.add(key);
          }
        }

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
          body: _buildBody(snapshot, contacts),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ContactPage(
                      existingFields: _knownKeys,
                    )
                ),
              );
            },
            tooltip: 'Додати контакт',
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  Widget _buildBody(AsyncSnapshot<List<Contact>> snapshot, List<Contact> contacts) {
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
    double totalWidth = 50.0; // Закладаємо 50 пікселів під іконку перетягування

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
            // ЗАГОЛОВОК ТАБЛИЦІ
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
                  const SizedBox(width: 48), // Місце під іконку drag_handle
                ],
              ),
            ),

            // СПИСОК КОНТАКТІВ
            Expanded(
              child: ReorderableListView(
                buildDefaultDragHandles: true,
                onReorder: (oldIndex, newIndex) {
                  // Викликаємо setState, щоб оновити інтерфейс миттєво
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;

                    final contact = contacts.removeAt(oldIndex);
                    contacts.insert(newIndex, contact);
                  });

                  // Firebase зберігає порядок у фоні
                  _dbService.updateContactsOrder(contacts);
                },
                children: contacts.map((contact) {
                  return InkWell(
                    key: ValueKey(contact.id),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ContactPage(
                              existingFields: _knownKeys,
                              contact: contact,
                            )
                        ),
                      );
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
                                style: colName == "Ім'я" ? const TextStyle(fontWeight: FontWeight.bold) : null,
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