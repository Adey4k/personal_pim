import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'contact_model.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference? _getUserCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection(user.uid);
  }

  Future<void> addContact(Contact contact) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    // Знаходимо найбільший orderIndex, щоб додати новий контакт у кінець
    final snapshot = await collection.orderBy('orderIndex', descending: true).limit(1).get();
    int newIndex = 0;
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data() as Map<String, dynamic>;
      newIndex = (data['orderIndex'] as int? ?? 0) + 1;
    }
    contact.orderIndex = newIndex;

    await collection.add(contact.toMap());
  }

  Future<void> updateContact(Contact contact) async {
    final collection = _getUserCollection();
    if (collection == null || contact.id == null) return;

    await collection.doc(contact.id).update(contact.toMap());
  }

  // НОВИЙ МЕТОД: Зберігає новий порядок після перетягування
  Future<void> updateContactsOrder(List<Contact> contacts) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    // Використовуємо Batch для того, щоб оновити всі індекси за 1 запит до Firebase
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < contacts.length; i++) {
      if (contacts[i].id != null) {
        batch.update(collection.doc(contacts[i].id!), {'orderIndex': i});
      }
    }
    await batch.commit();
  }

  Stream<List<Contact>> getContactsStream() {
    final collection = _getUserCollection();

    if (collection == null) {
      return Stream.value([]);
    }

    // Сортуємо результати по полю orderIndex
    return collection.orderBy('orderIndex').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}