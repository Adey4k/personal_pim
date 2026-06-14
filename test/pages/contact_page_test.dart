import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:personal_pim/pages/contact_page.dart';
import 'package:personal_pim/services/firestore_service.dart';
import 'package:personal_pim/models/contact.dart';
import 'package:personal_pim/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/test_app.dart';

@GenerateMocks([FirestoreService])
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ContactPage Widget Tests', () {
    testWidgets('Should display contact name and existing fields smoke test', (
      WidgetTester tester,
    ) async {
      final contact = Contact(
        id: '1',
        fields: {AppKeys.name: 'Ivan Mazepa', AppKeys.phone: '0671234567'},
      );

      await tester.pumpWidget(
        createTestApp(
          home: ContactPage(
            existingFields: {AppKeys.phone},
            existingNames: const {},
            existingGroups: const {},
            contact: contact,
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(ContactPage), findsOneWidget);
    });
  });
}
