import 'agent.dart';

class ChatMessage {
  final String id;
  final String conversationId;
  final String text;
  final bool isFromUser;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.text,
    required this.isFromUser,
    required this.timestamp,
    this.isRead = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'conversationId': conversationId,
      'text': text,
      'isFromUser': isFromUser,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      conversationId: map['conversationId'] ?? '',
      text: map['text'] ?? '',
      isFromUser: map['isFromUser'] ?? false,
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] ?? true,
    );
  }
}

class ChatPropertySummary {
  final String id;
  final String title;
  final double price;
  final String location;
  final String propertyType;
  final int areaSqFt;
  final String? imageUrl;
  final String? customImageBase64;

  const ChatPropertySummary({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.propertyType,
    required this.areaSqFt,
    this.imageUrl,
    this.customImageBase64,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'location': location,
      'propertyType': propertyType,
      'areaSqFt': areaSqFt,
      'imageUrl': imageUrl,
      'customImageBase64': customImageBase64,
    };
  }

  factory ChatPropertySummary.fromMap(Map<String, dynamic> map) {
    return ChatPropertySummary(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
      propertyType: map['propertyType'] ?? 'Property',
      areaSqFt: map['areaSqFt'] ?? 0,
      imageUrl: map['imageUrl'],
      customImageBase64: map['customImageBase64'],
    );
  }
}

class ChatConversation {
  final String id;
  final Agent agent;
  final ChatPropertySummary property;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.agent,
    required this.property,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.messages = const [],
  });

  ChatConversation copyWith({
    String? id,
    Agent? agent,
    ChatPropertySummary? property,
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
    List<ChatMessage>? messages,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      agent: agent ?? this.agent,
      property: property ?? this.property,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'agent': agent.toMap(),
      'property': property.toMap(),
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'unreadCount': unreadCount,
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory ChatConversation.fromMap(Map<String, dynamic> map) {
    return ChatConversation(
      id: map['id'] ?? '',
      agent: Agent.fromMap(map['agent'] ?? {}),
      property: ChatPropertySummary.fromMap(map['property'] ?? {}),
      lastMessage: map['lastMessage'] ?? '',
      lastMessageTime: map['lastMessageTime'] != null
          ? DateTime.tryParse(map['lastMessageTime']) ?? DateTime.now()
          : DateTime.now(),
      unreadCount: map['unreadCount'] ?? 0,
      messages: (map['messages'] as List<dynamic>? ?? [])
          .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }
}
