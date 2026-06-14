import 'package:flutter/material.dart';
import 'package:personal_pim/l10n/app_localizations.dart';
import 'package:personal_pim/providers/contacts_provider.dart';
import 'package:personal_pim/providers/locale_provider.dart';
import 'package:personal_pim/providers/notification_provider.dart';
import 'package:personal_pim/providers/theme_provider.dart';
import 'package:personal_pim/services/firestore_service.dart';
import 'package:provider/provider.dart';

Widget createTestApp({
  required Widget home,
  FirestoreService? firestoreService,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ChangeNotifierProvider(create: (_) => ContactsProvider()),
      if (firestoreService != null)
        Provider<FirestoreService>.value(value: firestoreService),
    ],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home,
    ),
  );
}
