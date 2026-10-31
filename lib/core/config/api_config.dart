import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig extends ChangeNotifier {
  static const String _keyServerUrl = 'np_server_url';
  static const String _keyOnlineMode = 'np_online_mode_enabled';

  static final ApiConfig instance = ApiConfig._();
  ApiConfig._();

  String _serverUrl = 'https://ads.mithradigitalsolutions.com/api';
  bool _isOnlineMode = true; // Connected directly to live production server
  bool _isCheckingConnection = false;
  String? _lastPingStatus;
  int? _lastPingLatencyMs;

  String get serverUrl => _serverUrl;
  bool get isOnlineMode => _isOnlineMode;
  bool get isCheckingConnection => _isCheckingConnection;
  String? get lastPingStatus => _lastPingStatus;
  int? get lastPingLatencyMs => _lastPingLatencyMs;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_keyServerUrl);
      if (savedUrl == null || savedUrl.contains('tenkasidreams.com') || savedUrl.contains('navanagari.com')) {
        _serverUrl = 'https://ads.mithradigitalsolutions.com/api';
        await prefs.setString(_keyServerUrl, _serverUrl);
      } else {
        _serverUrl = savedUrl;
      }
      _isOnlineMode = prefs.getBool(_keyOnlineMode) ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('ApiConfig init error: $e');
    }
  }

  Future<void> setServerUrl(String url) async {
    _serverUrl = url.trim();
    if (_serverUrl.endsWith('/')) {
      _serverUrl = _serverUrl.substring(0, _serverUrl.length - 1);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyServerUrl, _serverUrl);
    notifyListeners();
  }

  Future<void> setOnlineMode(bool enabled) async {
    _isOnlineMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnlineMode, _isOnlineMode);
    notifyListeners();
  }

  /// Pings the configured server to verify connectivity
  Future<bool> testConnection() async {
    _isCheckingConnection = true;
    _lastPingStatus = 'Testing connection...';
    _lastPingLatencyMs = null;
    notifyListeners();

    final stopwatch = Stopwatch()..start();
    try {
      final uri = Uri.parse('$_serverUrl/ping');
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 4));
      stopwatch.stop();
      _lastPingLatencyMs = stopwatch.elapsedMilliseconds;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        _lastPingStatus = 'Connected (${_lastPingLatencyMs}ms)';
        _isCheckingConnection = false;
        notifyListeners();
        return true;
      } else {
        _lastPingStatus = 'Server responded with code ${response.statusCode}';
        _isCheckingConnection = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      stopwatch.stop();
      _lastPingLatencyMs = stopwatch.elapsedMilliseconds;
      _lastPingStatus = 'Unreachable (${e.toString().split('\n').first})';
      _isCheckingConnection = false;
      notifyListeners();
      return false;
    }
  }
}
