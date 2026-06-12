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
import 'services/notification_service.dart';
import 'services/firestore_service.dart';
import 'pages/contact_page.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GoogleSignIn.instance.initialize(
    serverClientId: Env.googleClientId,
  );

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale(WidgetsBinding.instance.platformDispatcher.locale);

  await NotificationService().init();

  HomeWidget.registerInteractivityCallback(interactiveCallback);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeProvider),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
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
      title: 'Personal PIM',
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
  static const _channel = MethodChannel('com.ladikov.personal_pim/deeplink');
  bool _initialUriHandled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HomeWidget.setAppGroupId('group.com.ladikov.personal_pim');
    _checkLaunchedFromWidget();
    _checkInitialIntent();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkNewIntent();
    }
  }

  void _checkLaunchedFromWidget() async {
    final uri = await HomeWidget.initiallyLaunchedFromHomeWidget();
    if (uri != null) {
      _handleUri(uri);
      _initialUriHandled = true;
    }
    HomeWidget.widgetClicked.listen(_handleUri);
  }

  /// Check the initial intent that launched the app (for deep links via ACTION_VIEW)
  void _checkInitialIntent() async {
    if (_initialUriHandled) return;
    try {
      final String? uriString = await _channel.invokeMethod('getInitialUri');
      if (uriString != null && uriString.isNotEmpty) {
        _handleUri(Uri.tryParse(uriString));
        _initialUriHandled = true;
      }
    } catch (_) {
      // Platform channel not available — ignore
    }
  }

  /// Check for new intents when app is resumed from background
  void _checkNewIntent() async {
    try {
      final String? uriString = await _channel.invokeMethod('getLatestUri');
      if (uriString != null && uriString.isNotEmpty) {
        _handleUri(Uri.tryParse(uriString));
      }
    } catch (_) {
      // Platform channel not available — ignore
    }
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
    final firestore = FirestoreService();
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
