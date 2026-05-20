import 'package:flutter/material.dart';
import 'auth_service.dart';

/*
 * LoginPage керує UI авторизації.
 * Додано валідацію полів перед входом, щоб уникнути відправки пустих запитів
 * та покращено обробку помилок.
 */
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceAll('Exception: ', '')),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вхід у застосунок'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Пароль',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'Підтвердження пароля',
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isConfirmPasswordVisible,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      _showSnackBar('Будь ласка, введіть email та пароль');
                      return;
                    }

                    try {
                      await _authService.signInWithEmail(email, password);
                    } catch (e) {
                      _showSnackBar(e.toString());
                    }
                  },
                  child: const Text('Увійти'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final confirmPassword = _confirmPasswordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      _showSnackBar('Заповніть всі поля');
                      return;
                    }

                    if (password != confirmPassword) {
                      _showSnackBar('Паролі не збігаються');
                      return;
                    }

                    try {
                      await _authService.registerWithEmail(email, password);
                      _showSnackBar(
                        'Лист для підтвердження надіслано на вашу пошту!',
                        isError: false,
                      );
                    } catch (e) {
                      _showSnackBar(e.toString());
                    }
                  },
                  child: const Text('Реєстрація'),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                final email = _emailController.text.trim();

                if (email.isEmpty) {
                  _showSnackBar('Введіть email для скидання пароля');
                  return;
                }

                try {
                  await _authService.sendPasswordReset(email);
                  _showSnackBar(
                    'Якщо акаунт існує, лист для скидання надіслано!',
                    isError: false,
                  );
                } catch (e) {
                  _showSnackBar(e.toString());
                }
              },
              child: const Text('Забули пароль?'),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _authService.signInWithGoogle();
                } catch (e) {
                  _showSnackBar(e.toString());
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('Увійти через Google', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}