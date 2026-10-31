import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';
import '../local/local_storage_service.dart';
import '../../models/agent.dart';
import '../../models/chat_message.dart';
import '../../models/property.dart';

class ChatRepository {
  final LocalStorageService _storage;

  ChatRepository(this._storage);

  List<ChatConversation> getConversations() {
    return _storage.getConversations();
  }

  ChatConversation? getConversationById(String id) {
    try {
      return getConversations().firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> syncRemoteMessages(String conversationId) async {
    try {
      final url = '${ApiConfig.instance.serverUrl}/chat.php?action=messages&conversation_id=$conversationId';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['messages'] is List) {
          final user = _storage.getUserProfile();
          final conv = getConversationById(conversationId);
          if (conv != null) {
            for (final m in data['messages']) {
              final sPhone = m['sender_phone'] ?? '';
              final isMe = sPhone == user.phone;
              final msgId = m['id'] ?? 'msg_${DateTime.now().millisecondsSinceEpoch}';
              final exists = conv.messages.any((existing) => existing.id == msgId);
              if (!exists) {
                final newMsg = ChatMessage(
                  id: msgId,
                  conversationId: conversationId,
                  text: m['message'] ?? '',
                  isFromUser: isMe,
                  timestamp: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
                );
                await _storage.addMessageToConversation(conversationId, newMsg);
              }
            }
          }
        }
      }
    } catch (_) {}
  }

