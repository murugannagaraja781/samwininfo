import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

typedef RealtimeEventCallback = void Function(String eventType, Map<String, dynamic> payload);

class RealtimeService {
  static final RealtimeService _instance = RealtimeService._internal();
  factory RealtimeService() => _instance;
  RealtimeService._internal();

  http.Client? _client;
  bool _isConnected = false;
  bool _isDisposed = false;
  String? _currentUserPhone;
  final List<RealtimeEventCallback> _listeners = [];
  Timer? _reconnectTimer;

  bool get isConnected => _isConnected;

  void addListener(RealtimeEventCallback callback) {
    if (!_listeners.contains(callback)) {
      _listeners.add(callback);
    }
  }

  void removeListener(RealtimeEventCallback callback) {
    _listeners.remove(callback);
  }

  void startListening(String userPhone) {
    final cleanPhone = userPhone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) return;

    if (_isConnected && _currentUserPhone == cleanPhone) {
      return;
    }

    stopListening();
    _isDisposed = false;
    _currentUserPhone = cleanPhone;
    _connectStream();
  }

  void stopListening() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _client?.close();
    _client = null;
    _isConnected = false;
    _currentUserPhone = null;
  }

  Future<void> _connectStream() async {
    if (_isDisposed || _currentUserPhone == null) return;

    final baseUrl = ApiConfig.instance.serverUrl;
    final uri = Uri.parse('$baseUrl/events.php?user_phone=${Uri.encodeComponent(_currentUserPhone!)}');

    try {
      _client = http.Client();
      final request = http.Request('GET', uri)
        ..headers['Accept'] = 'text/event-stream'
        ..headers['Cache-Control'] = 'no-cache';

      final response = await _client!.send(request);

      if (response.statusCode == 200) {
        _isConnected = true;
        debugPrint('[RealtimeService] SSE Connected for $_currentUserPhone');

        String currentEvent = 'message';

        await for (final line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (_isDisposed) break;

          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;

          if (trimmed.startsWith('event:')) {
            currentEvent = trimmed.substring(6).trim();
          } else if (trimmed.startsWith('data:')) {
            final dataStr = trimmed.substring(5).trim();
            if (dataStr.isNotEmpty && dataStr != '{"reconnect": true}') {
              try {
                final Map<String, dynamic> json = jsonDecode(dataStr);
                final payload = json['payload'] is Map<String, dynamic>
                    ? json['payload'] as Map<String, dynamic>
                    : json;
                _dispatch(currentEvent, payload);
              } catch (_) {
                // Ignore raw ping/malformed data
              }
            }
            currentEvent = 'message';
          }
        }
      }
    } catch (e) {
      debugPrint('[RealtimeService] SSE Connection error: $e');
    } finally {
      _isConnected = false;
      _client?.close();
      _client = null;

      // Reconnect if not disposed
      if (!_isDisposed && _currentUserPhone != null) {
        _reconnectTimer?.cancel();
        _reconnectTimer = Timer(const Duration(seconds: 2), () {
          if (!_isDisposed) {
            _connectStream();
          }
        });
      }
    }
  }

  void _dispatch(String eventType, Map<String, dynamic> payload) {
    for (final listener in List.of(_listeners)) {
      try {
        listener(eventType, payload);
      } catch (e) {
        debugPrint('[RealtimeService] Error dispatching event $eventType: $e');
      }
    }
  }
}
