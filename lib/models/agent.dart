class Agent {
  final String id;
  final String name;
  final String agencyName;
  final String phone;
  final String email;
  final String avatarKey;
  final double rating;
  final int reviewsCount;
  final int experienceYears;
  final int totalListings;
  final bool isVerified;
  final String about;

  const Agent({
    required this.id,
    required this.name,
    required this.agencyName,
    required this.phone,
    required this.email,
    required this.avatarKey,
    required this.rating,
    required this.reviewsCount,
    required this.experienceYears,
    required this.totalListings,
    required this.isVerified,
    required this.about,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'agencyName': agencyName,
      'phone': phone,
      'email': email,
      'avatarKey': avatarKey,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'experienceYears': experienceYears,
      'totalListings': totalListings,
      'isVerified': isVerified,
      'about': about,
    };
  }

  factory Agent.fromMap(Map<String, dynamic> map) {
    return Agent(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      agencyName: map['agencyName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      avatarKey: map['avatarKey'] ?? 'agent_1',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: map['reviewsCount'] ?? 0,
      experienceYears: map['experienceYears'] ?? 5,
      totalListings: map['totalListings'] ?? 10,
      isVerified: map['isVerified'] ?? true,
      about: map['about'] ?? 'Experienced real estate advisor specializing in residential and commercial properties in Tamil Nadu.',
    );
  }
}
