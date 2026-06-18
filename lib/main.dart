import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'models/contact.dart';
import 'services/notification_service.dart';
import 'services/firestore_service.dart';
import 'services/gemini_service.dart';
import 'services/speech_service.dart';
import 'pages/contact_page.dart';
import 'l10n/app_localizations.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    runApp(const AppBootstrap());
  }, (error, stack) => debugPrint('Unhandled app error: $error\n$stack'));
}

bool _googleSignInInitialized = false;

Future<_AppDependencies> _initializeApp() async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await _tryStartupStep('Google Sign-In initialization', () async {
    if (_googleSignInInitialized) return;

    await GoogleSignIn.instance.initialize(serverClientId: Env.googleClientId);
    _googleSignInInitialized = true;
  });

  await _tryStartupStep('Firestore settings', () async {
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  });

  final localeProvider = LocaleProvider();
  await _tryStartupStep('Locale initialization', () {
    return localeProvider.loadLocale(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
  });

  final themeProvider = ThemeProvider();
  await _tryStartupStep('Theme initialization', themeProvider.init);

  await _tryStartupStep('Notification service initialization', () {
    return NotificationService().init().timeout(const Duration(seconds: 5));
  });

  final notificationProvider = NotificationProvider();
  await _tryStartupStep(
    'Notification settings initialization',
    notificationProvider.init,
  );

  final tutorialProvider = TutorialProvider();
  await _tryStartupStep('Tutorial initialization', tutorialProvider.init);

  await _tryStartupStep('Home widget callback registration', () {
    return HomeWidget.registerInteractivityCallback(interactiveCallback);
  });

  return _AppDependencies(
    localeProvider: localeProvider,
    themeProvider: themeProvider,
    notificationProvider: notificationProvider,
    tutorialProvider: tutorialProvider,
  );
}

Future<void> _tryStartupStep(
  String label,
  Future<void> Function() action,
) async {
  try {
    await action();
  } catch (error, stack) {
    debugPrint('$label failed: $error\n$stack');
  }
}

class _AppDependencies {
  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;
  final NotificationProvider notificationProvider;
  final TutorialProvider tutorialProvider;

  const _AppDependencies({
    required this.localeProvider,
    required this.themeProvider,
    required this.notificationProvider,
    required this.tutorialProvider,
  });
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late Future<_AppDependencies> _dependenciesFuture;

  @override
  void initState() {
    super.initState();
    _dependenciesFuture = _initializeApp();
  }

  void _retry() {
    setState(() {
      _dependenciesFuture = _initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_AppDependencies>(
      future: _dependenciesFuture,
      builder: (context, snapshot) {
        final dependencies = snapshot.data;
        if (dependencies != null) {
          return _AppProviders(
            dependencies: dependencies,
            child: const MyApp(),
          );
        }

        if (snapshot.hasError) {
          return _StartupErrorApp(onRetry: _retry);
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _AppProviders extends StatelessWidget {
  final _AppDependencies dependencies;
  final Widget child;

  const _AppProviders({required this.dependencies, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: dependencies.localeProvider),
        ChangeNotifierProvider.value(value: dependencies.themeProvider),
        ChangeNotifierProvider.value(value: dependencies.notificationProvider),
        ChangeNotifierProvider.value(value: dependencies.tutorialProvider),
        ChangeNotifierProvider(create: (context) => ContactsProvider()),
        Provider<FirestoreService>(create: (context) => FirestoreService()),
        Provider<GeminiService>(create: (context) => GeminiService()),
        Provider<SpeechService>(create: (context) => SpeechService()),
      ],
      child: child,
    );
  }
}

class _StartupErrorApp extends StatelessWidget {
  final VoidCallback onRetry;

  const _StartupErrorApp({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Unable to start Mnemo PIM',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check your connection and try again.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(onPressed: onRetry, child: const Text('Retry')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
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
  StreamSubscription<List<Contact>>? _contactReminderSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HomeWidget.setAppGroupId('group.com.ladikov.personal_pim');
    _checkLaunchedFromWidget();
    _startContactReminderSync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final subscription = _contactReminderSubscription;
    if (subscription != null) {
      unawaited(subscription.cancel());
    }
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

  void _startContactReminderSync() {
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    _contactReminderSubscription = firestore.getContactsStream().listen(
      (contacts) {
        unawaited(
          notificationProvider.scheduleContactEventNotifications(contacts),
        );
      },
      onError: (error) {
        debugPrint('Contact reminder sync error: $error');
      },
    );
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
