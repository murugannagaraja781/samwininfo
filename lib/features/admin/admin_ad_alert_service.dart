import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../models/property.dart';
import 'incoming_ad_alert_dialog.dart';

class AdminAdAlertService {
  static final AdminAdAlertService _instance = AdminAdAlertService._internal();
  factory AdminAdAlertService() => _instance;
  AdminAdAlertService._internal();

  static const String _keyHandledPendingIds = 'tenkasi_admin_handled_pending_ids_v1';
  Timer? _pollingTimer;
  final Set<String> _handledPendingIds = {};
  BuildContext? _currentContext;
  bool _isListening = false;
  bool _isInitialized = false;

  Future<void> _loadHandledIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(_keyHandledPendingIds) ?? [];
      _handledPendingIds.addAll(list);
    } catch (_) {}
  }

  Future<void> _saveHandledIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep up to latest 500 IDs
      final list = _handledPendingIds.toList();
      if (list.length > 500) {
        list.removeRange(0, list.length - 500);
      }
      await prefs.setStringList(_keyHandledPendingIds, list);
    } catch (_) {}
  }

  Future<void> markHandled(String id) async {
    if (id.isEmpty) return;
    _handledPendingIds.add(id);
    await _saveHandledIds();
  }

  void startMonitoring(BuildContext context) async {
    _currentContext = context;
    await _loadHandledIds();
    if (_isListening) return;
    _isListening = true;

    // Initial check
    _checkPendingAds();

    // 5-second ultra-lightweight check (83 bytes payload, zero UI lag)
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkPendingAds();
    });
  }

  void updateContext(BuildContext context) {
    _currentContext = context;
  }

  void stopMonitoring() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _isListening = false;
  }

  Future<void> _checkPendingAds() async {
    if (_currentContext == null || !_currentContext!.mounted) return;

    try {
      // 1. Query ultra-lightweight status check (returns in <5ms, only ~83 bytes)
      final checkUrl = Uri.parse('${ApiConfig.instance.serverUrl}/properties.php?action=pending_check');
      final res = await http.get(checkUrl).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final int pendingCount = data['pending_count'] ?? 0;
        final String latestId = data['latest_pending_id'] ?? '';

        if (!_isInitialized) {
          if (latestId.isNotEmpty) {
            _handledPendingIds.add(latestId);
            await _saveHandledIds();
          }
          _isInitialized = true;
          return;
        }

        // Only when a brand new pending ad appears, fetch that specific property
        if (pendingCount > 0 && latestId.isNotEmpty && !_handledPendingIds.contains(latestId)) {
          _handledPendingIds.add(latestId);
          await _saveHandledIds();

          final propUrl = Uri.parse('${ApiConfig.instance.serverUrl}/properties.php?id=$latestId');
          final propRes = await http.get(propUrl).timeout(const Duration(seconds: 5));
          if (propRes.statusCode == 200) {
            final propData = jsonDecode(propRes.body);
            if (propData['property'] != null) {
              final prop = Property.fromMap(propData['property'] as Map<String, dynamic>);
              _triggerAlert(prop);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Admin pending ad check note: $e');
    }
  }

  void _triggerAlert(Property property) {
    if (_currentContext != null && _currentContext!.mounted) {
      IncomingAdAlertDialog.show(
        _currentContext!,
        property,
        onHandled: () {
          markHandled(property.id);
        },
      );
    }
  }
}
