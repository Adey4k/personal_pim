import 'package:flutter/material.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Календар'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary
      ),
      body: const Center(
        child: Text('Тут буде календар з датами, налаштуваннями нагадувань та задачник'),
      ),
    );
  }
}