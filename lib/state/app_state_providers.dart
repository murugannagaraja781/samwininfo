import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_config.dart';
import '../core/services/realtime_service.dart';
import '../models/user_request.dart';
import '../data/local/local_storage_service.dart';
import '../data/local/seed_data.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/property_repository.dart';
import '../data/remote/property_api_service.dart';
import '../models/buyer_requirement.dart';
import '../models/chat_message.dart';
import '../models/notification_item.dart';
import '../models/property.dart';
import '../models/user_profile.dart';
import '../core/utils/location_service.dart';

// 1. Core Services Providers (initialized at app boot)
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('LocalStorageService must be initialized in main()');
});

final propertyRepositoryProvider = Provider<PropertyRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return PropertyRepository(storage);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return ChatRepository(storage);
});

// 2. Location & Active Category State
class SelectedLocationNotifier extends Notifier<String> {
  @override
  String build() {
    final storage = ref.watch(localStorageServiceProvider);
    return storage.getCurrentLocation();
  }

  void setLocation(String location) {
    state = location;
  }
}

final selectedLocationProvider = NotifierProvider<SelectedLocationNotifier, String>(
  SelectedLocationNotifier.new,
);

class UserLocationState {
  final double? latitude;
  final double? longitude;
  final bool isLiveGps;
  final String areaName;
  final String cityName;

  const UserLocationState({
    this.latitude,
    this.longitude,
    this.isLiveGps = false,
    this.areaName = 'Tenkasi',
    this.cityName = 'Tenkasi, Tamil Nadu',
  });

  UserLocationState copyWith({
    double? latitude,
    double? longitude,
    bool? isLiveGps,
    String? areaName,
    String? cityName,
  }) {
    return UserLocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLiveGps: isLiveGps ?? this.isLiveGps,
      areaName: areaName ?? this.areaName,
      cityName: cityName ?? this.cityName,
    );
  }
}

class UserLocationNotifier extends Notifier<UserLocationState> {
  @override
  UserLocationState build() {
    final location = ref.watch(selectedLocationProvider);
    final coords = LocationService.getCoordinatesForTown(location);
    return UserLocationState(
      latitude: coords?['lat'] ?? 8.9594,
      longitude: coords?['lng'] ?? 77.3160,
      isLiveGps: false,
      areaName: location.split(',').first.trim(),
      cityName: location,
    );
  }

  void setLiveLocation(LiveLocationResult result) {
    state = UserLocationState(
      latitude: result.latitude,
      longitude: result.longitude,
      isLiveGps: result.isLiveGps,
      areaName: result.estimatedArea,
      cityName: '${result.estimatedArea}, ${result.estimatedCity}',
    );
  }

  void setManualLocation(String location, {double? lat, double? lng}) {
    final coords = (lat != null && lng != null)
        ? {'lat': lat, 'lng': lng}
        : LocationService.getCoordinatesForTown(location);
    state = UserLocationState(
      latitude: coords?['lat'] ?? 8.9594,
      longitude: coords?['lng'] ?? 77.3160,
      isLiveGps: false,
      areaName: location.split(',').first.trim(),
      cityName: location,
    );
  }
}

final userLocationProvider = NotifierProvider<UserLocationNotifier, UserLocationState>(
  UserLocationNotifier.new,
);

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  void setCategory(String category) {
    state = category;
  }
}

final selectedCategoryProvider = NotifierProvider<SelectedCategoryNotifier, String>(
  SelectedCategoryNotifier.new,
);

// 3. Properties State Notifier
class PropertiesNotifier extends Notifier<List<Property>> {
  late final PropertyRepository _repo;

  @override
  List<Property> build() {
    _repo = ref.watch(propertyRepositoryProvider);
    Future.microtask(() => syncWithServer());
    return _repo.getAllProperties();
  }

  void refresh() {
    state = _repo.getAllProperties();
  }

  Future<void> toggleFavorite(String propertyId) async {
    await _repo.toggleFavorite(propertyId);
    state = _repo.getAllProperties();
  }

  Future<void> addProperty(Property property) async {
    await _repo.addProperty(property);
    state = _repo.getAllProperties();
  }

  Future<void> updateProperty(Property property) async {
    await _repo.updateProperty(property);
    state = _repo.getAllProperties();
  }

