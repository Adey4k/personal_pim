import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/env.dart';
import 'firestore_service.dart';
import 'dart:io';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn, FirestoreService? dbService}) {
    if (auth != null) _instance._auth = auth;
    if (googleSignIn != null) _instance._googleSignIn = googleSignIn;
    if (dbService != null) _instance._dbService = dbService;
    return _instance;
  }
  AuthService._internal();

  FirebaseAuth? _authInstance;
  FirebaseAuth get _auth => _authInstance ?? FirebaseAuth.instance;
  set _auth(FirebaseAuth value) => _authInstance = value;

  GoogleSignIn? _googleSignInInstance;
  GoogleSignIn get _googleSignIn => _googleSignInInstance ?? GoogleSignIn.instance;
  set _googleSignIn(GoogleSignIn value) => _googleSignInInstance = value;

  FirestoreService? _dbServiceInstance;
  FirestoreService get _dbService => _dbServiceInstance ?? FirestoreService();
  set _dbService(FirestoreService value) => _dbServiceInstance = value;

  static final String _googleClientId = Env.googleClientId;

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

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle({String? languageCode}) async {
    try {
      if (_googleClientId.isEmpty) {
        throw Exception("GOOGLE_CLIENT_ID не знайдено.");
      }

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final lang = languageCode ?? Platform.localeName.split('_')[0];
        await _dbService.initializeUserDatabase(lang);
      }

      return userCredential;
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

      final user = credential.user;
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        throw Exception("Email не підтверджено. Перевірте вашу пошту.");
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } on Exception catch (e) {
      rethrow;
    } catch (e) {
      debugPrint("AuthService Error: $e");
      throw Exception("Невідома помилка входу.");
    }
  }

  Future<void> registerWithEmail(String email, String password, String languageCode) async {
    try {
      _checkCooldown(_lastEmailVerification);

      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await _dbService.initializeUserDatabase(languageCode);
      }

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