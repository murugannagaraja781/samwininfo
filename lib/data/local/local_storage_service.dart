import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/buyer_requirement.dart';
import '../../models/chat_message.dart';
import '../../models/notification_item.dart';
import '../../models/property.dart';
import '../../models/user_profile.dart';
import 'seed_data.dart';

class LocalStorageService {
  static const String _keyProperties = 'tenkasidreams_properties_v2';
  static const String _keyFavorites = 'tenkasidreams_favorites_v2';
  static const String _keyConversations = 'tenkasidreams_conversations_v2';
  static const String _keyNotifications = 'tenkasidreams_notifications_v2';
  static const String _keyRecentSearches = 'tenkasidreams_recent_searches_v2';
  static const String _keySavedSearches = 'tenkasidreams_saved_searches_v2';
  static const String _keyUserProfile = 'tenkasidreams_user_profile_v2';
  static const String _keyCurrentLocation = 'tenkasidreams_current_location_v2';
  static const String _keyBuyerRequirements = 'tenkasidreams_buyer_requirements_v2';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  static Future<LocalStorageService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final service = LocalStorageService(prefs);
    await service._ensureInitialized();
    return service;
  }

  Future<void> _ensureInitialized() async {
    // Check if properties exist; if not, initialize empty
    if (!_prefs.containsKey(_keyProperties)) {
      await saveProperties([]);
    }
    // Check conversations
    if (!_prefs.containsKey(_keyConversations)) {
      await saveConversations([]);
    }
    // Check notifications
    if (!_prefs.containsKey(_keyNotifications)) {
      await saveNotifications([]);
    }
    // Check recent searches
    if (!_prefs.containsKey(_keyRecentSearches)) {
      await _prefs.setStringList(_keyRecentSearches, []);
    }
    // Check user profile
    if (!_prefs.containsKey(_keyUserProfile)) {
      await saveUserProfile(SeedData.initialProfile);
    }
    // Check current location
    if (!_prefs.containsKey(_keyCurrentLocation)) {
      await _prefs.setString(_keyCurrentLocation, 'Tenkasi, Tamil Nadu');
    }
    // Check buyer requirements (மக்களின் தேவை)
    if (!_prefs.containsKey(_keyBuyerRequirements)) {
      await saveBuyerRequirements([]);
    }
  }

  // ==========================================
  // PROPERTIES CRUD & PERSISTENCE
  // ==========================================

  List<Property> getProperties() {
    final raw = _prefs.getString(_keyProperties);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((item) => Property.fromMap(item as Map<String, dynamic>))
          .where((p) => !p.id.startsWith('seed_') && !p.id.startsWith('mock_'))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveProperties(List<Property> properties) async {
    final raw = jsonEncode(properties.map((p) => p.toMap()).toList());
    await _prefs.setString(_keyProperties, raw);
  }

  Future<void> addProperty(Property property) async {
    final list = getProperties();
    list.insert(0, property);
    await saveProperties(list);
  }

  Future<void> updateProperty(Property property) async {
    final list = getProperties();
    final index = list.indexWhere((p) => p.id == property.id);
    if (index != -1) {
      list[index] = property;
      await saveProperties(list);
    }
  }

  Future<void> deleteProperty(String id) async {
    final list = getProperties();
    list.removeWhere((p) => p.id == id);
    await saveProperties(list);
  }

  // ==========================================
  // FAVORITES
  // ==========================================

  List<String> getFavoriteIds() {
    return _prefs.getStringList(_keyFavorites) ?? [];
  }

  Future<void> toggleFavorite(String propertyId) async {
    final favorites = getFavoriteIds();
    if (favorites.contains(propertyId)) {
      favorites.remove(propertyId);
    } else {
      favorites.add(propertyId);
    }
    await _prefs.setStringList(_keyFavorites, favorites);

    // Also update property isFavorite flag in properties list
    final props = getProperties();
    final index = props.indexWhere((p) => p.id == propertyId);
    if (index != -1) {
      props[index] = props[index].copyWith(isFavorite: favorites.contains(propertyId));
      await saveProperties(props);
    }
  }

  // ==========================================
  // CHATS
  // ==========================================

  List<ChatConversation> getConversations() {
    final raw = _prefs.getString(_keyConversations);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => ChatConversation.fromMap(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveConversations(List<ChatConversation> convs) async {
    final raw = jsonEncode(convs.map((c) => c.toMap()).toList());
    await _prefs.setString(_keyConversations, raw);
  }

  Future<void> addMessageToConversation(String conversationId, ChatMessage message) async {
    final convs = getConversations();
    final index = convs.indexWhere((c) => c.id == conversationId);
    if (index != -1) {
      final old = convs[index];
      final updatedMsgs = List<ChatMessage>.from(old.messages)..add(message);
      convs[index] = old.copyWith(
        messages: updatedMsgs,
        lastMessage: message.text,
        lastMessageTime: message.timestamp,
        unreadCount: message.isFromUser ? old.unreadCount : old.unreadCount + 1,
      );
      await saveConversations(convs);
    }
  }

  Future<void> createOrGetConversation(Property property) async {
    final convs = getConversations();
    final existingIndex = convs.indexWhere((c) => c.property.id == property.id);
    if (existingIndex == -1) {
      final newConv = ChatConversation(
        id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
        agent: property.agent,
        property: ChatPropertySummary(
          id: property.id,
          title: property.title,
          price: property.price,
          location: property.location,
          propertyType: property.propertyType,
          areaSqFt: property.areaSqFt,
          imageUrl: property.primaryImageUrl,
          customImageBase64: property.customImageBase64,
        ),
        lastMessage: 'Enquired about ${property.title}',
        lastMessageTime: DateTime.now(),
        unreadCount: 0,
        messages: [
          ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            conversationId: 'conv_${DateTime.now().millisecondsSinceEpoch}',
            text: 'Hello! I am interested in "${property.title}" listed for ${property.location}. Please share further details.',
            isFromUser: true,
            timestamp: DateTime.now(),
          ),
        ],
      );
      convs.insert(0, newConv);
      await saveConversations(convs);
    }
  }

  // ==========================================
  // NOTIFICATIONS
  // ==========================================

  List<NotificationItem> getNotifications() {
    final raw = _prefs.getString(_keyNotifications);
    if (raw == null || raw.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(raw);
      return list.map((item) => NotificationItem.fromMap(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotifications(List<NotificationItem> items) async {
    final raw = jsonEncode(items.map((n) => n.toMap()).toList());
    await _prefs.setString(_keyNotifications, raw);
  }

  Future<void> markNotificationAsRead(String id) async {
    final notifs = getNotifications();
    final idx = notifs.indexWhere((n) => n.id == id);
    if (idx != -1) {
      notifs[idx] = notifs[idx].copyWith(isRead: true);
      await saveNotifications(notifs);
    }
  }

  Future<void> markAllNotificationsRead() async {
    final notifs = getNotifications();
    final updated = notifs.map((n) => n.copyWith(isRead: true)).toList();
    await saveNotifications(updated);
  }

  Future<void> addNotification(NotificationItem item) async {
    final notifs = getNotifications();
    notifs.removeWhere((n) => n.id == item.id);
    notifs.insert(0, item);
    if (notifs.length > 100) notifs.removeRange(100, notifs.length);
    await saveNotifications(notifs);
  }

  // ==========================================
  // RECENT & SAVED SEARCHES
  // ==========================================

  List<String> getRecentSearches() {
    return _prefs.getStringList(_keyRecentSearches) ?? [];
  }

  Future<void> addRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final list = getRecentSearches();
    list.removeWhere((q) => q.toLowerCase() == query.trim().toLowerCase());
    list.insert(0, query.trim());
    if (list.length > 10) list.removeLast();
    await _prefs.setStringList(_keyRecentSearches, list);
  }

  Future<void> clearRecentSearches() async {
    await _prefs.setStringList(_keyRecentSearches, []);
  }

  List<String> getSavedSearches() {
    return _prefs.getStringList(_keySavedSearches) ?? [];
  }

  Future<void> addSavedSearch(String query) async {
    final list = getSavedSearches();
    if (!list.contains(query)) {
      list.insert(0, query);
      await _prefs.setStringList(_keySavedSearches, list);
    }
  }

  Future<void> removeSavedSearch(String query) async {
    final list = getSavedSearches();
    list.remove(query);
    await _prefs.setStringList(_keySavedSearches, list);
  }

  // ==========================================
  // USER PROFILE & LOCATION
  // ==========================================

  UserProfile getUserProfile() {
    final raw = _prefs.getString(_keyUserProfile);
    if (raw == null) return SeedData.initialProfile;
    try {
      final p = UserProfile.fromMap(jsonDecode(raw));
      // Reset stale mock profile if not explicitly logged in
      if (!p.isLoggedIn && (p.email == 'tenkasidreams@gmail.com' || p.phone.contains('98941 74944'))) {
        return SeedData.initialProfile;
      }
      return p;
    } catch (_) {
      return SeedData.initialProfile;
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    await _prefs.setString(_keyUserProfile, jsonEncode(profile.toMap()));
  }

  String getCurrentLocation() {
    return _prefs.getString(_keyCurrentLocation) ?? 'Tenkasi, Tamil Nadu';
  }

  Future<void> setCurrentLocation(String location) async {
    await _prefs.setString(_keyCurrentLocation, location);
  }

  String getLocale() {
    return _prefs.getString('tenkasi_locale_v2') ?? 'ta';
  }

  Future<void> saveLocale(String locale) async {
    await _prefs.setString('tenkasi_locale_v2', locale);
  }

  // ==========================================
  // UNLOCKED PROPERTIES & FREE CONTACTS
  // ==========================================

  static const String _keyUnlockedProperties = 'tenkasi_unlocked_properties_v1';
  static const String _keyFreeContactsUsed = 'tenkasi_free_contacts_used_v1';

  List<String> getUnlockedPropertyIds() {
    return _prefs.getStringList(_keyUnlockedProperties) ?? [];
  }

  Future<void> addUnlockedProperty(String propId) async {
    final list = getUnlockedPropertyIds();
    if (!list.contains(propId)) {
      list.add(propId);
      await _prefs.setStringList(_keyUnlockedProperties, list);
    }
  }

  Future<void> setUnlockedPropertyIds(List<String> ids) async {
    await _prefs.setStringList(_keyUnlockedProperties, ids);
  }

  int getFreeContactsUsed() {
    return _prefs.getInt(_keyFreeContactsUsed) ?? 0;
  }

  Future<void> setFreeContactsUsed(int count) async {
    await _prefs.setInt(_keyFreeContactsUsed, count);
  }

  Future<void> incrementFreeContactsUsed() async {
    final count = getFreeContactsUsed() + 1;
    await _prefs.setInt(_keyFreeContactsUsed, count);
  }


  // ==========================================
  // BUYER REQUIREMENTS (மக்களின் தேவை)
  // ==========================================

  List<BuyerRequirement> getBuyerRequirements() {
    final raw = _prefs.getString(_keyBuyerRequirements);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((item) => BuyerRequirement.fromMap(item)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBuyerRequirements(List<BuyerRequirement> reqs) async {
    final encoded = jsonEncode(reqs.map((r) => r.toMap()).toList());
    await _prefs.setString(_keyBuyerRequirements, encoded);
  }

  Future<void> addBuyerRequirement(BuyerRequirement req) async {
    final current = getBuyerRequirements();
    final updated = [req, ...current];
    await saveBuyerRequirements(updated);
  }

  // ==========================================
  // RESET DEMO DATA
  // ==========================================

  Future<void> resetDemoData() async {
    await saveProperties([]);
    await _prefs.setStringList(_keyFavorites, []);
    await saveConversations([]);
    await saveNotifications([]);
    await _prefs.setStringList(_keyRecentSearches, []);
    await saveUserProfile(SeedData.initialProfile);
    await _prefs.setString(_keyCurrentLocation, 'Tenkasi, Tamil Nadu');
  }

  /// Cleans session-specific data on logout while strictly preserving persistent contact counts
  Future<void> clearUserSessionData() async {
    // 1. Reset user profile to default guest
    await saveUserProfile(SeedData.initialProfile);
    // 2. Note: Do NOT remove _keyFreeContactsUsed or _keyUnlockedProperties
    // so logout/login cannot reset the 3-ad free view limit.
    // 3. Clear favorites
    await _prefs.setStringList(_keyFavorites, []);
    // 4. Clear conversations
    await saveConversations([]);
    // 5. Clear notifications
    await saveNotifications([]);
    // 6. Clear recent searches
    await _prefs.setStringList(_keyRecentSearches, []);
    // 7. Remove any cached user-posted properties
    final props = getProperties().where((p) => !p.isUserPosted).toList();
    await saveProperties(props);
  }
}
