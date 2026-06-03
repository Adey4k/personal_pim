import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_pim/pages/home_page.dart';
import 'package:personal_pim/services/firestore_service.dart';
import 'package:personal_pim/providers/locale_provider.dart';
import 'package:personal_pim/providers/theme_provider.dart';
import 'package:personal_pim/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:personal_pim/l10n/app_localizations.dart';
import 'package:personal_pim/models/contact.dart';

import 'home_page_test.mocks.dart';

@GenerateMocks([FirestoreService])
void main() {
  testWidgets('HomePage shows contact list smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: HomePage(),
        ),
      ),
    );

    expect(find.byType(HomePage), findsOneWidget);
  });
}
