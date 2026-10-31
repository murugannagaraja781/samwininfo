import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'core/config/api_config.dart';
import 'data/local/local_storage_service.dart';
import 'state/app_state_providers.dart';
import 'core/services/fcm_notification_service.dart';
import 'features/admin/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase and background messaging
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase Admin initialization error: $e');
  }

  // Set status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize offline storage & API config
  final localStorageService = await LocalStorageService.init();
  await ApiConfig.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(localStorageService),
      ],
      child: const TenkasiDreamsAdminApp(),
    ),
  );
}

final GlobalKey<NavigatorState> adminNavigatorKey = GlobalKey<NavigatorState>();

class TenkasiDreamsAdminApp extends StatefulWidget {
  const TenkasiDreamsAdminApp({super.key});

  @override
  State<TenkasiDreamsAdminApp> createState() => _TenkasiDreamsAdminAppState();
}

class _TenkasiDreamsAdminAppState extends State<TenkasiDreamsAdminApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FcmNotificationService().initialize(adminNavigatorKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: adminNavigatorKey,
      title: 'SamWin Admin',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0F3D6E),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F3D6E),
          primary: const Color(0xFF0F3D6E),
          secondary: const Color(0xFF0284C7),
        ),
        textTheme: GoogleFonts.notoSansTamilTextTheme(
          Theme.of(context).textTheme,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F3D6E),
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: const AdminDashboardScreen(),
    );
  }
}
