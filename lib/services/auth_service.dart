import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../utils/env.dart';
import 'firestore_service.dart';
import 'dart:io';

class CooldownException implements Exception {
  final int remainingSeconds;
  CooldownException(this.remainingSeconds);
  @override
  String toString() => remainingSeconds.toString();
}

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
        throw CooldownException(remaining);
      }
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email': return 'invalidEmail';
      case 'user-not-found': return 'userNotFound';
      case 'wrong-password': return 'wrongPassword';
      case 'invalid-credential': return 'invalidCredential';
      case 'email-already-in-use': return 'emailAlreadyInUse';
      case 'weak-password': return 'weakPassword';
      case 'too-many-requests': return 'tooManyRequests';
      case 'user-disabled': return 'userDisabled';
      default: return 'authError';
    }
  }

  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle({String? languageCode}) async {
    try {
      if (_googleClientId.isEmpty) {
        throw Exception("googleClientIdNotFound");
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
      if (e is Exception && e.toString().contains('googleClientIdNotFound')) rethrow;
      throw Exception("authGoogleError");
    }
  }

  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } on Exception {
      rethrow;
    } catch (e) {
      debugPrint("AuthService Error: $e");
      throw Exception("unknownLoginError");
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String languageCode,
    String? firstName,
    String? lastName,
  }) async {
    try {
      _checkCooldown(_lastEmailVerification);

      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        if (firstName != null || lastName != null) {
          final displayName = [firstName, lastName]
              .where((s) => s != null && s.isNotEmpty)
              .join(' ');
          await credential.user!.updateDisplayName(displayName);
        }
        await _dbService.initializeUserDatabase(languageCode);
      }

      await credential.user?.sendEmailVerification();
      _lastEmailVerification = DateTime.now();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      if (e is CooldownException) rethrow;
      throw Exception("unknownRegistrationError");
    }
  }

  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("userNotAuthenticated");

    _checkCooldown(_lastEmailVerification);

    try {
      await user.sendEmailVerification();
      _lastEmailVerification = DateTime.now();
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      if (e is CooldownException) rethrow;
      throw Exception("unknownError");
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
      if (e is CooldownException) rethrow;
      throw Exception("unknownError");
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
