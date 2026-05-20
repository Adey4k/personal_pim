import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'env.dart';

/*
 * AuthService керує процесом аутентифікації.
 * Додано обробку специфічних помилок FirebaseAuth для інформативного UI
 * та механізм обмеження частоти (rate limiting) для відправки листів (60 секунд).
 */
class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static final String _googleClientId = Env.googleClientId;

  // Змінні для обмеження частоти відправки листів
  DateTime? _lastPasswordReset;
  DateTime? _lastEmailVerification;
  static const int _cooldownSeconds = 60;

  void _checkCooldown(DateTime? lastSent) {
    if (lastSent != null) {
      final difference = DateTime.now().difference(lastSent).inSeconds;
      if (difference < _cooldownSeconds) {
        final remaining = _cooldownSeconds - difference;
        throw Exception('Зачекайте $remaining сек. перед повторною відправкою.');
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return 'Некоректний формат email.';
      case 'user-not-found': return 'Користувача не знайдено.';
      case 'wrong-password': return 'Неправильний пароль.';
      case 'invalid-credential': return 'Неправильний email або пароль.';
      case 'email-already-in-use': return 'Цей email вже зареєстровано.';
      case 'weak-password': return 'Пароль занадто простий (мінімум 6 символів).';
      case 'too-many-requests': return 'Занадто багато спроб. Спробуйте пізніше.';
      case 'user-disabled': return 'Цей акаунт заблоковано.';
      default: return e.message ?? 'Сталася помилка авторизації.';
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (_googleClientId.isEmpty) {
        throw Exception("GOOGLE_CLIENT_ID не знайдено.");
      }

      await _googleSignIn.initialize(
        serverClientId: _googleClientId,
      );

      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) {
        throw Exception("Вхід скасовано користувачем.");
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Помилка входу через Google: $e");
      throw Exception("Помилка авторизації Google.");
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null && !credential.user!.emailVerified) {
        await _auth.signOut();
        throw Exception("Email не підтверджено. Перевірте вашу пошту.");
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception("Невідома помилка входу.");
    }
  }

  Future<void> registerWithEmail(String email, String password) async {
    try {
      _checkCooldown(_lastEmailVerification);

      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.sendEmailVerification();
      _lastEmailVerification = DateTime.now();
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      if (e.toString().contains('Зачекайте')) rethrow;
      throw Exception("Невідома помилка реєстрації.");
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("Користувач не авторизований.");

    _checkCooldown(_lastEmailVerification);

    try {
      await user.sendEmailVerification();
      _lastEmailVerification = DateTime.now();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception("Невідома помилка.");
    }
  }

  Future<void> sendPasswordReset(String email) async {
    _checkCooldown(_lastPasswordReset);

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _lastPasswordReset = DateTime.now();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      if (e.toString().contains('Зачекайте')) rethrow;
      throw Exception("Невідома помилка.");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}