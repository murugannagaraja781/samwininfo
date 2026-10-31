import 'dart:async';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:http/http.dart' as http;
import '../../admin_main.dart';
import '../../firebase_options.dart';
import '../../models/agent.dart';
import '../../models/property.dart';
import '../config/api_config.dart';
import '../../features/admin/incoming_ad_alert_dialog.dart';
import '../../features/admin/admin_dashboard_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  // If a new property ad alert arrives in background/killed, sound the alarm
  final data = message.data;
  if (data['type'] == 'new_property_ad') {
    try {
      FlutterRingtonePlayer().play(
        android: AndroidSounds.alarm,
        ios: IosSounds.alarm,
        looping: true,
        volume: 1.0,
      );
    } catch (_) {}
  }
}

class FcmNotificationService {
  static final FcmNotificationService _instance = FcmNotificationService._internal();
  factory FcmNotificationService() => _instance;
  FcmNotificationService._internal();

  GlobalKey<NavigatorState>? _navKey;
  BuildContext? _currentContext;
  bool _isInitialized = false;

  void updateContext(BuildContext context) {
    _currentContext = context;
  }

  void setNavigatorKey(GlobalKey<NavigatorState> navKey) {
    _navKey = navKey;
  }

  BuildContext? get _context => _navKey?.currentContext ?? _currentContext;

  Future<void> initialize([dynamic contextOrKey]) async {
    if (contextOrKey is GlobalKey<NavigatorState>) {
      _navKey = contextOrKey;
    } else if (contextOrKey is BuildContext) {
      _currentContext = contextOrKey;
    } else {
      _navKey = adminNavigatorKey;
    }

    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final messaging = FirebaseMessaging.instance;

      // Request notification permissions (including Android 13+)
      await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );

      // Subscribe to Super Admin new ads topic
      await messaging.subscribeToTopic('admin_new_ads');

      // Foreground message listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleIncomingMessage(message, isClick: false);
      });

      // Notification click listener (when app opened from notification)
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleIncomingMessage(message, isClick: true);
      });

      // Check if app was opened from terminated state by a notification
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleIncomingMessage(initialMessage, isClick: true);
      }
    } catch (e) {
      debugPrint('FCM initialization note: $e');
    }
  }

  Future<void> _handleIncomingMessage(RemoteMessage message, {required bool isClick}) async {
    // Stop any background alarm playing
    try {
      FlutterRingtonePlayer().stop();
    } catch (_) {}

    final data = message.data;
    if (data['type'] != 'new_property_ad') return;

    final propId = data['property_id'] ?? '';
    if (propId.isEmpty) return;

    if (isClick) {
      debugPrint('FCM Notification tapped! Opening pending tab for propId: $propId');
      // Wait briefly for framework to settle
      await Future.delayed(const Duration(milliseconds: 150));

      // 1. Pop back to dashboard if deep inside another route
      _navKey?.currentState?.popUntil((route) => route.isFirst);

      // 2. Switch to Pending tab & show incoming ad alert / pending list
      if (AdminDashboardScreen.instance != null && AdminDashboardScreen.instance!.mounted) {
        AdminDashboardScreen.openPendingTab(propertyId: propId);
      } else {
        _navKey?.currentState?.pushReplacement(
          MaterialPageRoute(
            builder: (_) => AdminDashboardScreen(
              initialTab: 3,
              pendingPropertyId: propId,
            ),
          ),
        );
      }
      return;
    }

    // Foreground message handling
    // Fetch full property details
    Property? property;
    try {
      final url = Uri.parse('${ApiConfig.instance.serverUrl}/properties.php?id=$propId');
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final resData = jsonDecode(res.body);
        if (resData['property'] != null) {
          property = Property.fromMap(resData['property'] as Map<String, dynamic>);
        }
      }
    } catch (_) {}

    // Fallback: build lightweight property from FCM data if API is slow
    property ??= Property(
      id: propId,
      title: data['property_title'] ?? 'புதிய விளம்பரம்',
      description: 'Super Admin Approval Request',
      price: double.tryParse(data['price']?.toString() ?? '0') ?? 0,
      location: data['location'] ?? 'தென்காசி',
      city: 'தென்காசி',
      propertyType: data['property_type'] ?? 'Land',
      areaSqFt: 0,
      contactPhone: data['seller_phone'] ?? '',
      agent: Agent(
        id: 'agent_$propId',
        name: data['seller_name'] ?? 'பயனர்',
        agencyName: 'Direct Owner',
        phone: data['seller_phone'] ?? '',
        email: '',
        avatarKey: 'avatar_user',
        rating: 5.0,
        reviewsCount: 0,
        experienceYears: 0,
        totalListings: 1,
        isVerified: true,
        about: '',
      ),
      postedDate: DateTime.now(),
      status: 'pending',
    );

    final ctx = _context;
    if (ctx != null && ctx.mounted) {
      IncomingAdAlertDialog.show(
        ctx,
        property,
        onHandled: () {
          AdminDashboardScreen.openPendingTab(propertyId: propId);
        },
      );
    }
  }
}

