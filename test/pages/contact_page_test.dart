import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_pim/pages/contact_page.dart';
import 'package:personal_pim/services/firestore_service.dart';
import 'package:personal_pim/l10n/app_localizations.dart';
import 'package:personal_pim/models/contact.dart';
import 'package:personal_pim/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'contact_page_test.mocks.dart';

@GenerateMocks([FirestoreService])
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );
  }

  group('ContactPage Widget Tests', () {
    testWidgets('Should display contact name and existing fields smoke test', (WidgetTester tester) async {
      final contact = Contact(
        id: '1',
        fields: {
          AppKeys.name: 'Ivan Mazepa',
          AppKeys.phone: '0671234567',
        },
      );

      await tester.pumpWidget(createTestWidget(
        ContactPage(
          existingFields: {AppKeys.phone},
          existingNames: const {},
          existingGroups: const {},
          contact: contact,
        ),
      ));

      await tester.pump();
      expect(find.byType(ContactPage), findsOneWidget);
    });
  });
}
