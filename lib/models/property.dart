import 'agent.dart';

class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String city;
  final String propertyType; // Land, Farmland, House, Apartment, Rental, Commercial
  final int areaSqFt;
  final int? bedrooms;
  final int? bathrooms;
  final String furnishingStatus; // Fully Furnished, Semi-Furnished, Unfurnished, N/A
  final String facing; // East, West, North, South, North-East, Corner Plot, etc.
  final String floor; // e.g. '3rd of 5 floors' or 'Ground floor'
  final List<String> imageUrls;
  final String? imageUrl;
  final List<String> imageKeys;
  final List<String> amenities;
  final Agent agent;
  final DateTime postedDate;
  final String status; // active, pending, sold, draft
  final bool isFavorite;
  final int views;
  final int enquiries;
  final bool isVerified;
  final bool isFeatured;
  final bool isPremium;
  final bool isUserPosted; // True if listed by the user (appears in My Ads)
  final int? superBuiltUpSqFt;
  final int? carpetAreaSqFt;
  final double? maintenanceMonthly;
  final String? landmark;
  final double? latitude;
  final double? longitude;
  final String? customImageBase64;
  
  // Local TN Land & Plot Specifications
  final String? posterType; // 'Direct Owner', 'Agent', 'Promoter'
  final String? landUnit; // 'Cents', 'குழி (Kuzhi)', 'Acres', 'Sq.Ft', 'Grounds'
  final double? landUnitValue;
  final List<String> landFeatures; // ['போர்வெல்', 'EB மின் இணைப்பு', 'கம்பி வேலி', 'காம்பவுண்ட் சுவர்', 'கிணறு', 'தார் ரோடு', 'நஞ்சை', 'புஞ்சை']
  final String? approvalType; // 'DTCP Approved', 'RERA Approved', 'Panchayat Approved', 'Unapproved'
  final bool isBankLoanAvailable; // Finance: இருக்கு / இல்லை
  final bool isPriceNegotiable; // விலை: பேசலாம் / நிலையானது
  final String? contactPhone; // Mobile Number for Direct Call & WhatsApp
  final String? googleMapUrl; // Google Map link

  // Apartment & House Specifics
  final String? waterSource; // 'Bore Water', 'Govt Water', 'Both', 'None'
  final bool hasLift; // லிஃப்ட்: இருக்கு / இல்லை

  // Farmland / தோட்டம் Specifics
  final bool hasTrees; // மரங்கள்: ஆம் / இல்லை
  final String? treesDetails; // தென்னை, மா, தேக்கு etc.
  final bool hasIncome; // வருமானம் / மகசூல்: ஆம் / இல்லை
  final String? incomeDetails; // மாதாந்திர/வருடாந்திர வருமானம்

  // Rental & Lease / வாடகைக்கு Specifics
  final bool isLease; // வாடகை (Monthly Rent) vs லீஸ் (Lease)
  final String? rentalSubType; // வீடு, கடை, Complex, காலி இடம், தோட்டம் குத்தகை, Business, அலுவலகம்
  final double? advanceAmount; // முன்பணம் / அட்வான்ஸ் தொகை ₹

  // Shop / Office / Commercial Specifics (கடை / அலுவலகம்)
  final String? commercialAreaType; // 'Main Bazaar', 'Bus Stand / Junction', 'Highway', 'Village'
  final bool hasTable; // மேஜை / பர்னிச்சர்: ஆம் / இல்லை
  final bool hasFan; // ஃபேன் வசதி: ஆம் / இல்லை
  final bool hasWaterSupply; // தண்ணீர் வசதி: ஆம் / இல்லை
  final bool hasShutter; // ஷட்டர் / கண்ணாடி கதவு: ஆம் / இல்லை
  final String? powerPhase; // 'Single Phase', '3 Phase EB', 'Free Agri EB'

  const Property({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.location,
    required this.city,
    required this.propertyType,
    required this.areaSqFt,
    this.bedrooms,
    this.bathrooms,
    this.furnishingStatus = 'Unfurnished',
    this.facing = 'East',
    this.floor = 'Ground Floor',
    this.imageUrls = const [],
    this.imageUrl,
    this.imageKeys = const [],
    this.amenities = const [],
    required this.agent,
    required this.postedDate,
    this.status = 'active',
    this.isFavorite = false,
    this.views = 0,
    this.enquiries = 0,
    this.isVerified = true,
    this.isFeatured = false,
    this.isPremium = false,
    this.isUserPosted = false,
    this.superBuiltUpSqFt,
    this.carpetAreaSqFt,
    this.maintenanceMonthly,
    this.landmark,
    this.latitude,
    this.longitude,
    this.customImageBase64,
    this.posterType = 'Direct Owner',
    this.landUnit,
    this.landUnitValue,
    this.landFeatures = const [],
    this.approvalType,
    this.isBankLoanAvailable = false,
    this.isPriceNegotiable = true,
    this.contactPhone,
    this.googleMapUrl,
    this.waterSource,
    this.hasLift = false,
    this.hasTrees = false,
    this.treesDetails,
    this.hasIncome = false,
    this.incomeDetails,
    this.isLease = false,
    this.rentalSubType,
    this.advanceAmount,
    this.commercialAreaType,
    this.hasTable = false,
    this.hasFan = false,
    this.hasWaterSupply = false,
    this.hasShutter = false,
    this.powerPhase,
  });

  bool get isRental => propertyType.toLowerCase() == 'rental' || isLease;

  String? get primaryImageUrl {
    if (imageUrls.isNotEmpty && imageUrls.first.isNotEmpty) {
      return imageUrls.first;
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return imageUrl;
    }
    return null;
  }

  Property copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? location,
    String? city,
    String? propertyType,
    int? areaSqFt,
    int? bedrooms,
    int? bathrooms,
    String? furnishingStatus,
    String? facing,
    String? floor,
    List<String>? imageUrls,
    String? imageUrl,
    List<String>? imageKeys,
    List<String>? amenities,
    Agent? agent,
    DateTime? postedDate,
    String? status,
    bool? isFavorite,
    int? views,
    int? enquiries,
    bool? isVerified,
    bool? isFeatured,
    bool? isPremium,
    bool? isUserPosted,
    int? superBuiltUpSqFt,
    int? carpetAreaSqFt,
    double? maintenanceMonthly,
    String? landmark,
    double? latitude,
    double? longitude,
    String? customImageBase64,
    String? posterType,
    String? landUnit,
    double? landUnitValue,
    List<String>? landFeatures,
    String? approvalType,
    bool? isBankLoanAvailable,
    bool? isPriceNegotiable,
    String? contactPhone,
    String? googleMapUrl,
    String? waterSource,
    bool? hasLift,
    bool? hasTrees,
    String? treesDetails,
    bool? hasIncome,
    String? incomeDetails,
    bool? isLease,
    String? rentalSubType,
    double? advanceAmount,
    String? commercialAreaType,
    bool? hasTable,
    bool? hasFan,
    bool? hasWaterSupply,
    bool? hasShutter,
    String? powerPhase,
  }) {
    return Property(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      location: location ?? this.location,
      city: city ?? this.city,
      propertyType: propertyType ?? this.propertyType,
      areaSqFt: areaSqFt ?? this.areaSqFt,
      bedrooms: bedrooms ?? this.bedrooms,
      bathrooms: bathrooms ?? this.bathrooms,
      furnishingStatus: furnishingStatus ?? this.furnishingStatus,
      facing: facing ?? this.facing,
      floor: floor ?? this.floor,
      imageUrls: imageUrls ?? this.imageUrls,
      imageUrl: imageUrl ?? this.imageUrl,
      imageKeys: imageKeys ?? this.imageKeys,
      amenities: amenities ?? this.amenities,
      agent: agent ?? this.agent,
      postedDate: postedDate ?? this.postedDate,
      status: status ?? this.status,
      isFavorite: isFavorite ?? this.isFavorite,
      views: views ?? this.views,
      enquiries: enquiries ?? this.enquiries,
      isVerified: isVerified ?? this.isVerified,
      isFeatured: isFeatured ?? this.isFeatured,
      isPremium: isPremium ?? this.isPremium,
      isUserPosted: isUserPosted ?? this.isUserPosted,
      superBuiltUpSqFt: superBuiltUpSqFt ?? this.superBuiltUpSqFt,
      carpetAreaSqFt: carpetAreaSqFt ?? this.carpetAreaSqFt,
      maintenanceMonthly: maintenanceMonthly ?? this.maintenanceMonthly,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      customImageBase64: customImageBase64 ?? this.customImageBase64,
      posterType: posterType ?? this.posterType,
      landUnit: landUnit ?? this.landUnit,
      landUnitValue: landUnitValue ?? this.landUnitValue,
      landFeatures: landFeatures ?? this.landFeatures,
      approvalType: approvalType ?? this.approvalType,
      isBankLoanAvailable: isBankLoanAvailable ?? this.isBankLoanAvailable,
      isPriceNegotiable: isPriceNegotiable ?? this.isPriceNegotiable,
      contactPhone: contactPhone ?? this.contactPhone,
      googleMapUrl: googleMapUrl ?? this.googleMapUrl,
      waterSource: waterSource ?? this.waterSource,
      hasLift: hasLift ?? this.hasLift,
      hasTrees: hasTrees ?? this.hasTrees,
      treesDetails: treesDetails ?? this.treesDetails,
      hasIncome: hasIncome ?? this.hasIncome,
      incomeDetails: incomeDetails ?? this.incomeDetails,
      isLease: isLease ?? this.isLease,
      rentalSubType: rentalSubType ?? this.rentalSubType,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      commercialAreaType: commercialAreaType ?? this.commercialAreaType,
      hasTable: hasTable ?? this.hasTable,
      hasFan: hasFan ?? this.hasFan,
      hasWaterSupply: hasWaterSupply ?? this.hasWaterSupply,
      hasShutter: hasShutter ?? this.hasShutter,
      powerPhase: powerPhase ?? this.powerPhase,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'location': location,
      'city': city,
      'propertyType': propertyType,
      'areaSqFt': areaSqFt,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'furnishingStatus': furnishingStatus,
      'facing': facing,
      'floor': floor,
      'imageUrls': imageUrls,
      'imageUrl': imageUrl,
      'imageKeys': imageKeys,
      'amenities': amenities,
      'agent': agent.toMap(),
      'postedDate': postedDate.toIso8601String(),
      'status': status,
      'isFavorite': isFavorite,
      'views': views,
      'enquiries': enquiries,
      'isVerified': isVerified,
      'isFeatured': isFeatured,
      'isPremium': isPremium,
      'isUserPosted': isUserPosted,
      'superBuiltUpSqFt': superBuiltUpSqFt,
      'carpetAreaSqFt': carpetAreaSqFt,
      'maintenanceMonthly': maintenanceMonthly,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'customImageBase64': customImageBase64,
      'posterType': posterType,
      'landUnit': landUnit,
      'landUnitValue': landUnitValue,
      'landFeatures': landFeatures,
      'approvalType': approvalType,
      'isBankLoanAvailable': isBankLoanAvailable,
      'isPriceNegotiable': isPriceNegotiable,
      'contactPhone': contactPhone,
      'sellerPhone': contactPhone ?? agent.phone,
      'sellerEmail': agent.email,
      'sellerName': agent.name,
      'googleMapUrl': googleMapUrl,
      'waterSource': waterSource,
      'hasLift': hasLift,
      'hasTrees': hasTrees,
      'treesDetails': treesDetails,
      'hasIncome': hasIncome,
      'incomeDetails': incomeDetails,
      'isLease': isLease,
      'rentalSubType': rentalSubType,
      'advanceAmount': advanceAmount,
      'commercialAreaType': commercialAreaType,
      'hasTable': hasTable,
      'hasFan': hasFan,
      'hasWaterSupply': hasWaterSupply,
      'hasShutter': hasShutter,
      'powerPhase': powerPhase,
    };
  }

  factory Property.fromMap(Map<String, dynamic> map) {
    List<String> parsedUrls = [];
    if (map['imageUrls'] is List) {
      parsedUrls = List<String>.from((map['imageUrls'] as List).map((e) => e.toString()));
    } else if (map['imageUrl'] != null && map['imageUrl'].toString().isNotEmpty) {
      parsedUrls = [map['imageUrl'].toString()];
    }

    String? singleUrl = map['imageUrl']?.toString();
    if ((singleUrl == null || singleUrl.isEmpty) && parsedUrls.isNotEmpty) {
      singleUrl = parsedUrls.first;
    }

    return Property(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      location: map['location'] ?? '',
      city: map['city'] ?? '',
      propertyType: map['propertyType'] ?? 'House',
      areaSqFt: map['areaSqFt'] ?? 1000,
      bedrooms: map['bedrooms'],
      bathrooms: map['bathrooms'],
      furnishingStatus: map['furnishingStatus'] ?? 'Unfurnished',
      facing: map['facing'] ?? 'East',
      floor: map['floor'] ?? 'Ground Floor',
      imageUrls: parsedUrls,
      imageUrl: singleUrl,
      imageKeys: List<String>.from(map['imageKeys'] ?? []),
      amenities: List<String>.from(map['amenities'] ?? []),
      agent: Agent.fromMap(map['agent'] ?? {}),
      postedDate: map['postedDate'] != null
          ? DateTime.tryParse(map['postedDate']) ?? DateTime.now()
          : DateTime.now(),
      status: map['status'] ?? 'active',
      isFavorite: map['isFavorite'] ?? false,
      views: map['views'] ?? 0,
      enquiries: map['enquiries'] ?? 0,
      isVerified: map['isVerified'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      isPremium: map['isPremium'] == true || map['isPremium'] == 1 || map['isPremium'] == '1',
      isUserPosted: map['isUserPosted'] ?? false,
      superBuiltUpSqFt: map['superBuiltUpSqFt'],
      carpetAreaSqFt: map['carpetAreaSqFt'],
      maintenanceMonthly: (map['maintenanceMonthly'] as num?)?.toDouble(),
      landmark: map['landmark'],
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      customImageBase64: map['customImageBase64'],
      posterType: map['posterType'] ?? 'Direct Owner',
      landUnit: map['landUnit'],
      landUnitValue: (map['landUnitValue'] as num?)?.toDouble(),
      landFeatures: List<String>.from(map['landFeatures'] ?? []),
      approvalType: map['approvalType'],
      isBankLoanAvailable: map['isBankLoanAvailable'] ?? false,
      isPriceNegotiable: map['isPriceNegotiable'] ?? true,
      contactPhone: map['contactPhone'] ?? map['agent']?['phone'],
      googleMapUrl: map['googleMapUrl'],
      waterSource: map['waterSource'],
      hasLift: map['hasLift'] ?? false,
      hasTrees: map['hasTrees'] ?? false,
      treesDetails: map['treesDetails'],
      hasIncome: map['hasIncome'] ?? false,
      incomeDetails: map['incomeDetails'],
      isLease: map['isLease'] ?? false,
      rentalSubType: map['rentalSubType'],
      advanceAmount: (map['advanceAmount'] as num?)?.toDouble(),
      commercialAreaType: map['commercialAreaType'],
      hasTable: map['hasTable'] ?? false,
      hasFan: map['hasFan'] ?? false,
      hasWaterSupply: map['hasWaterSupply'] ?? false,
      hasShutter: map['hasShutter'] ?? false,
      powerPhase: map['powerPhase'],
    );
  }
}