  Future<void> deleteProperty(String propertyId) async {
    await _repo.deleteProperty(propertyId);
    state = _repo.getAllProperties();
  }

  Future<void> markAsSold(String propertyId) async {
    final prop = _repo.getPropertyById(propertyId);
    if (prop != null) {
      final updated = prop.copyWith(status: 'sold');
      await _repo.updateProperty(updated);
      state = _repo.getAllProperties();
    }
  }

  Future<bool> syncWithServer() async {
    final synced = await _repo.syncWithRemoteServer();
    if (synced) {
      state = _repo.getAllProperties();
    }
    return synced;
  }

  Future<void> resetAllData() async {
    final storage = ref.read(localStorageServiceProvider);
    await storage.resetDemoData();
    ref.read(selectedLocationProvider.notifier).setLocation('Tenkasi, Tamil Nadu');
    ref.read(selectedCategoryProvider.notifier).setCategory('all');
    state = _repo.getAllProperties();
  }
}

final propertiesProvider = NotifierProvider<PropertiesNotifier, List<Property>>(
  PropertiesNotifier.new,
);

// 4. Computed Providers for Home Sections
final featuredPropertiesProvider = Provider<List<Property>>((ref) {
  final all = ref.watch(propertiesProvider);
  return all.where((p) => p.isFeatured && p.status == 'active').toList();
});

final nearbyPropertiesProvider = Provider<List<Property>>((ref) {
  final all = List<Property>.from(ref.watch(propertiesProvider).where((p) => p.status == 'active'));
  final userLoc = ref.watch(userLocationProvider);

  if (userLoc.latitude != null && userLoc.longitude != null) {
    all.sort((a, b) {
      final aLat = a.latitude ?? LocationService.getCoordinatesForTown(a.location)?['lat'] ?? 8.9594;
      final aLng = a.longitude ?? LocationService.getCoordinatesForTown(a.location)?['lng'] ?? 77.3160;
      final bLat = b.latitude ?? LocationService.getCoordinatesForTown(b.location)?['lat'] ?? 8.9594;
      final bLng = b.longitude ?? LocationService.getCoordinatesForTown(b.location)?['lng'] ?? 77.3160;

      final distA = LocationService.calculateDistanceKm(userLoc.latitude!, userLoc.longitude!, aLat, aLng);
      final distB = LocationService.calculateDistanceKm(userLoc.latitude!, userLoc.longitude!, bLat, bLng);

      return distA.compareTo(distB);
    });
    return all.take(6).toList();
  }

  final location = ref.watch(selectedLocationProvider);
  final cityOrArea = location.split(',').first.trim().toLowerCase();
  final matching = all.where((p) => p.location.toLowerCase().contains(cityOrArea)).toList();
  if (matching.length >= 3) return matching;
  return all.take(6).toList();
});

final latestPropertiesProvider = Provider<List<Property>>((ref) {
  final all = List<Property>.from(ref.watch(propertiesProvider).where((p) => p.status == 'active'));
  final userLoc = ref.watch(userLocationProvider);

  if (userLoc.latitude != null && userLoc.longitude != null) {
    // Check if user is within 200 km of Tenkasi region
    final distToTenkasi = LocationService.calculateDistanceKm(
      userLoc.latitude!,
      userLoc.longitude!,
      8.9594,
      77.3160,
    );

    // If within 200 km, sort by distance (nearest first)
    if (distToTenkasi < 200) {
      all.sort((a, b) {
        final aLat = a.latitude ?? LocationService.getCoordinatesForTown(a.location)?['lat'] ?? 8.9594;
        final aLng = a.longitude ?? LocationService.getCoordinatesForTown(a.location)?['lng'] ?? 77.3160;
        final bLat = b.latitude ?? LocationService.getCoordinatesForTown(b.location)?['lat'] ?? 8.9594;
        final bLng = b.longitude ?? LocationService.getCoordinatesForTown(b.location)?['lng'] ?? 77.3160;

        final distA = LocationService.calculateDistanceKm(userLoc.latitude!, userLoc.longitude!, aLat, aLng);
        final distB = LocationService.calculateDistanceKm(userLoc.latitude!, userLoc.longitude!, bLat, bLng);

        final cmp = distA.compareTo(distB);
        if (cmp != 0) return cmp;
        return b.postedDate.compareTo(a.postedDate);
      });
      return all;
    }
  }

  // Fallback for foreign / NRI / far away users: Default latest order
  all.sort((a, b) => b.postedDate.compareTo(a.postedDate));
  return all;
});

