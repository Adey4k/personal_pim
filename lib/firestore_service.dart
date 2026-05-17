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

    contact.orderIndex = DateTime.now().millisecondsSinceEpoch;

    await collection.add(contact.toMap());
  }

  Future<void> updateContact(Contact contact) async {
    final collection = _getUserCollection();
    if (collection == null || contact.id == null) return;

    await collection.doc(contact.id).update(contact.toMap());
  }

  Future<void> renameGroupGlobal(String oldName, String newName) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    final snapshot = await collection.get();
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final groupsStr = data[AppKeys.groups]?.toString();

      List<String> groups = Contact.parseGroups(groupsStr); // Используем хелпер

      if (groups.contains(oldName)) {
        int index = groups.indexOf(oldName);
        groups[index] = newName;
        batch.update(doc.reference, {AppKeys.groups: groups.join(', ')});
      }
    }
    await batch.commit();
  }

  Future<void> deleteGroupGlobal(String groupName) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    final snapshot = await collection.get();
    final batch = FirebaseFirestore.instance.batch();

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final groupsStr = data[AppKeys.groups]?.toString();

      List<String> groups = Contact.parseGroups(groupsStr); // Используем хелпер

      if (groups.contains(groupName)) {
        groups.remove(groupName);
        if (groups.isEmpty) {
          batch.update(doc.reference, {AppKeys.groups: FieldValue.delete()});
        } else {
          batch.update(doc.reference, {AppKeys.groups: groups.join(', ')});
        }
      }
    }
    await batch.commit();
  }

  Future<void> updateContactsOrder(List<Contact> contacts, int oldIndex, int newIndex) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    final batch = FirebaseFirestore.instance.batch();

    final startIndex = oldIndex < newIndex ? oldIndex : newIndex;
    final endIndex = oldIndex > newIndex ? oldIndex : newIndex;

    for (int i = startIndex; i <= endIndex; i++) {
      if (contacts[i].id != null) {
        batch.update(collection.doc(contacts[i].id!), {AppKeys.orderIndex: i});
      }
    }
    await batch.commit();
  }

  Future<void> deleteContact(String contactId) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    await collection.doc(contactId).delete();
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