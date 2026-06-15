import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../l10n/app_localizations.dart';
import '../utils/snackbar_utils.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  Timer? _timer;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    showCurrentSnackBar(
      context,
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
      case 'invalidEmail':
        return l10n.invalidEmail;
      case 'userNotFound':
        return l10n.userNotFound;
      case 'wrongPassword':
        return l10n.wrongPassword;
      case 'invalidCredential':
        return l10n.invalidCredential;
      case 'emailAlreadyInUse':
        return l10n.emailAlreadyInUse;
      case 'weakPassword':
        return l10n.weakPassword;
      case 'tooManyRequests':
        return l10n.tooManyRequests;
      case 'userDisabled':
        return l10n.userDisabled;
      case 'authError':
        return l10n.authError;
      case 'googleClientIdNotFound':
        return l10n.googleClientIdNotFound;
      case 'authGoogleError':
        return l10n.authGoogleError;
      case 'unknownLoginError':
        return l10n.unknownLoginError;
      case 'unknownRegistrationError':
        return l10n.unknownRegistrationError;
      case 'userNotAuthenticated':
        return l10n.userNotAuthenticated;
      case 'unknownError':
        return l10n.unknownError;
      default:
        return message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.verifyEmailTitle),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.mark_email_unread_outlined,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.verificationEmailSentTo(user?.email ?? ''),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.checkEmailInstructions,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  await _authService.resendVerificationEmail();
                  _showSnackBar(l10n.emailResent, isError: false);
                } catch (e) {
                  _showSnackBar(_translateError(e, l10n));
                }
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.resendEmail),
            ),
            TextButton(
              onPressed: () async {
                await _authService.signOut();
              },
              child: Text(l10n.cancelAndReturn),
            ),
          ],
        ),
      ),
    );
  }
}