final recommendedPropertiesProvider = Provider<List<Property>>((ref) {
  final all = ref.watch(propertiesProvider).where((p) => p.status == 'active').toList();
  return all.reversed.take(6).toList();
});

final favoritesListProvider = Provider<List<Property>>((ref) {
  final all = ref.watch(propertiesProvider);
  return all.where((p) => p.isFavorite).toList();
});

// 5. My Ads Tab & Provider
class MyAdsStatusFilterNotifier extends Notifier<String> {
  @override
  String build() => 'active';

  void setFilter(String status) {
    state = status;
  }
}

final myAdsStatusFilterProvider = NotifierProvider<MyAdsStatusFilterNotifier, String>(
  MyAdsStatusFilterNotifier.new,
);

final myAdsListProvider = Provider<List<Property>>((ref) {
  final user = ref.watch(userProfileProvider);
  if (!user.isLoggedIn) return [];

  final cleanUserPhone = user.phone.replaceAll(RegExp(r'[^0-9]'), '');
  final all = ref.watch(propertiesProvider).where((p) {
    if (!p.isUserPosted) return false;
    if (cleanUserPhone.length >= 10) {
      final userSuffix = cleanUserPhone.substring(cleanUserPhone.length - 10);
      final cleanContact = (p.contactPhone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
      final cleanAgentPhone = p.agent.phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanContact.length >= 10 && cleanContact.endsWith(userSuffix)) return true;
      if (cleanAgentPhone.length >= 10 && cleanAgentPhone.endsWith(userSuffix)) return true;
    }
    if (user.email.isNotEmpty && p.agent.email.isNotEmpty) {
      if (p.agent.email.trim().toLowerCase() == user.email.trim().toLowerCase()) {
        return true;
      }
    }
    return false;
  }).toList();

  final filter = ref.watch(myAdsStatusFilterProvider);
  if (filter == 'all') return all;
  return all.where((p) => p.status.toLowerCase() == filter.toLowerCase()).toList();
});

// 6. Search & Filter State
class SearchFilterState {
  final String query;
  final String categoryId;
  final String location;
  final double minPrice;
  final double maxPrice;
  final List<String> bhkList;
  final String furnishing;
  final bool verifiedOnly;
  final String sortBy; // 'price_low_to_high', 'price_high_to_low', 'newest', 'popular'

  const SearchFilterState({
    this.query = '',
    this.categoryId = 'all',
    this.location = 'All Locations',
    this.minPrice = 0,
    this.maxPrice = 50000000, // ₹5 Cr
    this.bhkList = const [],
    this.furnishing = 'Any',
    this.verifiedOnly = false,
    this.sortBy = 'newest',
  });

  bool get hasActiveFilters =>
      categoryId != 'all' ||
      location != 'All Locations' ||
      minPrice > 0 ||
      maxPrice < 50000000 ||
      bhkList.isNotEmpty ||
      furnishing != 'Any' ||
      verifiedOnly ||
      sortBy != 'newest';

  int get activeFilterCount {
    int count = 0;
    if (categoryId != 'all') count++;
    if (location != 'All Locations') count++;
    if (minPrice > 0 || maxPrice < 50000000) count++;
    if (bhkList.isNotEmpty) count += bhkList.length;
    if (furnishing != 'Any') count++;
    if (verifiedOnly) count++;
    if (sortBy != 'newest') count++;
    return count;
  }

