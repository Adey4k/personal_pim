import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_pim/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../helpers/test_app.dart';
import 'home_page_test.mocks.dart';

void main() {
  late MockFirestoreService mockFirestoreService;

  setUp(() {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('UTC'));

    mockFirestoreService = MockFirestoreService();

    when(
      mockFirestoreService.getContactsStream(),
    ).thenAnswer((_) => Stream.value([]));
    when(
      mockFirestoreService.getTodosStream(),
    ).thenAnswer((_) => Stream.value([]));
    when(
      mockFirestoreService.getAllContacts(),
    ).thenAnswer((_) => Future.value([]));
  });

  testWidgets('Navigation switches between tabs', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      createTestApp(
        home: const HomePage(),
        firestoreService: mockFirestoreService,
      ),
    );

    await tester.pumpAndSettle();

    // Initially at Home (Contacts)
    expect(find.text('Home'), findsWidgets);

    // Tap Calendar
    await tester.tap(find.byIcon(Icons.calendar_today));
    await tester.pumpAndSettle();

    expect(find.text('Calendar'), findsWidgets);

    // Tap Settings
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsWidgets);
    expect(find.text('Logout'), findsOneWidget);
  });
}