  Future<void> syncAllUserConversations(String userPhone, {String? userEmail}) async {
    final cleanP = userPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final cleanEmail = (userEmail ?? '').trim().toLowerCase();
    if (cleanP.isEmpty && cleanEmail.isEmpty) return;

    try {
      final url = '${ApiConfig.instance.serverUrl}/chat.php?action=conversations&user_phone=$cleanP&user_email=${Uri.encodeComponent(cleanEmail)}';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['conversations'] is List) {
          final convList = data['conversations'] as List;
          final localConvs = _storage.getConversations();

          for (final c in convList) {
            final convId = c['id'] ?? '';
            if (convId.isEmpty) continue;

            final sPhone = (c['seller_phone'] ?? '').toString().replaceAll(RegExp(r'[^0-9]'), '');
            final sEmail = (c['seller_email'] ?? '').toString().trim().toLowerCase();
            final isSeller = (cleanP.isNotEmpty && cleanP == sPhone) || (cleanEmail.isNotEmpty && cleanEmail == sEmail);

            final counterpartName = isSeller ? (c['buyer_name'] ?? 'Buyer') : (c['seller_name'] ?? 'Direct Owner');
            final counterpartPhone = isSeller ? (c['buyer_phone'] ?? '') : (c['seller_phone'] ?? '');

            final existingIndex = localConvs.indexWhere((lc) => lc.id == convId);

            if (existingIndex == -1) {
              final newConv = ChatConversation(
                id: convId,
                agent: Agent(
                  id: 'agent_$convId',
                  name: counterpartName,
                  agencyName: isSeller ? 'வாங்குபவர் (Buyer)' : 'சொத்து உரிமையாளர் (Owner)',
                  phone: counterpartPhone,
                  email: '',
                  avatarKey: 'agent_1',
                  rating: 5.0,
                  reviewsCount: 1,
                  experienceYears: 2,
                  totalListings: 1,
                  isVerified: true,
                  about: '',
                ),
                property: ChatPropertySummary(
                  id: c['property_id'] ?? '',
                  title: c['property_title'] ?? 'Property',
                  price: 0,
                  location: 'Tenkasi',
                  propertyType: 'Property',
                  areaSqFt: 0,
                ),
                lastMessage: c['last_message'] ?? '',
                lastMessageTime: DateTime.tryParse(c['last_message_time'] ?? '') ?? DateTime.now(),
                unreadCount: 0,
                messages: const [],
              );
              localConvs.insert(0, newConv);
              await _storage.saveConversations(localConvs);
            }
            await syncRemoteMessages(convId);
          }
        }
      }
    } catch (_) {}
  }

  Future<void> syncAdminAllConversations() async {
    try {
      final url = '${ApiConfig.instance.serverUrl}/chat.php?action=admin_all';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 6));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['conversations'] is List) {
          final convList = data['conversations'] as List;
          final localConvs = _storage.getConversations();

          for (final c in convList) {
            final convId = c['id'] ?? '';
            if (convId.isEmpty) continue;

            final buyerName = c['buyer_name'] ?? 'Buyer';
            final buyerPhone = c['buyer_phone'] ?? '';
            final sellerName = c['seller_name'] ?? 'Seller';
            final sellerPhone = c['seller_phone'] ?? '';

            final existingIndex = localConvs.indexWhere((lc) => lc.id == convId);

            if (existingIndex == -1) {
              final newConv = ChatConversation(
                id: convId,
                agent: Agent(
                  id: 'agent_$convId',
                  name: '$buyerName ⇄ $sellerName',
                  agencyName: 'Buyer: $buyerPhone | Seller: $sellerPhone',
                  phone: sellerPhone.isNotEmpty ? sellerPhone : buyerPhone,
                  email: '',
                  avatarKey: 'agent_1',
                  rating: 5.0,
                  reviewsCount: 1,
                  experienceYears: 2,
                  totalListings: 1,
                  isVerified: true,
                  about: '',
                ),
                property: ChatPropertySummary(
                  id: c['property_id'] ?? '',
                  title: c['property_title'] ?? 'Property',
                  price: 0,
                  location: 'Tenkasi',
                  propertyType: 'Property',
                  areaSqFt: 0,
                ),
                lastMessage: c['last_message'] ?? '',
                lastMessageTime: DateTime.tryParse(c['last_message_time'] ?? '') ?? DateTime.now(),
                unreadCount: 0,
                messages: const [],
              );
              localConvs.insert(0, newConv);
              await _storage.saveConversations(localConvs);
            }
            await syncRemoteMessages(convId);
          }
        }
      }
    } catch (e) {
      debugPrint('Admin sync conversations error: $e');
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String text,
    required Function(ChatMessage) onAgentReplied,
  }) async {
    final userMsg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      text: text,
      isFromUser: true,
      timestamp: DateTime.now(),
    );

    // 1. Persist user message locally
    await _storage.addMessageToConversation(conversationId, userMsg);

    final conv = getConversationById(conversationId);
    final user = _storage.getUserProfile();
    final cleanUserP = user.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final cleanAgentP = (conv?.agent.phone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    final cleanUserEmail = user.email.trim().toLowerCase();
    final cleanAgentEmail = (conv?.agent.email ?? '').trim().toLowerCase();
    final isSeller = (cleanUserP.isNotEmpty && cleanUserP == cleanAgentP) ||
                     (cleanUserEmail.isNotEmpty && cleanUserEmail == cleanAgentEmail);

    final userIdentifier = cleanUserP.isNotEmpty ? user.phone : (user.email.isNotEmpty ? user.email : 'Customer');

    // 2. Send to live server chat.php
    try {
      final url = '${ApiConfig.instance.serverUrl}/chat.php';
      await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'send',
          'conversation_id': conversationId,
          'property_id': conv?.property.id ?? '',
          'property_title': conv?.property.title ?? '',
          'buyer_name': isSeller ? (conv?.agent.name ?? 'Customer') : (user.name.isNotEmpty ? user.name : 'Customer'),
          'buyer_phone': isSeller ? (conv?.agent.phone ?? '') : userIdentifier,
          'buyer_email': isSeller ? (conv?.agent.email ?? '') : user.email,
          'seller_name': isSeller ? (user.name.isNotEmpty ? user.name : 'Direct Owner') : (conv?.agent.name ?? 'Direct Owner'),
          'seller_phone': isSeller ? userIdentifier : (conv?.agent.phone ?? ''),
          'seller_email': isSeller ? user.email : (conv?.agent.email ?? ''),
          'sender_phone': userIdentifier,
          'sender_email': user.email,
          'sender_name': user.name.isNotEmpty ? user.name : (isSeller ? 'Owner' : 'Customer'),
          'sender_role': isSeller ? 'seller' : 'buyer',
          'message': text,
        }),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  Future<void> startConversationForProperty(Property property) async {
    await _storage.createOrGetConversation(property);
  }
}
