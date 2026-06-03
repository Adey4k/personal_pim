import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_pim/services/auth_service.dart';
import 'package:personal_pim/services/firestore_service.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([
  FirebaseAuth,
  GoogleSignIn,
  GoogleSignInAccount,
  GoogleSignInAuthentication,
  UserCredential,
  User,
  FirestoreService,
])
void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late MockFirestoreService mockDbService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      mockDbService = MockFirestoreService();
      
      authService = AuthService(
        auth: mockAuth,
        googleSignIn: mockGoogleSignIn,
        dbService: mockDbService,
      );
    });

    test('signInWithGoogle calls authenticate and signInWithCredential', () async {
      final mockGoogleUser = MockGoogleSignInAccount();
      final mockGoogleAuth = MockGoogleSignInAuthentication();
      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      when(mockGoogleSignIn.authenticate()).thenAnswer((_) async => mockGoogleUser);
      when(mockGoogleUser.authentication).thenReturn(mockGoogleAuth);
      when(mockGoogleAuth.idToken).thenReturn('mock_id_token');
      when(mockAuth.signInWithCredential(any)).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockDbService.initializeUserDatabase(any)).thenAnswer((_) async {});

      final result = await authService.signInWithGoogle();

      expect(result, mockUserCredential);
      verify(mockGoogleSignIn.authenticate()).called(1);
      verify(mockAuth.signInWithCredential(any)).called(1);
    });
  });
}
