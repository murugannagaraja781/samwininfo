import 'package:flutter/foundation.dart';
import '../local/local_storage_service.dart';
import '../local/seed_data.dart';
import '../remote/property_api_service.dart';
import '../../core/config/api_config.dart';
import '../../models/agent.dart';
import '../../models/property.dart';

class PropertyRepository {
  final LocalStorageService _storage;
  final PropertyApiService _apiService = PropertyApiService();

  PropertyRepository(this._storage);

  DateTime? _lastSyncTime;

  /// Synchronize properties from remote server when online mode is active
  /// Avoids unwanted API calls if data was fetched within the last 3 minutes
  Future<bool> syncWithRemoteServer({bool force = false}) async {
    if (!ApiConfig.instance.isOnlineMode) return false;

    // Avoid unwanted API calls: if synced less than 3 minutes ago, return cached data
    if (!force && _lastSyncTime != null && DateTime.now().difference(_lastSyncTime!).inMinutes < 3) {
      return true;
    }

    try {
      final remoteProperties = await _apiService.fetchProperties();
      // Cache remote properties into local storage (even if empty, to clear stale data)
      await _storage.saveProperties(remoteProperties);
      _lastSyncTime = DateTime.now();
      return true;
    } catch (e) {
      debugPrint('Sync with remote server failed, falling back to local cache: $e');
      return false;
    }
  }

  List<Property> getAllProperties() {
    final favorites = _storage.getFavoriteIds().toSet();
    final props = _storage.getProperties();
    return props.map((p) => p.copyWith(isFavorite: favorites.contains(p.id))).toList();
  }

