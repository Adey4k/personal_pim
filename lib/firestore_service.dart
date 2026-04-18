import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'contact_model.dart';

class FirestoreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Метод для получения ссылки на личную коллекцию пользователя
  // Мы используем UID как название коллекции в корне базы
  CollectionReference? _getUserCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return FirebaseFirestore.instance.collection(user.uid);
  }

  // Метод для добавления контакта
  Future<void> addContact(Contact contact) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    // Просто сохраняем данные. userId в полях больше не нужен!
    await collection.add(contact.toMap());
  }

  // Метод для получения стрима контактов
  Stream<List<Contact>> getContactsStream() {
    final collection = _getUserCollection();

    if (collection == null) {
      return Stream.value([]);
    }

    // Теперь нам не нужен .where(), потому что в этой коллекции
    // лежат ТОЛЬКО контакты этого пользователя
    return collection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}