import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact.dart';
import '../models/todo.dart';
import '../utils/constants.dart';
import 'home_widget_service.dart';

class FirestoreService {
  final FirebaseAuth _authInstance;
  final FirebaseFirestore _firestoreInstance;

  FirestoreService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _authInstance = auth ?? FirebaseAuth.instance,
        _firestoreInstance = firestore ?? FirebaseFirestore.instance;

  FirebaseAuth get _auth => _authInstance;
  FirebaseFirestore get _db => _firestoreInstance;

  CollectionReference? _getUserCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection(user.uid);
  }

  CollectionReference? _getTodoCollection() {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _db.collection(user.uid).doc('--todos--').collection('items');
  }

  // Contact methods
  Future<void> addContact(Contact contact) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    contact.orderIndex = DateTime.now().millisecondsSinceEpoch;

    await collection.add(contact.toMap());
  }

  // Todo methods
  Future<void> addTodo(Todo todo) async {
    final collection = _getTodoCollection();
    if (collection == null) return;
    await collection.add(todo.toMap());
  }

  Future<void> updateTodo(Todo todo) async {
    final collection = _getTodoCollection();
    if (collection == null || todo.id == null) return;
    await collection.doc(todo.id).update(todo.toMap());
  }

  Future<void> deleteTodo(String todoId) async {
    final collection = _getTodoCollection();
    if (collection == null) return;
    await collection.doc(todoId).delete();
  }

  Stream<List<Todo>> getTodosStream() {
    final collection = _getTodoCollection();
    if (collection == null) return Stream.value([]);
    return collection.orderBy('dueDate').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Todo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
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
    final List<MapEntry<DocumentReference, Map<String, dynamic>>> updates = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final groupsStr = data[AppKeys.groups]?.toString();

      List<String> groups = Contact.parseGroups(groupsStr);

      if (groups.contains(oldName)) {
        int index = groups.indexOf(oldName);
        groups[index] = newName;
        updates.add(MapEntry(doc.reference, {AppKeys.groups: groups.join(', ')}));
      }
    }
    await _commitInBatches(updates);
  }

  Future<void> deleteGroupGlobal(String groupName) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    final snapshot = await collection.get();
    final List<MapEntry<DocumentReference, Map<String, dynamic>>> updates = [];

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final groupsStr = data[AppKeys.groups]?.toString();

      List<String> groups = Contact.parseGroups(groupsStr);

      if (groups.contains(groupName)) {
        groups.remove(groupName);
        if (groups.isEmpty) {
          updates.add(MapEntry(doc.reference, {AppKeys.groups: FieldValue.delete()}));
        } else {
          updates.add(MapEntry(doc.reference, {AppKeys.groups: groups.join(', ')}));
        }
      }
    }
    await _commitInBatches(updates);
  }

  Future<void> _commitInBatches(List<MapEntry<DocumentReference, Map<String, dynamic>>> updates) async {
    const int batchSize = 500;
    for (int i = 0; i < updates.length; i += batchSize) {
      final batch = _db.batch();
      final chunk = updates.sublist(i, i + batchSize > updates.length ? updates.length : i + batchSize);
      for (var update in chunk) {
        batch.update(update.key, update.value);
      }
      try {
        await batch.commit();
      } catch (e) {
        // Log error and optionally throw if you want to abort subsequent batches
        print("Error committing batch (index $i): $e");
        rethrow; // Assuming we want the caller to know about the failure
      }
    }
  }

  Future<void> updateAllContactsOrder(List<Contact> contacts) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    final List<MapEntry<DocumentReference, Map<String, dynamic>>> updates = [];

    for (int i = 0; i < contacts.length; i++) {
      if (contacts[i].id != null) {
        updates.add(MapEntry(collection.doc(contacts[i].id!), {AppKeys.orderIndex: i}));
        contacts[i].orderIndex = i;
      }
    }
    await _commitInBatches(updates);
  }

  Future<void> deleteContact(String contactId) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    await collection.doc(contactId).delete();
  }

  Future<int> getFieldUsageCount(String fieldKey) async {
    final collection = _getUserCollection();
    if (collection == null) return 0;

    final snapshot = await collection.get();
    int count = 0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final val = data[fieldKey]?.toString() ?? "";
      if (val.trim().isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  Future<void> deleteFieldGlobal(String fieldKey) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    final snapshot = await collection.get();
    final List<MapEntry<DocumentReference, Map<String, dynamic>>> updates = [];

    for (var doc in snapshot.docs) {
      updates.add(MapEntry(doc.reference, {fieldKey: FieldValue.delete()}));
    }
    await _commitInBatches(updates);
  }

  Future<List<Contact>> getAllContacts() async {
    final collection = _getUserCollection();
    if (collection == null) return [];

    final snapshot = await collection.orderBy(AppKeys.orderIndex).get();
    return snapshot.docs.map((doc) {
      return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();
  }

  Future<Contact?> getContact(String contactId) async {
    final collection = _getUserCollection();
    if (collection == null) return null;

    final doc = await collection.doc(contactId).get();
    if (!doc.exists) return null;

    return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  Future<void> importContacts(List<Contact> contacts) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    final batch = _db.batch();
    for (var contact in contacts) {
      final docRef = collection.doc(); // Generate new ID
      batch.set(docRef, contact.toMap());
    }
    await batch.commit();
  }

  Stream<List<Contact>> getContactsStream() {
    final collection = _getUserCollection();

    if (collection == null) {
      return Stream.value([]);
    }

    return collection.orderBy(AppKeys.orderIndex).snapshots().map((snapshot) {
      final contacts = snapshot.docs.map((doc) {
        return Contact.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
      return contacts;
    });
  }

  Future<void> initializeUserDatabase(String languageCode) async {
    final collection = _getUserCollection();
    if (collection == null) return;

    final snapshot = await collection.limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    // Localized strings
    String name;
    String groups;

    switch (languageCode) {
      case 'uk':
        name = 'Джейн Доу';
        groups = 'Сім\'я, Робота, Друзі';
        break;
      case 'de':
        name = 'Jane Doe';
        groups = 'Familie, Arbeit, Freunde';
        break;
      case 'fr':
        name = 'Jane Doe';
        groups = 'Famille, Travail, Amis';
        break;
      case 'es':
        name = 'Jane Doe';
        groups = 'Familia, Trabajo, Amigos';
        break;
      case 'pl':
        name = 'Jane Doe';
        groups = 'Rodzina, Praca, Znajomi';
        break;
      default:
        name = 'Jane Doe';
        groups = 'Family, Work, Friends';
    }

    final contact = Contact(fields: {
      AppKeys.name: name,
      AppKeys.phone: '+380123456789',
      AppKeys.email: 'janedoe@gmail.com',
      AppKeys.birthday: {
        'date': '12.12.2012',
        'remindYearly': true,
        'remindBefore': ['day', 'today']
      },
      AppKeys.groups: groups
    });

    contact.orderIndex = 0;
    await collection.add(contact.toMap());
  }
}
