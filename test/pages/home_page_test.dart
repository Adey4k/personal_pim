import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_pim/pages/home_page.dart';
import 'package:personal_pim/services/firestore_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../helpers/test_app.dart';
import 'home_page_test.mocks.dart';

@GenerateMocks([FirestoreService])
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
  });

  testWidgets('HomePage shows contact list smoke test', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      createTestApp(
        home: const HomePage(),
        firestoreService: mockFirestoreService,
      ),
    );

    await tester.pump();
    expect(find.byType(HomePage), findsOneWidget);
  });
}
