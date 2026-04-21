import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'app_drawer.dart';
import 'add_contact_page.dart';
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

  // Список колонок, які зараз відображаються
  List<String> _columns = ["Ім'я", "Телефон"];

  // "Пам'ять" таблиці. Зберігає всі ключі, які таблиця вже колись бачила.
  // Це потрібно, щоб якщо ти сховаєш колонку, вона не додалась назад автоматично.
  final Set<String> _knownKeys = {"Ім'я", "Телефон"};

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

  DataCell _buildCell(Contact contact, String columnName) {
    final value = contact.fields[columnName]?.toString() ?? '';
    return DataCell(
        Text(
          value,
          style: columnName == "Ім'я" ? const TextStyle(fontWeight: FontWeight.bold) : null,
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Contact>>(
      stream: _dbService.getContactsStream(),
      builder: (context, snapshot) {
        final contacts = snapshot.data ?? [];
        final allKeys = _getAllAvailableKeys(contacts);

        // === МАГІЯ АВТОДОДАВАННЯ ===
        // Якщо в базі з'явилося нове поле, якого ми ще не бачили,
        // додаємо його в пам'ять таблиці і відразу виводимо як колонку!
        for (String key in allKeys) {
          if (!_knownKeys.contains(key)) {
            _knownKeys.add(key); // Запам'ятали
            _columns.add(key);   // Показали
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
                MaterialPageRoute(builder: (context) => const AddContactPage()),
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

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: _columns.map((colName) => DataColumn(
            label: Text(colName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          )).toList(),
          rows: contacts.map((contact) {
            return DataRow(
              cells: _columns.map((colName) => _buildCell(contact, colName)).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}