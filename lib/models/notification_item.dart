class NotificationItem {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'enquiry', 'price_drop', 'ad_approved', 'system'
  final String? propertyId;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.type,
    this.propertyId,
  });

  NotificationItem copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    String? type,
    String? propertyId,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      propertyId: propertyId ?? this.propertyId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
      'propertyId': propertyId,
    };
  }

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      type: map['type'] ?? 'general',
      propertyId: map['propertyId'],
    );
  }
}
