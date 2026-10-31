import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/api_config.dart';
import 'core/theme/app_theme.dart';
import 'data/local/local_storage_service.dart';
import 'features/navigation/main_navigation_screen.dart';
import 'state/app_state_providers.dart';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/fcm_notification_service.dart';
import 'core/l10n/locale_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and Google Sign-In in parallel
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (!kIsWeb) {
      await GoogleSignIn.instance.initialize(
        serverClientId: '472022657503-rrpdp12ussod2875eiva4vs74iq5p4oi.apps.googleusercontent.com',
      );
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
  } catch (e) {
    debugPrint('Firebase / GoogleSignIn initialization error: $e');
  }

  // Set transparent system status bar for modern edge-to-edge feel
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Lock to portrait mode for standard mobile layout
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize offline local storage, seed data, and backend API config
  final localStorageService = await LocalStorageService.init();
  await ApiConfig.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
      ],
      child: const RealEstateApp(),
    ),
  );
}

class RealEstateApp extends ConsumerWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'SamWin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: currentLocale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ta', 'IN'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const MainNavigationScreen(),
    );
  }
}
