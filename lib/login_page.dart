import 'package:flutter/material.dart';
import 'auth_service.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вхід у застосунок'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            final authService = AuthService();
            await authService.signInWithGoogle();
          },
          icon: const Icon(Icons.login),
          label: const Text('Увійти через Google', style: TextStyle(fontSize: 18)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}