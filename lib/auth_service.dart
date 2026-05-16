import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  // Фабричний конструктор
  factory AuthService() {
    return _instance;
  }
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const String _googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (_googleClientId.isEmpty) {
        throw Exception(
            "GOOGLE_CLIENT_ID не знайдено."
        );
      }

      await _googleSignIn.initialize(
        serverClientId: _googleClientId,
      );

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Помилка входу через Google: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}