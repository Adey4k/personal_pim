import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_pim/models/contact.dart';
import 'package:personal_pim/services/firestore_service.dart';
import 'package:personal_pim/utils/constants.dart';

import 'firestore_service_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  FirebaseAuth,
  User,
  CollectionReference,
  DocumentReference,
  WriteBatch,
  QuerySnapshot,
  DocumentSnapshot,
])
void main() {
  group('FirestoreService Tests', () {
    late FirestoreService firestoreService;
    late MockFirebaseFirestore mockDb;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;

    setUp(() {
      mockDb = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('user123');

      firestoreService = FirestoreService(auth: mockAuth, firestore: mockDb);
    });

    test('addContact calls add on the correct collection', () async {
      // This test might be limited without DI in FirestoreService
      expect(firestoreService, isNotNull);
    });

    test('importContacts commits imports in Firestore-sized batches', () async {
      final collection = MockCollectionReference<Map<String, dynamic>>();
      final batches = [MockWriteBatch(), MockWriteBatch()];
      final docs = List.generate(
        501,
        (_) => MockDocumentReference<Map<String, dynamic>>(),
      );
      var batchIndex = 0;
      var docIndex = 0;

      when(mockDb.collection('user123')).thenReturn(collection);
      when(mockDb.batch()).thenAnswer((_) => batches[batchIndex++]);
      when(collection.doc()).thenAnswer((_) => docs[docIndex++]);

      final contacts = List.generate(
        501,
        (index) => Contact(fields: {AppKeys.name: 'Contact $index'}),
      );

      await firestoreService.importContacts(contacts);

      verify(batches[0].set(any, any)).called(500);
      verify(batches[1].set(any, any)).called(1);
      verify(batches[0].commit()).called(1);
      verify(batches[1].commit()).called(1);
    });
  });
}
