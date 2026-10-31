class UserRequest {
  final String id;
  final String senderPhone;
  final String senderName;
  final String receiverPhone;
  final String receiverName;
  final String? propertyId;
  final String? propertyTitle;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? message;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserRequest({
    required this.id,
    required this.senderPhone,
    required this.senderName,
    required this.receiverPhone,
    required this.receiverName,
    this.propertyId,
    this.propertyTitle,
    this.status = 'pending',
    this.message,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isAccepted => status.toLowerCase() == 'accepted';
  bool get isRejected => status.toLowerCase() == 'rejected';

  UserRequest copyWith({
    String? id,
    String? senderPhone,
    String? senderName,
    String? receiverPhone,
    String? receiverName,
    String? propertyId,
    String? propertyTitle,
    String? status,
    String? message,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserRequest(
      id: id ?? this.id,
      senderPhone: senderPhone ?? this.senderPhone,
      senderName: senderName ?? this.senderName,
      receiverPhone: receiverPhone ?? this.receiverPhone,
      receiverName: receiverName ?? this.receiverName,
      propertyId: propertyId ?? this.propertyId,
      propertyTitle: propertyTitle ?? this.propertyTitle,
      status: status ?? this.status,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderPhone': senderPhone,
      'senderName': senderName,
      'receiverPhone': receiverPhone,
      'receiverName': receiverName,
      'propertyId': propertyId,
      'propertyTitle': propertyTitle,
      'status': status,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserRequest.fromMap(Map<String, dynamic> map) {
    return UserRequest(
      id: map['id'] ?? '',
      senderPhone: map['senderPhone'] ?? map['sender_phone'] ?? '',
      senderName: map['senderName'] ?? map['sender_name'] ?? '',
      receiverPhone: map['receiverPhone'] ?? map['receiver_phone'] ?? '',
      receiverName: map['receiverName'] ?? map['receiver_name'] ?? '',
      propertyId: map['propertyId'] ?? map['property_id'],
      propertyTitle: map['propertyTitle'] ?? map['property_title'],
      status: (map['status'] ?? 'pending').toString().toLowerCase(),
      message: map['message'],
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
          : (map['created_at'] != null ? DateTime.tryParse(map['created_at']) ?? DateTime.now() : DateTime.now()),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : (map['updated_at'] != null ? DateTime.tryParse(map['updated_at']) : null),
    );
  }
}