  SearchFilterState copyWith({
    String? query,
    String? categoryId,
    String? location,
    double? minPrice,
    double? maxPrice,
    List<String>? bhkList,
    String? furnishing,
    bool? verifiedOnly,
    String? sortBy,
  }) {
    return SearchFilterState(
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      location: location ?? this.location,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      bhkList: bhkList ?? this.bhkList,
      furnishing: furnishing ?? this.furnishing,
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class SearchFilterNotifier extends Notifier<SearchFilterState> {
  @override
  SearchFilterState build() => const SearchFilterState();

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  void updateCategory(String categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void updateLocation(String location) {
    state = state.copyWith(location: location);
  }

  void updatePriceRange(double min, double max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void toggleBhk(String bhk) {
    final current = List<String>.from(state.bhkList);
    if (current.contains(bhk)) {
      current.remove(bhk);
    } else {
      current.add(bhk);
    }
    state = state.copyWith(bhkList: current);
  }

  void updateFurnishing(String furnishing) {
    state = state.copyWith(furnishing: furnishing);
  }

  void toggleVerifiedOnly(bool value) {
    state = state.copyWith(verifiedOnly: value);
  }

  void updateSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void resetFilters() {
    state = SearchFilterState(query: state.query);
  }
}

final searchFilterProvider = NotifierProvider<SearchFilterNotifier, SearchFilterState>(
  SearchFilterNotifier.new,
);

// 7. Search Results Provider
final searchResultsProvider = Provider<List<Property>>((ref) {
  final repo = ref.watch(propertyRepositoryProvider);
  final filter = ref.watch(searchFilterProvider);

  // Trigger rebuild when master properties list changes
  ref.watch(propertiesProvider);

  return repo.searchAndFilter(
    query: filter.query,
    categoryId: filter.categoryId,
    location: filter.location,
    minPrice: filter.minPrice,
    maxPrice: filter.maxPrice,
    bhkList: filter.bhkList,
    furnishing: filter.furnishing,
    verifiedOnly: filter.verifiedOnly,
    sortBy: filter.sortBy,
  );
});

// 8. Conversations Notifier
class ConversationsNotifier extends Notifier<List<ChatConversation>> {
  late final LocalStorageService _storage;
  late final ChatRepository _chatRepo;

  @override
  List<ChatConversation> build() {
    _storage = ref.watch(localStorageServiceProvider);
    _chatRepo = ref.watch(chatRepositoryProvider);
    return _storage.getConversations();
  }

  void refresh() {
    state = _storage.getConversations();
  }

  Future<void> sendMessage(String conversationId, String text) async {
    await _chatRepo.sendMessage(
      conversationId: conversationId,
      text: text,
      onAgentReplied: (agentMsg) {
        state = _storage.getConversations();
        ref.read(notificationsProvider.notifier).refresh();
      },
    );
    state = _storage.getConversations();
  }

  Future<void> startConversation(Property property) async {
    await _chatRepo.startConversationForProperty(property);
    state = _storage.getConversations();
  }

  Future<void> syncRemoteConversations() async {
    final user = _storage.getUserProfile();
    if (user.phone.isNotEmpty) {
      await _chatRepo.syncAllUserConversations(user.phone);
      state = _storage.getConversations();
    }
  }

  Future<void> syncAdminAllConversations() async {
    await _chatRepo.syncAdminAllConversations();
    state = _storage.getConversations();
  }
}

final conversationsProvider = NotifierProvider<ConversationsNotifier, List<ChatConversation>>(
  ConversationsNotifier.new,
);

// 9. Notifications Notifier
class NotificationsNotifier extends Notifier<List<NotificationItem>> {
  late final LocalStorageService _storage;

  @override
  List<NotificationItem> build() {
    _storage = ref.watch(localStorageServiceProvider);
    return _storage.getNotifications();
  }

  void refresh() {
    state = _storage.getNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _storage.markNotificationAsRead(id);
    state = _storage.getNotifications();
  }

  Future<void> markAllAsRead() async {
    await _storage.markAllNotificationsRead();
    state = _storage.getNotifications();
  }

  Future<void> addNotification(NotificationItem item) async {
    await _storage.addNotification(item);
    state = _storage.getNotifications();
  }
}

final notificationsProvider = NotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  NotificationsNotifier.new,
);

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationsProvider);
  return list.where((n) => !n.isRead).length;
});

// 10. User Profile Notifier
class UserProfileNotifier extends Notifier<UserProfile> {
  late final LocalStorageService _storage;

  @override
  UserProfile build() {
    _storage = ref.watch(localStorageServiceProvider);
    return _storage.getUserProfile();
  }

  Future<void> updateProfile(UserProfile profile) async {
    state = profile;
    await _storage.saveUserProfile(profile);
  }

