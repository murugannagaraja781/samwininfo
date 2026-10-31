class BuyerRequirement {
  final String id;
  final String userName;
  final String userPhone;
  final String propertyType; // Land, Farmland, House, Apartment, Shop, Rental
  final String targetLocation;
  final double? budgetMin;
  final double? budgetMax;
  final String? preferredSize; // '5 Cents', '10 குழி (Kuzhi)', '2 Acres', '2 BHK'
  final String? facingPreference;
  final String description;
  final DateTime postedDate;
  final String status; // active, fulfilled
  final bool isUserPosted;

  const BuyerRequirement({
    required this.id,
    required this.userName,
    required this.userPhone,
    required this.propertyType,
    required this.targetLocation,
    this.budgetMin,
    this.budgetMax,
    this.preferredSize,
    this.facingPreference,
    required this.description,
    required this.postedDate,
    this.status = 'active',
    this.isUserPosted = false,
  });

  BuyerRequirement copyWith({
    String? id,
    String? userName,
    String? userPhone,
    String? propertyType,
    String? targetLocation,
    double? budgetMin,
    double? budgetMax,
    String? preferredSize,
    String? facingPreference,
    String? description,
    DateTime? postedDate,
    String? status,
    bool? isUserPosted,
  }) {
    return BuyerRequirement(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      propertyType: propertyType ?? this.propertyType,
      targetLocation: targetLocation ?? this.targetLocation,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      preferredSize: preferredSize ?? this.preferredSize,
      facingPreference: facingPreference ?? this.facingPreference,
      description: description ?? this.description,
      postedDate: postedDate ?? this.postedDate,
      status: status ?? this.status,
      isUserPosted: isUserPosted ?? this.isUserPosted,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'userPhone': userPhone,
      'propertyType': propertyType,
      'targetLocation': targetLocation,
      'budgetMin': budgetMin,
      'budgetMax': budgetMax,
      'preferredSize': preferredSize,
      'facingPreference': facingPreference,
      'description': description,
      'postedDate': postedDate.toIso8601String(),
      'status': status,
      'isUserPosted': isUserPosted,
    };
  }

  factory BuyerRequirement.fromMap(Map<String, dynamic> map) {
    return BuyerRequirement(
      id: map['id'] ?? '',
      userName: map['userName'] ?? '',
      userPhone: map['userPhone'] ?? '',
      propertyType: map['propertyType'] ?? 'Land',
      targetLocation: map['targetLocation'] ?? 'Tenkasi',
      budgetMin: (map['budgetMin'] as num?)?.toDouble(),
      budgetMax: (map['budgetMax'] as num?)?.toDouble(),
      preferredSize: map['preferredSize'],
      facingPreference: map['facingPreference'],
      description: map['description'] ?? '',
      postedDate: map['postedDate'] != null
          ? DateTime.tryParse(map['postedDate']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'active',
      isUserPosted: map['isUserPosted'] ?? false,
    );
  }
}
