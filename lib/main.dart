import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
// НОВЫЙ ИМПОРТ: нужен для настройки кэша Firestore
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

import 'app_drawer.dart';
import 'add_contact_page.dart';
import 'firestore_service.dart';
import 'contact_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // === ЯВНО ВКЛЮЧАЕМ И НАСТРАИВАЕМ ОФЛАЙН КЭШ ===
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true, // Принудительно включаем кэш на диске
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // Не ограничиваем размер кэша
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
      home: const MyHomePage(title: 'Мої контакти'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder<List<Contact>>(
        stream: _dbService.getContactsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // === ТЕПЕРЬ МЫ ВЫВОДИМ РЕАЛЬНУЮ ПРИЧИНУ ОШИБКИ НА ЭКРАН ===
          if (snapshot.hasError) {
            print('Firebase Error: ${snapshot.error}'); // Пишем в консоль
            return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Помилка: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
            );
          }

          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return const Center(
              child: Text(
                'Список контактів порожній',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                      contact.name,
                      style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text(contact.phone),
                ),
              );
            },
          );
        },
      ),
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
  }
}