import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'SamWin';
  static const String appTagline = 'SamWin - Real Estate & Property Solutions';

  // Poster Types (Who is posting)
  static const List<PosterType> posterTypes = [
    PosterType(
      id: 'owner',
      nameEn: 'Owner',
      nameTa: 'உரிமையாளர்',
      subtitleTa: '(உரிமையாளர்)',
      icon: Icons.person_rounded,
    ),
    PosterType(
      id: 'promoter',
      nameEn: 'Promoter',
      nameTa: 'புரோமோட்டர்',
      subtitleTa: '(புரோமோட்டர்)',
      icon: Icons.campaign_rounded,
    ),
    PosterType(
      id: 'builder',
      nameEn: 'Builder',
      nameTa: 'பில்டர்',
      subtitleTa: '(பில்டர்)',
      icon: Icons.engineering_rounded,
    ),
    PosterType(
      id: 'agent',
      nameEn: 'Agent',
      nameTa: 'ஏஜென்ட்',
      subtitleTa: '(ஏஜென்ட்)',
      icon: Icons.support_agent_rounded,
    ),
  ];

  // Property Sub-Types (Tamil-specific from screenshot)
  static const List<PropertySubType> propertySubTypes = [
    PropertySubType(id: 'individual_house', nameEn: 'Individual House', nameTa: 'தனிவீடு', icon: Icons.home_rounded),
    PropertySubType(id: 'villa', nameEn: 'Villa', nameTa: 'வில்லா', icon: Icons.villa_rounded),
    PropertySubType(id: 'brick_house', nameEn: 'Brick House', nameTa: 'செங்கல் வீடு', icon: Icons.house_rounded),
    PropertySubType(id: 'farm_house', nameEn: 'Farm House', nameTa: 'பண்ணை வீடு', icon: Icons.agriculture_rounded),
    PropertySubType(id: 'cottage', nameEn: 'Cottage', nameTa: 'காட்டேஜ் வீடு', icon: Icons.cottage_rounded),
    PropertySubType(id: 'duplex', nameEn: 'Duplex House', nameTa: 'கூடாரம் வீடு', icon: Icons.holiday_village_rounded),
    PropertySubType(id: 'apartment', nameEn: 'Apartment', nameTa: 'அபார்ட்மெண்ட் வீடு', icon: Icons.apartment_rounded),
    PropertySubType(id: 'un_approval', nameEn: 'UN Approval House', nameTa: 'UN approval வீடு', icon: Icons.verified_rounded),
    PropertySubType(id: 'un_eb', nameEn: 'UN EB House', nameTa: 'UN EB வீடு', icon: Icons.electrical_services_rounded),
    PropertySubType(id: 'council_house', nameEn: 'Council Seat House', nameTa: 'கவுன்சில் சீட் வீடு', icon: Icons.account_balance_rounded),
  ];

  // Categories matching the 6 core Tamil Nadu property types
  static const List<CategoryItem> categories = [
    CategoryItem(
      id: 'all',
      name: 'All',
      nameTa: 'அனைத்தும்',
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard_rounded,
    ),
    CategoryItem(
      id: 'house',
      name: 'House',
      nameTa: 'வீடு',
      imagePath: 'assets/images/cat_house.png',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    CategoryItem(
      id: 'land',
      name: 'Land / Plot',
      nameTa: 'நிலம் / மனை',
      imagePath: 'assets/images/cat_land.png',
      icon: Icons.landscape_outlined,
      activeIcon: Icons.landscape_rounded,
    ),
    CategoryItem(
      id: 'farmland',
      name: 'Farm / Garden',
      nameTa: 'தோட்டம்',
      imagePath: 'assets/images/cat_farm.png',
      icon: Icons.nature_people_outlined,
      activeIcon: Icons.nature_people_rounded,
    ),
    CategoryItem(
      id: 'shop',
      name: 'Shop / Commercial',
      nameTa: 'கடை / வணிகம்',
      imagePath: 'assets/images/cat_shop.png',
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
    ),
    CategoryItem(
      id: 'apartment',
      name: 'Apartment',
      nameTa: 'அபார்ட்மெண்ட்',
      imagePath: 'assets/images/cat_apartment.png',
      icon: Icons.apartment_outlined,
      activeIcon: Icons.apartment_rounded,
    ),
    CategoryItem(
      id: 'rental',
      name: 'Rental Property',
      nameTa: 'வாடகைக்கு',
      imagePath: 'assets/images/cat_rental.png',
      icon: Icons.vpn_key_outlined,
      activeIcon: Icons.vpn_key_rounded,
    ),
  ];

  // Locations for switching and filtering
  static const List<String> popularLocations = [
    'Tenkasi, Tamil Nadu',
    'Pavoorchatram, Tamil Nadu',
    'Courtallam, Tamil Nadu',
    'Surandai, Tamil Nadu',
    'Alangulam, Tamil Nadu',
    'Kadayanallur, Tamil Nadu',
    'Shenkottai, Tamil Nadu',
    'Sankarankovil, Tamil Nadu',
    'Tirunelveli, Tamil Nadu',
    'Rajapalayam, Tamil Nadu',
    'Virudhunagar, Tamil Nadu',
    'Madurai, Tamil Nadu',
    'Chennai, Tamil Nadu',
  ];

  // Amenities
  static const List<String> availableAmenities = [
    '24x7 Security',
    'Power Backup',
    'Covered Car Parking',
    'Swimming Pool',
    'Gymnasium',
    'Club House',
    'Children Play Area',
    'High Speed Elevator',
    'Rainwater Harvesting',
    'CCTV Surveillance',
    'Landscaped Garden',
    'Water Treatment Plant',
    'Intercom Facility',
    'Vaastu Compliant',
    'Fire Safety System',
    'EV Charging Station',
  ];

  // BHK filters
  static const List<String> bhkOptions = ['1 BHK', '2 BHK', '3 BHK', '4 BHK+'];

  // Furnishing options
  static const List<String> furnishingOptions = [
    'Fully Furnished',
    'Semi-Furnished',
    'Unfurnished',
  ];

  // Building Status Options (Tamil)
  static const List<BuildingStatusOption> buildingStatusOptions = [
    BuildingStatusOption(
      id: 'completed',
      nameEn: 'Fully Completed',
      nameTa: 'முழுமையாக கட்டி முடிக்கப்பட்டது',
    ),
    BuildingStatusOption(
      id: 'under_construction',
      nameEn: 'Under Construction',
      nameTa: 'கட்டுமானம் நடந்து வருகிறது',
    ),
    BuildingStatusOption(
      id: 'not_built',
      nameEn: 'Not Yet Built',
      nameTa: 'கட்டிடம் முழுக்கப்படவில்லை',
    ),
  ];

  // Facing directions (8 directions)
  static const List<String> facingDirections = [
    'North',
    'East',
    'South',
    'West',
    'North-East',
  ];

  // Tamil facing directions for UI
  static const List<FacingDirection> facingDirectionsFull = [
    FacingDirection(id: 'east', nameEn: 'East', nameTa: 'கிழக்கு'),
    FacingDirection(id: 'west', nameEn: 'West', nameTa: 'மேற்கு'),
    FacingDirection(id: 'north', nameEn: 'North', nameTa: 'வடக்கு'),
    FacingDirection(id: 'south', nameEn: 'South', nameTa: 'தெற்கு'),
    FacingDirection(id: 'northeast', nameEn: 'North-East', nameTa: 'வடகிழக்கு'),
    FacingDirection(id: 'northwest', nameEn: 'North-West', nameTa: 'வடமேற்கு'),
    FacingDirection(id: 'southeast', nameEn: 'South-East', nameTa: 'தென்கிழக்கு'),
    FacingDirection(id: 'southwest', nameEn: 'South-West', nameTa: 'தென்மேற்கு'),
  ];

  // Districts for Tenkasi region
  static const List<String> districts = [
    'தென்காசி',
    'திருநெல்வேலி',
    'மதுரை',
    'விருதுநகர்',
    'தூத்துக்குடி',
    'நாகர்கோவில்',
    'சென்னை',
  ];
}

class CategoryItem {
  final String id;
  final String name;
  final String? nameTa;
  final String? imagePath;
  final IconData icon;
  final IconData activeIcon;

  const CategoryItem({
    required this.id,
    required this.name,
    this.nameTa,
    this.imagePath,
    required this.icon,
    required this.activeIcon,
  });
}

class PosterType {
  final String id;
  final String nameEn;
  final String nameTa;
  final String subtitleTa;
  final IconData icon;

  const PosterType({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    required this.subtitleTa,
    required this.icon,
  });
}

class PropertySubType {
  final String id;
  final String nameEn;
  final String nameTa;
  final IconData icon;

  const PropertySubType({
    required this.id,
    required this.nameEn,
    required this.nameTa,
    required this.icon,
  });
}

class BuildingStatusOption {
  final String id;
  final String nameEn;
  final String nameTa;

  const BuildingStatusOption({
    required this.id,
    required this.nameEn,
    required this.nameTa,
  });
}

class FacingDirection {
  final String id;
  final String nameEn;
  final String nameTa;

  const FacingDirection({
    required this.id,
    required this.nameEn,
    required this.nameTa,
  });
}
