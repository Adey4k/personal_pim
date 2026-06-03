import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';


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
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocaleCode = localeProvider.locale?.languageCode ?? Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.loginTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.language, size: 20),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: currentLocaleCode,
                  underline: const SizedBox(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      localeProvider.setLocale(Locale(newValue));
                    }
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: 'en',
                      child: Text(l10n.english),
                    ),
                    DropdownMenuItem<String>(
                      value: 'uk',
                      child: Text(l10n.ukrainian),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: l10n.email),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.password,
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
                labelText: l10n.confirmPassword,
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
                      _showSnackBar(l10n.pleaseEnterEmailAndPassword);
                      return;
                    }

                    try {
                      await _authService.signInWithEmail(email, password);
                    } catch (e) {
                      _showSnackBar(e.toString());
                    }
                  },
                  child: Text(l10n.login),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();
                    final confirmPassword = _confirmPasswordController.text.trim();

                    if (email.isEmpty || password.isEmpty) {
                      _showSnackBar(l10n.fillAllFields);
                      return;
                    }

                    if (password != confirmPassword) {
                      _showSnackBar(l10n.passwordsDoNotMatch);
                      return;
                    }

                    try {
                      await _authService.registerWithEmail(email, password, currentLocaleCode);
                      _showSnackBar(
                        l10n.verificationEmailSent,
                        isError: false,
                      );
                    } catch (e) {
                      _showSnackBar(e.toString());
                    }
                  },
                  child: Text(l10n.register),
                ),
              ],
            ),
            TextButton(
              onPressed: () async {
                final email = _emailController.text.trim();

                if (email.isEmpty) {
                  _showSnackBar(l10n.enterEmailToResetPassword);
                  return;
                }

                try {
                  await _authService.sendPasswordReset(email);
                  _showSnackBar(
                    l10n.passwordResetEmailSent,
                    isError: false,
                  );
                } catch (e) {
                  _showSnackBar(e.toString());
                }
              },
              child: Text(l10n.forgotPassword),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _authService.signInWithGoogle(languageCode: currentLocaleCode);
                } catch (e) {
                  _showSnackBar(e.toString());
                }
              },
              icon: const Icon(Icons.login),
              label: Text(l10n.loginWithGoogle, style: const TextStyle(fontSize: 18)),
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
