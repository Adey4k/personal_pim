import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  String _translateError(dynamic e, AppLocalizations l10n) {
    if (e is CooldownException) {
      return l10n.waitCooldown(e.remainingSeconds);
    }
    final message = e.toString().replaceAll('Exception: ', '');
    switch (message) {
      case 'invalidEmail': return l10n.invalidEmail;
      case 'userNotFound': return l10n.userNotFound;
      case 'wrongPassword': return l10n.wrongPassword;
      case 'invalidCredential': return l10n.invalidCredential;
      case 'tooManyRequests': return l10n.tooManyRequests;
      case 'userDisabled': return l10n.userDisabled;
      case 'authError': return l10n.authError;
      case 'googleClientIdNotFound': return l10n.googleClientIdNotFound;
      case 'authGoogleError': return l10n.authGoogleError;
      case 'unknownLoginError': return l10n.unknownLoginError;
      case 'unknownError': return l10n.unknownError;
      default: return message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocaleCode = localeProvider.locale?.languageCode ?? Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // Welcome Text Section
              Text(
                l10n.welcomeBack,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Input Fields
              TextField(
                controller: _emailController,
                maxLength: 64,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: "",
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                maxLength: 64,
                decoration: InputDecoration(
                  labelText: l10n.password,
                  prefixIcon: const Icon(Icons.lock_outline),
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  counterText: "",
                ),
                obscureText: !_isPasswordVisible,
              ),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () async {
                    final email = _emailController.text.trim();
                    if (email.isEmpty) {
                      _showSnackBar(l10n.enterEmailToResetPassword);
                      return;
                    }
                    try {
                      await _authService.sendPasswordReset(email);
                      _showSnackBar(l10n.passwordResetEmailSent, isError: false);
                    } catch (e) {
                      _showSnackBar(_translateError(e, l10n));
                    }
                  },
                  child: Text(l10n.forgotPassword),
                ),
              ),
              const SizedBox(height: 24),

              // Login Button - Higher Contrast
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
                    _showSnackBar(_translateError(e, l10n));
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  l10n.login,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              
              // Register Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${l10n.dontHaveAccount.split('?')[0]}?'),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const RegisterPage()),
                      );
                    },
                    child: Text(
                      l10n.register,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(l10n.orText),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),

              // Google Login
              OutlinedButton.icon(
                onPressed: () async {
                  try {
                    await _authService.signInWithGoogle(languageCode: currentLocaleCode);
                  } catch (e) {
                    _showSnackBar(_translateError(e, l10n));
                  }
                },
                icon: const Icon(Icons.login), // Replace with Google icon if available
                label: Text(l10n.loginWithGoogle),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: colorScheme.outline),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
