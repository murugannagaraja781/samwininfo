import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../../models/property.dart';

class PropertyApiService {
  final ApiConfig _config = ApiConfig.instance;

  String get _baseUrl => _config.serverUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Fetch all properties from the remote server
  Future<List<Property>> fetchProperties() async {
    try {
      final uri = Uri.parse('$_baseUrl/properties?all=true');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        final List<dynamic> list = decoded is List
            ? decoded
            : (decoded['properties'] ?? decoded['data'] ?? []);
        return list.map((item) => Property.fromMap(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Server returned code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('PropertyApiService fetchProperties error: $e');
      rethrow;
    }
  }

  /// Fetch all buyer requirements (மக்களின் தேவை) from remote server
  Future<List<Map<String, dynamic>>> fetchBuyerRequirements() async {
    try {
      final uri = Uri.parse('$_baseUrl/requirements.php');
      final response = await http
          .get(uri, headers: _headers)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        final List<dynamic> list = decoded is List
            ? decoded
            : (decoded['requirements'] ?? decoded['data'] ?? []);
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('PropertyApiService fetchBuyerRequirements error: $e');
      return [];
    }
  }

  /// Post a new buyer requirement to remote server
  Future<bool> createBuyerRequirement(Map<String, dynamic> reqData) async {
    try {
      final uri = Uri.parse('$_baseUrl/requirements.php');
      final response = await http
          .post(uri, headers: _headers, body: jsonEncode(reqData))
          .timeout(const Duration(seconds: 6));
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('PropertyApiService createBuyerRequirement error: $e');
      return false;
    }
  }

  /// Create a new property listing on the remote server
  Future<Property> createProperty(Property property) async {
    try {
      final uri = Uri.parse('$_baseUrl/properties');
      final body = jsonEncode(property.toMap());

      final response = await http
          .post(uri, headers: _headers, body: body)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final dynamic decoded = jsonDecode(response.body);
        final Map<String, dynamic> data =
            decoded is Map<String, dynamic> && decoded.containsKey('data')
                ? decoded['data']
                : decoded;
        return Property.fromMap(data);
      } else {
        throw Exception('Server returned code ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('PropertyApiService createProperty error: $e');
      rethrow;
    }
  }

  /// Update an existing property listing on the remote server
  Future<Property> updateProperty(Property property) async {
    try {
      final uri = Uri.parse('$_baseUrl/properties/${property.id}');
      final body = jsonEncode(property.toMap());

      final response = await http
          .put(uri, headers: _headers, body: body)
          .timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final dynamic decoded = jsonDecode(response.body);
        final Map<String, dynamic> data =
            decoded is Map<String, dynamic> && decoded.containsKey('data')
                ? decoded['data']
                : decoded;
        return Property.fromMap(data);
      } else {
        throw Exception('Server returned code ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('PropertyApiService updateProperty error: $e');
      rethrow;
    }
  }

  /// Delete property by ID
  Future<bool> deleteProperty(String propertyId) async {
    try {
      final uri = Uri.parse('$_baseUrl/properties/$propertyId');
      final response = await http
          .delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('PropertyApiService deleteProperty error: $e');
      return false;
    }
  }
}
