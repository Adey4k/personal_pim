import 'package:flutter_test/flutter_test.dart';
import 'package:personal_pim/models/todo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Todo Model Tests', () {
    final testDate = DateTime(2023, 10, 27, 10, 0);
    final testTimestamp = Timestamp.fromDate(testDate);

    test('Todo.toMap() should return a valid map', () {
      final todo = Todo(
        id: '1',
        title: 'Test Todo',
        description: 'Test Description',
        dueDate: testDate,
        isCompleted: false,
        contactId: 'c1',
        contactName: 'John Doe',
      );

      final map = todo.toMap();

      expect(map['title'], 'Test Todo');
      expect(map['description'], 'Test Description');
      expect(map['dueDate'], testTimestamp);
      expect(map['isCompleted'], false);
      expect(map['contactId'], 'c1');
      expect(map['contactName'], 'John Doe');
    });

    test('Todo.fromMap() should create a valid Todo object', () {
      final map = {
        'title': 'Test Todo',
        'description': 'Test Description',
        'dueDate': testTimestamp,
        'isCompleted': true,
        'contactId': 'c2',
        'contactName': 'Jane Smith',
      };

      final todo = Todo.fromMap(map, '2');

      expect(todo.id, '2');
      expect(todo.title, 'Test Todo');
      expect(todo.description, 'Test Description');
      expect(todo.dueDate, testDate);
      expect(todo.isCompleted, true);
      expect(todo.contactId, 'c2');
      expect(todo.contactName, 'Jane Smith');
    });

    test('Todo.copyWith() should return a new object with updated values', () {
      final todo = Todo(
        id: '1',
        title: 'Original Title',
        dueDate: testDate,
      );

      final updatedTodo = todo.copyWith(
        title: 'Updated Title',
        isCompleted: true,
      );

      expect(updatedTodo.id, '1');
      expect(updatedTodo.title, 'Updated Title');
      expect(updatedTodo.isCompleted, true);
      expect(updatedTodo.dueDate, testDate); // Should remain same
    });
  });
}
