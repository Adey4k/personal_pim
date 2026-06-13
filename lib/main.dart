import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'package:home_widget/home_widget.dart';
import 'pages/login_page.dart';
import 'pages/home_page.dart';
import 'pages/verify_email_page.dart';
import 'utils/env.dart';
import 'providers/locale_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/tutorial_provider.dart';
import 'providers/contacts_provider.dart';
import 'services/notification_service.dart';
import 'services/firestore_service.dart';
import 'services/gemini_service.dart';
import 'services/speech_service.dart';
import 'pages/contact_page.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  GoogleSignIn.instance.initialize(
    serverClientId: Env.googleClientId,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale(WidgetsBinding.instance.platformDispatcher.locale);

  final themeProvider = ThemeProvider();
  await themeProvider.init();

  await NotificationService().init();

  final notificationProvider = NotificationProvider();
  await notificationProvider.init();

  final tutorialProvider = TutorialProvider();
  await tutorialProvider.init();

  HomeWidget.registerInteractivityCallback(interactiveCallback);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: notificationProvider),
        ChangeNotifierProvider.value(value: tutorialProvider),
        ChangeNotifierProvider(create: (context) => ContactsProvider()),
        Provider<FirestoreService>(create: (context) => FirestoreService()),
        Provider<GeminiService>(create: (context) => GeminiService()),
        Provider<SpeechService>(create: (context) => SpeechService()),
      ],
      child: const MyApp(),
    ),
  );
}

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? uri) async {
  // Logic for background actions if needed.
  // Currently, we mostly use deep links.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeProvider.seedColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeProvider.seedColor,
            brightness: Brightness.dark,
            surface: const Color(0xFF1A1C1E),
          ),
          scaffoldBackgroundColor: const Color(0xFF1A1C1E),
        ),
        themeMode: themeProvider.themeMode,
        locale: localeProvider.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          return MediaQuery(
            data: mediaQueryData.copyWith(
              textScaler: mediaQueryData.textScaler.clamp(
                minScaleFactor: 0.8,
                maxScaleFactor: 1.1,
              ),
            ),
            child: child!,
          );
        },
        home: const AppRoot(),
      );
  }
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          final user = snapshot.data!;
          if (user.emailVerified) {
            return const AppNavigationHandler();
          }
          return const VerifyEmailPage();
        }
        return const LoginPage();
      },
    );
  }
}

class AppNavigationHandler extends StatefulWidget {
  const AppNavigationHandler({super.key});

  @override
  State<AppNavigationHandler> createState() => _AppNavigationHandlerState();
}

class _AppNavigationHandlerState extends State<AppNavigationHandler>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HomeWidget.setAppGroupId('group.com.ladikov.personal_pim');
    _checkLaunchedFromWidget();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Rely on HomeWidget.widgetClicked stream to handle deep links
  }

  void _checkLaunchedFromWidget() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _handleUri(uri);
    }
    HomeWidget.widgetClicked.listen(_handleUri);
  }

  void _handleUri(Uri? uri) {
    if (uri == null) return;
    if (uri.scheme == 'personalpim' && uri.host == 'add_contact') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const ContactPage(
            existingFields: {},
            existingNames: {},
            existingGroups: {},
            existingFieldTypes: {},
          ),
        ),
      );
    } else if (uri.scheme == 'personalpim' && uri.host == 'contact') {
      final contactId = uri.queryParameters['id'];
      if (contactId != null) {
        _navigateToContact(contactId);
      }
    }
  }

  void _navigateToContact(String id) async {
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final contact = await firestore.getContact(id);
    if (contact != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ContactPage(
            existingFields: {},
            existingNames: {},
            existingGroups: {},
            contact: contact,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
