import 'package:flutter_test/flutter_test.dart';
import 'package:personal_pim/models/contact.dart';
import 'package:personal_pim/utils/constants.dart';

void main() {
  group('Contact Model Tests', () {
    test('Contact.toMap() should return a valid map', () {
      final contact = Contact(
        id: 'c1',
        fields: {
          AppKeys.name: 'John Doe',
          AppKeys.phone: '123456789',
        },
        orderIndex: 5,
      );

      final map = contact.toMap();

      expect(map[AppKeys.name], 'John Doe');
      expect(map[AppKeys.phone], '123456789');
      expect(map[AppKeys.orderIndex], 5);
    });

    test('Contact.fromMap() should create a valid Contact object', () {
      final map = {
        AppKeys.name: 'Jane Smith',
        AppKeys.phone: '987654321',
        AppKeys.orderIndex: 10,
      };

      final contact = Contact.fromMap(map, 'c2');

      expect(contact.id, 'c2');
      expect(contact.name, 'Jane Smith');
      expect(contact.fields[AppKeys.phone], '987654321');
      expect(contact.orderIndex, 10);
      // orderIndex should be removed from fields
      expect(contact.fields.containsKey(AppKeys.orderIndex), false);
    });

    test('name getter should return default value if name field is missing', () {
      final contact = Contact(fields: {});
      expect(contact.name, 'Без імені');
    });

    group('parseGroups', () {
      test('should return empty list for null or empty string', () {
        expect(Contact.parseGroups(null), []);
        expect(Contact.parseGroups(''), []);
      });

      test('should parse single group', () {
        expect(Contact.parseGroups('Friends'), ['Friends']);
      });

      test('should parse multiple groups and trim spaces', () {
        expect(Contact.parseGroups('Friends, Work , Family '), ['Friends', 'Work', 'Family']);
      });

      test('should ignore empty entries', () {
        expect(Contact.parseGroups('Friends,,Work,'), ['Friends', 'Work']);
      });
    });
  });
}
