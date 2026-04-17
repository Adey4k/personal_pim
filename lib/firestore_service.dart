import 'package:cloud_firestore/cloud_firestore.dart';
import 'contact_model.dart';

class FirestoreService {
  // Ссылка на "папку" (коллекцию) с контактами в базе данных
  final CollectionReference _contactsCollection =
  FirebaseFirestore.instance.collection('contacts');

  // Метод для добавления нового контакта
  Future<void> addContact(Contact contact) async {
    // Просто добавляем данные. Firestore сам сохранит их локально,
    // а потом отправит на сервер, когда будет интернет.
    await _contactsCollection.add(contact.toMap());
  }

  // Метод для получения списка контактов в реальном времени
  Stream<List<Contact>> getContactsStream() {
    // snapshots() будет автоматически обновлять список на экране,
    // если данные изменятся (даже в офлайне)
    return _contactsCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }
}