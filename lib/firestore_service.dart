import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'contact_model.dart';
import 'app_constants.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();

  factory FirestoreService() {
    return _instance;
  }

  FirestoreService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference? _getUserCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection(user.uid);
  }

  Future<void> addContact(Contact contact) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    // --- ИСПРАВЛЕНИЕ RACE CONDITION ---
    // Вместо чтения базы данных (лишний запрос к Firebase) мы просто
    // берем текущее время в миллисекундах. Это число всегда уникально
    // и всегда больше предыдущего, поэтому контакт появится в конце.
    contact.orderIndex = DateTime.now().millisecondsSinceEpoch;

    await collection.add(contact.toMap());
  }

  Future<void> updateContact(Contact contact) async {
    final collection = _getUserCollection();
    if (collection == null || contact.id == null) return;

    await collection.doc(contact.id).update(contact.toMap());
  }

  Future<void> updateContactsOrder(List<Contact> contacts) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < contacts.length; i++) {
      if (contacts[i].id != null) {
        batch.update(collection.doc(contacts[i].id!), {AppKeys.orderIndex: i});
      }
    }
    await batch.commit();
  }

  Stream<List<Contact>> getContactsStream() {
    final collection = _getUserCollection();

    if (collection == null) {
      return Stream.value([]);
    }

    return collection.orderBy(AppKeys.orderIndex).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}