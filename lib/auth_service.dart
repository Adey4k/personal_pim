import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Используем .instance, как того требуют новые правила
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Инициализируем настройки с твоим Web Client ID
      await _googleSignIn.initialize(
        serverClientId: '151482638658-bmvchcm2g58vrpup12crqmlhrcdstq04.apps.googleusercontent.com',
      );

      // 2. Вызываем окно входа (теперь метод называется authenticate)
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return null; // Пользователь закрыл окно

      // 3. Получаем ключи (в 7.x версии это происходит мгновенно, БЕЗ await)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // 4. Передаем idToken в Firebase (accessToken разработчики удалили)
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