  Future<void> logout() async {
    RealtimeService().stopListening();
    ref.read(userRequestsProvider.notifier).clear();
    await _storage.clearUserSessionData();
    state = SeedData.initialProfile;
    ref.read(propertiesProvider.notifier).refresh();
    ref.read(notificationsProvider.notifier).refresh();
    ref.read(conversationsProvider.notifier).refresh();
    await ref.read(propertiesProvider.notifier).syncWithServer();
  }
}

final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfile>(
  UserProfileNotifier.new,
);

// 11. Buyer Requirements (மக்களின் தேவை) Notifier
class BuyerRequirementsNotifier extends Notifier<List<BuyerRequirement>> {
  late final LocalStorageService _storage;
  final PropertyApiService _apiService = PropertyApiService();

  @override
  List<BuyerRequirement> build() {
    _storage = ref.watch(localStorageServiceProvider);
    Future.microtask(() => syncWithServer());
    return _storage.getBuyerRequirements();
  }

  Future<void> syncWithServer() async {
    try {
      final rawList = await _apiService.fetchBuyerRequirements();
      if (rawList.isNotEmpty) {
        final reqs = rawList.map((m) => BuyerRequirement.fromMap(m)).toList();
        await _storage.saveBuyerRequirements(reqs);
        state = reqs;
      }
    } catch (_) {}
  }

  void refresh() {
    syncWithServer();
    state = _storage.getBuyerRequirements();
  }

  Future<void> addRequirement(BuyerRequirement req) async {
    await _storage.addBuyerRequirement(req);
    state = _storage.getBuyerRequirements();
    try {
      await _apiService.createBuyerRequirement(req.toMap());
    } catch (_) {}
  }
}

final buyerRequirementsProvider =
    NotifierProvider<BuyerRequirementsNotifier, List<BuyerRequirement>>(
  BuyerRequirementsNotifier.new,
);

// 12. User Requests (Real-Time Contact & Approval)
class UserRequestsState {
  final List<UserRequest> sent;
  final List<UserRequest> received;
  final bool isLoading;

  const UserRequestsState({
    this.sent = const [],
    this.received = const [],
    this.isLoading = false,
  });

