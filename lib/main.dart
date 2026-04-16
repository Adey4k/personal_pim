import 'package:flutter/material.dart';

import 'app_drawer.dart';
// Импортируем наш новый экран добавления контакта
import 'add_contact_page.dart';

void main() {
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
      home: const MyHomePage(title: 'Мої контакти'), // Изменили заголовок
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
  // Мы удалили переменную _counter и метод _incrementCounter,
  // так как они нам больше не нужны!

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      drawer: const AppDrawer(),
      body: const Center(
        // Вместо колонки со счетчиком мы пока выводим простую надпись
        child: Text(
          'Список контактів порожній',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Теперь при нажатии мы переходим на экран AddContactPage
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