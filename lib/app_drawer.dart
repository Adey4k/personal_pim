import 'package:flutter/material.dart';

// Импортируем наши новые экраны, чтобы к ним можно было перейти
import 'settings_page.dart';
import 'profile_page.dart';
import 'auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).colorScheme.inversePrimary),
            child: const Text('Меню застосунку', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Головна'),
            onTap: () {
              Navigator.pop(context); // Закрываем меню
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Налаштування'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Профіль'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          const Divider(), // Визуальная линия-разделитель
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Вийти', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.pop(context); // Закрываем меню
              final authService = AuthService();
              await authService.signOut();
            },
          ),
        ],
      ),
    );
  }
}