  UserRequestsState copyWith({
    List<UserRequest>? sent,
    List<UserRequest>? received,
    bool? isLoading,
  }) {
    return UserRequestsState(
      sent: sent ?? this.sent,
      received: received ?? this.received,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class UserRequestsNotifier extends Notifier<UserRequestsState> {
  bool _listenerAttached = false;

  @override
  UserRequestsState build() {
    final user = ref.watch(userProfileProvider);
    if (user.isLoggedIn && user.phone.isNotEmpty) {
      final cleanPhone = user.phone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanPhone.isNotEmpty) {
        RealtimeService().startListening(cleanPhone);
        if (!_listenerAttached) {
          _listenerAttached = true;
          RealtimeService().addListener(_handleRealtimeEvent);
        }
        Future.microtask(() => fetchRequests());
      }
    }
    return const UserRequestsState();
  }

  void _handleRealtimeEvent(String eventType, Map<String, dynamic> payload) {
    if (eventType == 'new_request') {
      try {
        final req = UserRequest.fromMap(payload);
        final currentReceived = List<UserRequest>.from(state.received);
        currentReceived.removeWhere((r) => r.id == req.id);
        currentReceived.insert(0, req);
        state = state.copyWith(received: currentReceived);

        // Also add local notification
        ref.read(notificationsProvider.notifier).addNotification(
          NotificationItem(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
            title: 'புதிய தொடர்பு கோரிக்கை: ${req.senderName}',
            message: '${req.senderName} (${req.senderPhone}) உங்கள் \'${req.propertyTitle ?? "விளம்பரம்"}\' விளம்பரத்திற்கு கோரிக்கை விடுத்துள்ளார்.',
            timestamp: DateTime.now(),
            type: 'enquiry',
            propertyId: req.propertyId,
          ),
        );
      } catch (e) {
        debugPrint('Error parsing new_request: $e');
      }
    } else if (eventType == 'request_status_updated') {
      try {
        final reqId = payload['id'] ?? '';
        final status = (payload['status'] ?? 'pending').toString().toLowerCase();
        final currentSent = List<UserRequest>.from(state.sent);
        final index = currentSent.indexWhere((r) => r.id == reqId);
        if (index != -1) {
          currentSent[index] = currentSent[index].copyWith(status: status);
          state = state.copyWith(sent: currentSent);
        }

        final receiverName = payload['receiverName'] ?? 'விற்பனையாளர்';
        final isAcc = status == 'accepted';
        ref.read(notificationsProvider.notifier).addNotification(
          NotificationItem(
            id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
            title: isAcc ? 'கோரிக்கை ஏற்கப்பட்டது! ✓' : 'கோரிக்கை நிராகரிக்கப்பட்டது',
            message: isAcc
                ? '$receiverName உங்கள் கோரிக்கையை ஏற்றுக்கொண்டுள்ளார். தொடர்பு கொள்ளலாம்!'
                : '$receiverName உங்கள் கோரிக்கையை நிராகரித்துள்ளார்.',
            timestamp: DateTime.now(),
            type: isAcc ? 'ad_approved' : 'system',
            propertyId: payload['propertyId'],
          ),
        );
      } catch (e) {
        debugPrint('Error parsing request_status_updated: $e');
      }
    }
  }

  Future<void> fetchRequests() async {
    final user = ref.read(userProfileProvider);
    final cleanPhone = user.phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.isEmpty) return;

    state = state.copyWith(isLoading: true);
    final baseUrl = ApiConfig.instance.serverUrl;
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/requests.php?user_phone=${Uri.encodeComponent(cleanPhone)}'))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          final sentList = (data['sent'] as List? ?? [])
              .map((e) => UserRequest.fromMap(e as Map<String, dynamic>))
              .toList();
          final receivedList = (data['received'] as List? ?? [])
              .map((e) => UserRequest.fromMap(e as Map<String, dynamic>))
              .toList();
          state = UserRequestsState(sent: sentList, received: receivedList, isLoading: false);
          return;
        }
      }
    } catch (e) {
      debugPrint('fetchRequests error: $e');
    }
    state = state.copyWith(isLoading: false);
  }

  Future<bool> sendRequest({
    required String receiverPhone,
    required String receiverName,
    String? propertyId,
    String? propertyTitle,
    String? message,
  }) async {
    final user = ref.read(userProfileProvider);
    final cleanSenderPhone = user.phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanSenderPhone.isEmpty) return false;

    final baseUrl = ApiConfig.instance.serverUrl;
    try {
      final body = jsonEncode({
        'action': 'send',
        'senderPhone': cleanSenderPhone,
        'senderName': user.name.isNotEmpty ? user.name : 'பயனர்',
        'receiverPhone': receiverPhone.replaceAll(RegExp(r'[^0-9]'), ''),
        'receiverName': receiverName,
        'propertyId': propertyId,
        'propertyTitle': propertyTitle,
        'message': message ?? 'வணக்கம், உங்கள் விளம்பரம் தொடர்பாக தொடர்பு கொள்ள விரும்புகிறேன்.',
      });

      final res = await http.post(
        Uri.parse('$baseUrl/requests.php?action=send'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['request'] != null) {
          final newReq = UserRequest.fromMap(data['request']);
          final currentSent = List<UserRequest>.from(state.sent);
          currentSent.removeWhere((r) => r.id == newReq.id);
          currentSent.insert(0, newReq);
          state = state.copyWith(sent: currentSent);
          return true;
        }
      }
    } catch (e) {
      debugPrint('sendRequest error: $e');
    }
    return false;
  }

  Future<bool> acceptRequest(String requestId) async {
    // Optimistic UI update immediately
    final currentReceived = List<UserRequest>.from(state.received);
    final idx = currentReceived.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      currentReceived[idx] = currentReceived[idx].copyWith(status: 'accepted');
      state = state.copyWith(received: currentReceived);
    }

    final baseUrl = ApiConfig.instance.serverUrl;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/requests.php?action=accept'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'accept', 'requestId': requestId}),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('acceptRequest error: $e');
    }
    return false;
  }

  Future<bool> rejectRequest(String requestId) async {
    // Optimistic UI update immediately
    final currentReceived = List<UserRequest>.from(state.received);
    final idx = currentReceived.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      currentReceived[idx] = currentReceived[idx].copyWith(status: 'rejected');
      state = state.copyWith(received: currentReceived);
    }

    final baseUrl = ApiConfig.instance.serverUrl;
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/requests.php?action=reject'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'reject', 'requestId': requestId}),
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint('rejectRequest error: $e');
    }
    return false;
  }

  void clear() {
    state = const UserRequestsState();
  }
}

final userRequestsProvider = NotifierProvider<UserRequestsNotifier, UserRequestsState>(
  UserRequestsNotifier.new,
);