  Property? getPropertyById(String id) {
    try {
      final all = getAllProperties();
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Property> getFeaturedProperties() {
    return getAllProperties().where((p) => p.isFeatured && p.status == 'active').toList();
  }

  List<Property> getNearbyProperties(String location) {
    final cityOrArea = location.split(',').first.trim().toLowerCase();
    final all = getAllProperties().where((p) => p.status == 'active').toList();
    final matching = all.where((p) => p.location.toLowerCase().contains(cityOrArea)).toList();
    if (matching.length >= 3) return matching;
    return all.take(6).toList();
  }

  List<Property> getLatestProperties() {
    final all = getAllProperties().where((p) => p.status == 'active').toList();
    all.sort((a, b) => b.postedDate.compareTo(a.postedDate));
    return all;
  }

  List<Property> getRecommendedProperties() {
    final all = getAllProperties().where((p) => p.status == 'active').toList();
    return all.reversed.take(6).toList();
  }

  List<Property> getPropertiesByCategory(String categoryId) {
    final all = getAllProperties().where((p) => p.status == 'active').toList();
    if (categoryId.toLowerCase() == 'all') return all;

    return all.where((p) {
      final type = p.propertyType.toLowerCase();
      final target = categoryId.toLowerCase();
      if (target == 'house' || target == 'villa') return type.contains('house') || type.contains('villa');
      if (target == 'land' || target == 'plot' || target == 'plots') return type == 'land' || type.contains('land') || type.contains('plot');
      if (target == 'farmland' || target == 'farm land' || target == 'farm' || target == 'thottam') return type.contains('farm') || type.contains('thottam');
      if (target == 'shop' || target == 'commercial' || target == 'office') {
        return type.contains('shop') || type.contains('commercial') || type.contains('office') || type.contains('retail') || p.rentalSubType == 'Commercial / Shop' || p.commercialAreaType != null;
      }
      if (target == 'apartment' || target == 'flat') return type.contains('apartment') || type.contains('flat');
      if (target == 'rental' || target == 'lease') return p.isRental || type.contains('rental') || type.contains('lease') || p.rentalSubType != null;
      return type.contains(target);
    }).toList();
  }

  List<Property> getFavoriteProperties() {
    final favorites = _storage.getFavoriteIds().toSet();
    return getAllProperties().where((p) => favorites.contains(p.id)).toList();
  }

  List<Property> getUserPostedProperties({String? status, String? userPhone, String? userEmail}) {
    final all = getAllProperties().where((p) {
      if (!p.isUserPosted) return false;

      // 1. Strict match by Google email
      if (userEmail != null && userEmail.trim().isNotEmpty && p.agent.email.trim().isNotEmpty) {
        return p.agent.email.trim().toLowerCase() == userEmail.trim().toLowerCase();
      }

      // 2. Match by verified phone number (ONLY if email does not mismatch)
      if (userPhone != null && userPhone.isNotEmpty) {
        if (userEmail != null && userEmail.trim().isNotEmpty && p.agent.email.trim().isNotEmpty && p.agent.email.trim().toLowerCase() != userEmail.trim().toLowerCase()) {
          return false;
        }
        final cleanTarget = userPhone.replaceAll(RegExp(r'[^0-9]'), '');
        final pPhone = (p.contactPhone ?? p.agent.phone).replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanTarget.length >= 10 && pPhone.length >= 10) {
          final targetSuffix = cleanTarget.substring(cleanTarget.length - 10);
          final pSuffix = pPhone.substring(pPhone.length - 10);
          return targetSuffix == pSuffix;
        }
      }

      return false;
    }).toList();
    if (status == null || status == 'all') return all;
    return all.where((p) => p.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Filter and Search Engine
  List<Property> searchAndFilter({
    String? query,
    String? categoryId,
    String? location,
    double? minPrice,
    double? maxPrice,
    List<String>? bhkList,
    String? furnishing,
    bool? verifiedOnly,
    String? sortBy, // 'price_low_to_high', 'price_high_to_low', 'newest', 'popular'
  }) {
    List<Property> results = getAllProperties();

    // Text search (Title, location, city, propertyType, description)
    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      results = results.where((p) {
        return p.title.toLowerCase().contains(q) ||
            p.location.toLowerCase().contains(q) ||
            p.city.toLowerCase().contains(q) ||
            p.propertyType.toLowerCase().contains(q) ||
            (p.landmark != null && p.landmark!.toLowerCase().contains(q)) ||
            p.description.toLowerCase().contains(q);
      }).toList();
    }

    // Category filter
    if (categoryId != null && categoryId.toLowerCase() != 'all') {
      final target = categoryId.toLowerCase();
      results = results.where((p) {
        final type = p.propertyType.toLowerCase();
        if (target == 'house' || target == 'villa') return type.contains('house') || type.contains('villa');
        if (target == 'land' || target == 'plot' || target == 'plots') return type == 'land' || type.contains('land') || type.contains('plot');
        if (target == 'farmland' || target == 'farm land' || target == 'farm' || target == 'thottam') return type.contains('farm') || type.contains('thottam');
        if (target == 'shop' || target == 'commercial' || target == 'office') {
          return type.contains('shop') || type.contains('commercial') || type.contains('office') || type.contains('retail') || p.rentalSubType == 'Commercial / Shop' || p.commercialAreaType != null;
        }
        if (target == 'apartment' || target == 'flat') return type.contains('apartment') || type.contains('flat');
        if (target == 'rental' || target == 'lease') return p.isRental || type.contains('rental') || type.contains('lease') || p.rentalSubType != null;
        return type.contains(target);
      }).toList();
    }

    // Location filter
    if (location != null && location.isNotEmpty && location != 'All Locations') {
      final loc = location.split(',').first.trim().toLowerCase();
      results = results.where((p) => p.location.toLowerCase().contains(loc)).toList();
    }

    // Price range
    if (minPrice != null && minPrice > 0) {
      results = results.where((p) => p.price >= minPrice).toList();
    }
    if (maxPrice != null && maxPrice > 0) {
      results = results.where((p) => p.price <= maxPrice).toList();
    }

    // BHK filter
    if (bhkList != null && bhkList.isNotEmpty) {
      results = results.where((p) {
        if (p.bedrooms == null) return false;
        final bhkStr = '${p.bedrooms} BHK';
        if (bhkList.contains(bhkStr)) return true;
        if (bhkList.contains('4+ BHK') && p.bedrooms! >= 4) return true;
        return false;
      }).toList();
    }

    // Furnishing status
    if (furnishing != null && furnishing != 'Any' && furnishing.isNotEmpty) {
      results = results.where((p) => p.furnishingStatus.toLowerCase() == furnishing.toLowerCase()).toList();
    }

    // Verified only
    if (verifiedOnly == true) {
      results = results.where((p) => p.isVerified).toList();
    }

    // Sorting
    if (sortBy != null) {
      switch (sortBy) {
        case 'price_low_to_high':
          results.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'price_high_to_low':
          results.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'newest':
          results.sort((a, b) => b.postedDate.compareTo(a.postedDate));
          break;
        case 'popular':
          results.sort((a, b) => (b.views + b.enquiries * 2).compareTo(a.views + a.enquiries * 2));
          break;
      }
    }

    return results;
  }

  // Mutations
  Future<void> addProperty(Property property) async {
    await _storage.addProperty(property);
    if (ApiConfig.instance.isOnlineMode) {
      try {
        await _apiService.createProperty(property);
      } catch (e) {
        debugPrint('Remote create failed, retained in local storage: $e');
      }
    }
  }

  Future<void> updateProperty(Property property) async {
    await _storage.updateProperty(property);
    if (ApiConfig.instance.isOnlineMode) {
      try {
        await _apiService.updateProperty(property);
      } catch (e) {
        debugPrint('Remote update failed, retained in local storage: $e');
      }
    }
  }

  Future<void> deleteProperty(String id) async {
    await _storage.deleteProperty(id);
    if (ApiConfig.instance.isOnlineMode) {
      try {
        await _apiService.deleteProperty(id);
      } catch (e) {
        debugPrint('Remote delete failed: $e');
      }
    }
  }

  Future<void> toggleFavorite(String propertyId) async {
    await _storage.toggleFavorite(propertyId);
  }

  List<Agent> getAgents() {
    return SeedData.initialAgents;
  }

  Agent? getAgentById(String id) {
    try {
      return getAgents().firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Property> getPropertiesByAgent(String agentId) {
    return getAllProperties().where((p) => p.agent.id == agentId).toList();
  }
}
