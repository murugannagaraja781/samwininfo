import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/land_units.dart';
import '../../core/utils/location_service.dart';
import '../../core/widgets/animated_favorite_btn.dart';
import '../../core/widgets/property_visual.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';
import '../auth/login_screen.dart';
import '../chat/conversation_screen.dart';
import '../payment/payment_webview_screen.dart';
import '../account/user_requests_screen.dart';
import 'agent_profile_screen.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final properties = ref.read(propertiesProvider);
      final p = properties.cast<Property?>().firstWhere(
            (item) => item?.id == widget.propertyId,
            orElse: () => null,
          );
      if (p != null) {
        _logPropertyView(p);
      }
      _syncAdAccess();
    });
  }

  Future<void> _syncAdAccess() async {
    try {
      final user = ref.read(userProfileProvider);
      if (!user.isLoggedIn) return;
      final userIdentifier = user.email.isNotEmpty ? user.email : user.phone;
      final url = Uri.parse(
        '${ApiConfig.instance.serverUrl}/users.php?action=get_ad_access&user_id=${Uri.encodeComponent(userIdentifier)}&user_email=${Uri.encodeComponent(user.email)}&user_phone=${Uri.encodeComponent(user.phone)}&property_id=${widget.propertyId}',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          final storage = ref.read(localStorageServiceProvider);
          final int viewed = data['ads_viewed'] ?? 0;
          await storage.setFreeContactsUsed(viewed);
          if (data['unlocked_properties'] is List) {
            final List<String> list = (data['unlocked_properties'] as List).map((e) => e.toString()).toList();
            await storage.setUnlockedPropertyIds(list);
          }
          if (mounted) setState(() {});
        }
      }
    } catch (_) {}
  }

  Future<void> _logPropertyView(Property property) async {
    try {
      final user = ref.read(userProfileProvider);
      final url = '${ApiConfig.instance.serverUrl}/activities.php';
      await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userName': user.name.isNotEmpty ? user.name : 'Customer',
          'userPhone': user.phone,
          'userEmail': user.email,
          'actionType': 'property_view',
          'actionTitle': 'சொத்து விவரம் பார்வை (Property View)',
          'propId': property.id,
          'propTitle': property.title,
          'propType': property.propertyType,
          'propLocation': property.location,
          'sellerName': property.agent.name,
          'sellerPhone': property.agent.phone,
          'amount': 0.0,
        }),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  Future<void> _logContactActivity(Property property, String contactMethod) async {
    try {
      final user = ref.read(userProfileProvider);
      final url = '${ApiConfig.instance.serverUrl}/activities.php';
      await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userName': user.name.isNotEmpty ? user.name : 'Customer',
          'userPhone': user.phone,
          'userEmail': user.email,
          'actionType': 'contact_unlock_free',
          'actionTitle': 'உரிமையாளர் தொடர்பு பார்க்கப்பட்டது ($contactMethod)',
          'propId': property.id,
          'propTitle': property.title,
          'propType': property.propertyType,
          'propLocation': property.location,
          'sellerName': property.agent.name,
          'sellerPhone': property.agent.phone,
          'amount': 0.0,
          'details': '$contactMethod மூலம் உரிமையாளர் ${property.agent.name} தொடர்பு விவரம் பார்வையிடப்பட்டது.',
        }),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final properties = ref.watch(propertiesProvider);
    final property = properties.cast<Property?>().firstWhere(
          (p) => p?.id == widget.propertyId,
          orElse: () => null,
        );

    if (property == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Property Details')),
        body: const Center(child: Text('Property not found.')),
      );
    }

    final totalImages = property.imageUrls.isNotEmpty
        ? property.imageUrls.length
        : (property.imageKeys.isNotEmpty ? property.imageKeys.length : 3);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Main Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. Image Carousel Header
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    SizedBox(
                      height: 320,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: totalImages,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                        itemBuilder: (context, index) {
                          final currentUrl = (property.imageUrls.isNotEmpty && index < property.imageUrls.length)
                              ? property.imageUrls[index]
                              : property.imageUrl;
                          return PropertyVisual(
                            propertyType: property.propertyType,
                            visualIndex: index,
                            customImageBase64: property.customImageBase64,
                            imageUrl: currentUrl,
                            height: 320,
                            width: double.infinity,
                            borderRadius: BorderRadius.zero,
                          );
                        },
                      ),
                    ),

                    // Top navigation floating buttons
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back Button
                            _buildCircleButton(
                              icon: Icons.arrow_back_ios_new_rounded,
                              onTap: () => Navigator.pop(context),
                            ),
                            Row(
                              children: [
                                // Share Button
                                _buildCircleButton(
                                  icon: Icons.share_outlined,
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Listing link copied for "${property.title}"'),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.primaryDark,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 10),
                                // Favorite Button
                                AnimatedFavoriteButton(
                                  isFavorite: property.isFavorite,
                                  onToggle: () {
                                    ref.read(propertiesProvider.notifier).toggleFavorite(property.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Carousel Dots Indicator & Count Badge
                    Positioned(
                      bottom: 16,
                      left: 20,
                      right: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Dots
                          Row(
                            children: List.generate(totalImages, (index) {
                              final isSelected = index == _currentImageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(right: 5),
                                width: isSelected ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),

                          // Image Counter
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_currentImageIndex + 1} / $totalImages Photos',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Main Content Body
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -16, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  property.propertyType,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              if (property.isVerified) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentGoldLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.accentGold, width: 0.8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.verified_rounded, size: 13, color: AppColors.accentGold),
                                      SizedBox(width: 4),
                                      Text(
                                        'Verified Listing',
                                        style: TextStyle(
                                          color: AppColors.accentGold,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            DateFormatter.timeAgo(property.postedDate),
                            style: AppTextStyles.labelSmall,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Price & Per Sq.ft
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            CurrencyFormatter.formatIndianPrice(property.price, isRental: property.isRental),
                            style: AppTextStyles.priceLarge.copyWith(fontSize: 28),
                          ),
                          if (property.areaSqFt > 0 && !property.isRental) ...[
                            const SizedBox(width: 10),
                            Text(
                              CurrencyFormatter.formatPerSqFt(property.price, property.areaSqFt),
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Title
                      Text(
                        property.title,
                        style: AppTextStyles.h2.copyWith(fontSize: 20),
                      ),

                      const SizedBox(height: 8),

                      // Location & Landmark
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 18, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.location,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (property.landmark != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    property.landmark!,
                                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 20),

                      // 3. Category-Specific Bespoke Showcase Card
                      _buildCategorySpecificShowcase(property),

                      const SizedBox(height: 16),

                      // 4. Quick Specs Grid
                      Text('சொத்து முக்கிய விவரங்கள் (Property Overview)', style: AppTextStyles.h4),
                      const SizedBox(height: 12),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 1.25,
                        children: [
                          _buildSpecBox(
                            icon: Icons.straighten_rounded,
                            title: 'அளவு (Area)',
                            value: LandUnitConverter.formatDisplayArea(
                              sqFt: property.areaSqFt,
                              landUnit: property.landUnit,
                              landUnitValue: property.landUnitValue,
                            ),
                          ),
                          _buildSpecBox(
                            icon: Icons.person_pin_circle_outlined,
                            title: 'பதிவு செய்தவர்',
                            value: property.posterType ?? 'Direct Owner',
                          ),
                          _buildSpecBox(
                            icon: Icons.verified_outlined,
                            title: 'அங்கீகாரம்',
                            value: property.approvalType ?? (property.propertyType == 'Farmland' ? 'தோட்டம்' : 'Verified'),
                          ),
                          _buildSpecBox(
                            icon: Icons.account_balance_outlined,
                            title: 'வங்கி கடன்',
                            value: property.isBankLoanAvailable ? 'உண்டு (Available)' : 'இல்லை (No Loan)',
                          ),
                          _buildSpecBox(
                            icon: Icons.price_change_outlined,
                            title: 'விலை பேசலாம்',
                            value: property.isPriceNegotiable ? 'பேசலாம் (Yes)' : 'Fixed Price',
                          ),
                          _buildSpecBox(
                            icon: Icons.explore_outlined,
                            title: 'திசை (Facing)',
                            value: property.facing.isNotEmpty ? property.facing.split(' ').first : 'East',
                          ),
                          if (property.bedrooms != null)
                            _buildSpecBox(
                              icon: Icons.bed_outlined,
                              title: 'Bedrooms',
                              value: '${property.bedrooms} BHK',
                            ),
                          if (property.hasLift)
                            _buildSpecBox(
                              icon: Icons.elevator_outlined,
                              title: 'லிஃப்ட் வசதி',
                              value: 'உண்டு (Yes)',
                            ),
                          if (property.waterSource != null)
                            _buildSpecBox(
                              icon: Icons.water_drop_outlined,
                              title: 'குடிநீர் வசதி',
                              value: property.waterSource!.split(' ').first,
                            ),
                          if (property.propertyType == 'Farmland' && property.hasTrees)
                            _buildSpecBox(
                              icon: Icons.park_outlined,
                              title: 'மரங்கள்',
                              value: 'உண்டு (Yes)',
                            ),
                          if (property.propertyType == 'Farmland' && property.hasIncome)
                            _buildSpecBox(
                              icon: Icons.currency_rupee_rounded,
                              title: 'மகசூல் வருமானம்',
                              value: 'உண்டு (Income)',
                            ),
                          if (property.advanceAmount != null && property.advanceAmount! > 0)
                            _buildSpecBox(
                              icon: Icons.wallet_outlined,
                              title: 'அட்வான்ஸ்',
                              value: '₹${property.advanceAmount!.toInt()}',
                            ),
                          if (property.commercialAreaType != null)
                            _buildSpecBox(
                              icon: Icons.storefront_outlined,
                              title: 'பகுதி வகை',
                              value: property.commercialAreaType!,
                            ),
                        ],
                      ),

                      // Farmland extra highlights (Only for Farmland)
                      if (property.propertyType == 'Farmland' && property.treesDetails != null && property.treesDetails!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.park_rounded, color: Colors.green, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'மரங்கள்: ${property.treesDetails}',
                                  style: TextStyle(color: Colors.green.shade900, fontWeight: FontWeight.bold, fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      if (property.propertyType == 'Farmland' && property.incomeDetails != null && property.incomeDetails!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade300),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.monetization_on_outlined, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'வருமானம்: ${property.incomeDetails}',
                                  style: TextStyle(color: Colors.brown.shade900, fontWeight: FontWeight.bold, fontSize: 12.5),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Land & Plot feature chips
                      if (property.landFeatures.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('நில வசதிகள் (Land Amenities & Infrastructure)', style: AppTextStyles.labelLarge),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: property.landFeatures.map((feat) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 5),
                                  Text(
                                    feat,
                                    style: const TextStyle(
                                      color: AppColors.primaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 20),

                      // 4. Description
                      Text('Description', style: AppTextStyles.h4),
                      const SizedBox(height: 10),
                      Text(
                        property.description,
                        maxLines: _isDescriptionExpanded ? null : 4,
                        overflow: _isDescriptionExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.6,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isDescriptionExpanded = !_isDescriptionExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            _isDescriptionExpanded ? 'Read Less' : 'Read More',
                            style: AppTextStyles.labelMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 20),

                      // 5. Amenities
                      if (property.amenities.isNotEmpty) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Amenities', style: AppTextStyles.h4),
                            Text(
                              '${property.amenities.length} features',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: property.amenities.map((amenity) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border, width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    amenity,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: AppColors.border),
                        const SizedBox(height: 20),
                      ],

                      // 6. Property Specifications Table
                      Text('Property Details & Compliance', style: AppTextStyles.h4),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Column(
                          children: [
                            _buildDetailRow('Property ID', property.id.toUpperCase()),
                            _buildDetailRow('Super Built-Up Area', '${property.superBuiltUpSqFt ?? property.areaSqFt} sq.ft'),
                            _buildDetailRow('Carpet Area', '${property.carpetAreaSqFt ?? (property.areaSqFt * 0.85).round()} sq.ft'),
                            _buildDetailRow(
                              'Land Measurement',
                              LandUnitConverter.formatWithConversion(
                                sqFt: property.areaSqFt,
                                preferredUnit: property.landUnit,
                                unitValue: property.landUnitValue,
                              ),
                            ),
                            _buildDetailRow('Legal Approvals', 'CMDA & RERA Approved', isHighlight: true),
                            _buildDetailRow('Water Supply', 'Borewell & Kaveri Metro Water'),
                            if (property.maintenanceMonthly != null)
                              _buildDetailRow('Monthly Maintenance', '₹${property.maintenanceMonthly!.toInt()}/mo'),
                            _buildDetailRow('Availability Status', 'Ready to Move', isLast: true),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 20),

                      // Location & Live GPS Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Location & Live GPS', style: AppTextStyles.h4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.gps_fixed_rounded, size: 12, color: AppColors.primary),
                                SizedBox(width: 4),
                                Text(
                                  'GPS VERIFIED',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    property.location,
                                    style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            if (property.landmark != null && property.landmark!.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.near_me_outlined, size: 16, color: AppColors.textMuted),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Landmark: ${property.landmark}',
                                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 12),
                            // GPS HUD Bar
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.my_location_rounded, size: 14, color: AppColors.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${(property.latitude ?? 13.0382).toStringAsFixed(5)}° N, ${(property.longitude ?? 80.1565).toStringAsFixed(5)}° E',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'monospace',
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Open Google Maps Live Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  final lat = property.latitude ?? 13.0382;
                                  final lng = property.longitude ?? 80.1565;
                                  final url = LocationService.getGoogleMapsUrl(lat, lng, label: property.title);
                                  final uri = Uri.parse(url);
                                  if (await canLaunchUrl(uri)) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Opening Google Maps...')),
                                      );
                                    }
                                  }
                                },
                                icon: const Icon(Icons.map_rounded, size: 18),
                                label: const Text('Open in Google Maps / Navigation'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 20),

                      // 7. Agent / Owner & Contact Unlock Card
                      _buildOwnerContactCard(context, property),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 8. Sticky Bottom CTA Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Call button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
                      onPressed: () => _handleContactAction(context, property, 'Call'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // WhatsApp direct button
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.4), width: 1),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chat_outlined, color: Color(0xFF25D366), size: 20),
                      onPressed: () => _handleContactAction(context, property, 'WhatsApp'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Chat CTA Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleChatAction(context, property),
                        icon: const Icon(Icons.forum_outlined, size: 18),
                        label: const Text('Chat with Seller'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: AppColors.textPrimary),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSpecBox({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isHighlight = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // CATEGORY-SPECIFIC BESPOKE SHOWCASE CARDS
  // ==========================================

  Widget _buildCategorySpecificShowcase(Property property) {
    final type = property.propertyType.toLowerCase();

    if (type.contains('shop') || type.contains('commercial') || property.rentalSubType == 'கடை' || property.rentalSubType == 'அலுவலகம்') {
      return _buildShopOfficeShowcase(property);
    } else if (type.contains('farm') || property.rentalSubType == 'தோட்டம் குத்தகை') {
      return _buildFarmlandShowcase(property);
    } else if (type.contains('land') || type.contains('plot') || property.rentalSubType == 'காலி இடம்') {
      return _buildLandShowcase(property);
    } else if (type.contains('apartment')) {
      return _buildApartmentShowcase(property);
    } else if (type.contains('house') || type.contains('villa')) {
      return _buildHouseShowcase(property);
    } else if (property.isRental) {
      return _buildRentalShowcase(property);
    }
    return const SizedBox.shrink();
  }

  // 1. 🏪 Shop & Office Showcase (கடை / அலுவலகம்)
  Widget _buildShopOfficeShowcase(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.storefront_rounded, color: Color(0xFFB45309), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'வணிக வசதிகள் (Shop & Office Specs)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF78350F),
                    ),
                  ),
                ],
              ),
              if (property.commercialAreaType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB45309),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    property.commercialAreaType!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Facilities Grid (EB, Fan, Table, Water, Shutter)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureTag(
                icon: Icons.electrical_services_rounded,
                label: property.powerPhase ?? 'EB மின் வசதி',
                isAvailable: property.powerPhase != null || property.hasFan,
              ),
              _buildFeatureTag(
                icon: Icons.air_rounded,
                label: 'ஃபேன் (Fan)',
                isAvailable: property.hasFan,
              ),
              _buildFeatureTag(
                icon: Icons.table_restaurant_rounded,
                label: 'மேஜை (Table)',
                isAvailable: property.hasTable,
              ),
              _buildFeatureTag(
                icon: Icons.water_drop_rounded,
                label: 'தண்ணீர் (Water)',
                isAvailable: property.hasWaterSupply,
              ),
              _buildFeatureTag(
                icon: Icons.sensor_door_rounded,
                label: 'ஷட்டர் (Shutter)',
                isAvailable: property.hasShutter,
              ),
            ],
          ),
          if (property.advanceAmount != null && property.advanceAmount! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFCD34D)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'முன்பணம் (Advance Amount):',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF78350F)),
                  ),
                  Text(
                    CurrencyFormatter.formatIndian(property.advanceAmount!),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // 2. 🌴 Farmland Showcase (தோட்டம்)
  Widget _buildFarmlandShowcase(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0FDF4), Color(0xFFDCFCE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.agriculture_rounded, color: Color(0xFF15803D), size: 20),
              SizedBox(width: 8),
              Text(
                'விவசாய நில விவரங்கள் (Farmland Specs)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF14532D),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFeatureTag(
                icon: Icons.bolt_rounded,
                label: 'இலவச விவசாய EB',
                isAvailable: true,
              ),
              _buildFeatureTag(
                icon: Icons.water_rounded,
                label: 'போர்வெல் / கிணறு',
                isAvailable: true,
              ),
              if (property.hasTrees)
                _buildFeatureTag(
                  icon: Icons.park_rounded,
                  label: property.treesDetails ?? 'தென்னை / பழ மரங்கள்',
                  isAvailable: true,
                ),
              if (property.hasIncome)
                _buildFeatureTag(
                  icon: Icons.monetization_on_rounded,
                  label: property.incomeDetails ?? 'மாத மகசூல் வருமானம்',
                  isAvailable: true,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. 🏞️ Land & Plot Showcase (நிலம் / மனை)
  Widget _buildLandShowcase(Property property) {
    final sqFt = property.areaSqFt;
    final cents = LandUnitConverter.fromSqFt(sqFt, 'Cents');
    final kuzhi = LandUnitConverter.fromSqFt(sqFt, 'Kuzhi');
    final acres = LandUnitConverter.fromSqFt(sqFt, 'Acres');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBAE6FD)),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.terrain_rounded, color: Color(0xFF0284C7), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'நில அளவீடு விவரங்கள் (Land Matrix)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF0369A1),
                    ),
                  ),
                ],
              ),
              if (property.approvalType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    property.approvalType!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // Multi-unit conversions box
          Row(
            children: [
              Expanded(
                child: _buildUnitBox('சென்ட் (Cent)', '$cents'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUnitBox('குழி (Kuzhi)', '$kuzhi'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildUnitBox('ஏக்கர் (Acre)', '$acres'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. 🏢 Apartment Showcase (அபார்ட்மெண்ட்)
  Widget _buildApartmentShowcase(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.apartment_rounded, color: Color(0xFF7C3AED), size: 20),
              SizedBox(width: 8),
              Text(
                'அபார்ட்மெண்ட் சிறப்பம்சங்கள் (Apartment Specs)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF5B21B6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (property.bedrooms != null)
                _buildFeatureTag(icon: Icons.bed_rounded, label: '${property.bedrooms} BHK Flat', isAvailable: true),
              _buildFeatureTag(icon: Icons.elevator_rounded, label: property.hasLift ? 'லிஃப்ட் வசதி (Lift)' : 'No Lift', isAvailable: property.hasLift),
              _buildFeatureTag(icon: Icons.directions_car_rounded, label: 'Covered Parking', isAvailable: true),
              if (property.waterSource != null)
                _buildFeatureTag(icon: Icons.water_drop_rounded, label: property.waterSource!, isAvailable: true),
            ],
          ),
        ],
      ),
    );
  }

  // 5. 🏠 House / Villa Showcase (வீடு / வில்லா)
  Widget _buildHouseShowcase(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.home_work_rounded, color: Color(0xFF0F172A), size: 20),
              SizedBox(width: 8),
              Text(
                'தனிவீடு விவரங்கள் (Individual House Specs)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (property.bedrooms != null)
                _buildFeatureTag(icon: Icons.bed_rounded, label: '${property.bedrooms} Bedrooms', isAvailable: true),
              _buildFeatureTag(icon: Icons.fence_rounded, label: 'காம்பவுண்ட் சுவர்', isAvailable: true),
              _buildFeatureTag(icon: Icons.directions_car_rounded, label: 'Car Parking', isAvailable: true),
              _buildFeatureTag(icon: Icons.water_drop_rounded, label: property.waterSource ?? 'குடிநீர் & போர்வெல்', isAvailable: true),
            ],
          ),
        ],
      ),
    );
  }

  // 6. 🔑 Rental / Lease Showcase
  Widget _buildRentalShowcase(Property property) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFFEDD5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.vpn_key_rounded, color: Color(0xFFEA580C), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    property.isLease ? 'குத்தகை விவரங்கள் (Lease)' : 'வாடகை விவரங்கள் (Rental)',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF9A3412),
                    ),
                  ),
                ],
              ),
              if (property.rentalSubType != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA580C),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    property.rentalSubType!,
                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          if (property.advanceAmount != null && property.advanceAmount! > 0) ...[
            const SizedBox(height: 10),
            Text(
              'முன்பணம் (Advance): ₹${property.advanceAmount!.toInt()}',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFFC2410C)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUnitBox(String title, String val) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBAE6FD)),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 10.5, color: Color(0xFF0369A1), fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 15, color: Color(0xFF0C4A6E), fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _buildFeatureTag({required IconData icon, required String label, required bool isAvailable}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAvailable ? Colors.white : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAvailable ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isAvailable ? AppColors.primary : AppColors.textMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: isAvailable ? const Color(0xFF0F172A) : AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOwnerContactCard(BuildContext context, Property property) {
    final storage = ref.watch(localStorageServiceProvider);
    final isPremium = property.isPremium;
    final isUnlocked = !isPremium || storage.getUnlockedPropertyIds().contains(property.id);
    final freeUsed = storage.getFreeContactsUsed();
    final freeRemaining = (3 - freeUsed).clamp(0, 3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Listed By & Contact', style: AppTextStyles.h4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isPremium ? const Color(0xFFFFFBEB) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isPremium ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPremium ? Icons.workspace_premium_rounded : Icons.lock_open_rounded,
                    size: 13,
                    color: isPremium ? const Color(0xFFD97706) : const Color(0xFF059669),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isPremium ? 'பிரீமியம் விளம்பரம்' : 'இலவச தொடர்பு',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: isPremium ? const Color(0xFFD97706) : const Color(0xFF059669),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPremium
                ? (isUnlocked ? const Color(0xFFFFFDF5) : AppColors.surface)
                : const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPremium
                  ? (isUnlocked ? const Color(0xFFD97706) : const Color(0xFFF59E0B).withValues(alpha: 0.5))
                  : const Color(0xFF10B981),
              width: 1.5,
            ),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPremium
                            ? [const Color(0xFFF59E0B), const Color(0xFFD97706)]
                            : [const Color(0xFF10B981), const Color(0xFF059669)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        property.agent.name.isNotEmpty ? property.agent.name[0] : 'A',
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                property.agent.name,
                                style: AppTextStyles.h4.copyWith(fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (property.agent.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          property.agent.agencyName,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AgentProfileScreen(agent: property.agent)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      side: const BorderSide(color: AppColors.primary, width: 1.2),
                    ),
                    child: const Text('Profile', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),
              const SizedBox(height: 14),

              if (isUnlocked) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: isPremium ? const Color(0xFFD97706) : const Color(0xFF10B981),
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isPremium ? 'பிரீமியம் தொடர்பு எண்:' : 'உரிமையாளர் தொடர்பு எண்:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isPremium ? const Color(0xFF92400E) : const Color(0xFF065F46),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPremium ? const Color(0xFFD97706) : const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isPremium ? '✓ பிரீமியம் திறக்கப்பட்டது' : '✓ இலவச தொடர்பு',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: (isPremium ? const Color(0xFFD97706) : const Color(0xFF10B981)).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📞 ${property.agent.phone}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.phone_rounded, color: AppColors.primary),
                            onPressed: () => _launchCall(property.agent.phone),
                            tooltip: 'அழைக்க (Call)',
                          ),
                          IconButton(
                            icon: const Icon(Icons.chat_outlined, color: Color(0xFF25D366)),
                            onPressed: () => _launchWhatsApp(property.agent.phone, property.title, property.agent.name),
                            tooltip: 'WhatsApp',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ] else if (freeRemaining > 0) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'பிரீமியம் தொடர்பு:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '🎁 இலவச பார்வை: $freeRemaining / 3 மீதம்',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '📞 +91 98••••••••',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleContactAction(context, property, 'View'),
                          icon: const Icon(Icons.lock_open_rounded, size: 16),
                          label: const Text('இலவசமாக தொடர்பு காண்க (Unlock Contact)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'பிரீமியம் தொடர்பு எண்:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD97706),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              '3 இலவச பார்வைகள் முடிந்தது',
                              style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '📞 +91 98••••••••',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleContactAction(context, property, 'View'),
                          icon: const Icon(Icons.payment_rounded, size: 16),
                          label: const Text('₹10 செலுத்தி திறக்க (Special Offer)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showSendRequestDialog(context, property),
                  icon: const Icon(Icons.send_rounded, size: 16),
                  label: const Text('உரிமையாளருக்கு தொடர்பு கோரிக்கை அனுப்புக'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSendRequestDialog(BuildContext context, Property property) {
    final user = ref.read(userProfileProvider);
    if (!user.isLoggedIn) {
      _showLoginPrompt(context, property, 'Request');
      return;
    }

    final targetPhone = property.contactPhone ?? property.agent.phone;
    final targetName = property.agent.name;
    final messageCtrl = TextEditingController(
      text: 'வணக்கம், "${property.title}" சொத்து தொடர்பாக உங்களிடம் பேச விரும்புகிறேன்.',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.send_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('தொடர்பு கோரிக்கை', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'உரிமையாளர் $targetName அவர்களுக்கு நேரடி தொடர்பு கோரிக்கை அனுப்பப்படும். அவர் ஏற்றவுடன் உடனுக்குடன் உங்களுக்கு தகவல் வரும்.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'உங்கள் செய்தி (Message)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ரத்து'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final success = await ref.read(userRequestsProvider.notifier).sendRequest(
                receiverPhone: targetPhone,
                receiverName: targetName,
                propertyId: property.id,
                propertyTitle: property.title,
                message: messageCtrl.text.trim(),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'கோரிக்கை வெற்றிகரமாக அனுப்பப்பட்டது! உரிமையாளர் ஏற்கும்போது அறிவிப்பு வரும்.'
                          : 'கோரிக்கை அனுப்ப முடியவில்லை. மீண்டும் முயற்சிக்கவும்.',
                    ),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: success ? AppColors.emerald : AppColors.error,
                    action: success
                        ? SnackBarAction(
                            label: 'பார்க்க',
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const UserRequestsScreen(initialTabIndex: 1)),
                              );
                            },
                          )
                        : null,
                  ),
                );
              }
            },
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('அனுப்புக (Send)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleContactAction(BuildContext context, Property property, String method) async {
    final user = ref.read(userProfileProvider);
    if (!user.isLoggedIn) {
      _showLoginPrompt(context, property, method);
      return;
    }

    // If Super Admin set this property as FREE (not premium), allow direct contact without paywall
    if (!property.isPremium) {
      _performContactAction(property, method);
      return;
    }

    final storage = ref.read(localStorageServiceProvider);
    if (storage.getUnlockedPropertyIds().contains(property.id)) {
      _performContactAction(property, method);
      return;
    }

    // Server-side authoritative ad access check
    try {
      final userIdentifier = user.email.isNotEmpty ? user.email : user.phone;
      final url = Uri.parse(
        '${ApiConfig.instance.serverUrl}/users.php?action=get_ad_access&user_id=${Uri.encodeComponent(userIdentifier)}&user_email=${Uri.encodeComponent(user.email)}&user_phone=${Uri.encodeComponent(user.phone)}&property_id=${property.id}',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true) {
          final int viewed = data['ads_viewed'] ?? 0;
          final int remaining = data['remaining_free'] ?? (3 - viewed).clamp(0, 3);
          await storage.setFreeContactsUsed(viewed);
          if (data['unlocked_properties'] is List) {
            final List<String> list = (data['unlocked_properties'] as List).map((e) => e.toString()).toList();
            await storage.setUnlockedPropertyIds(list);
            if (list.contains(property.id) || data['already_unlocked'] == true) {
              if (mounted) setState(() {});
              _performContactAction(property, method);
              return;
            }
          }

          if (remaining > 0 || data['is_premium'] == true) {
            if (mounted) _showFreeUnlockDialog(context, property, method, remaining);
            return;
          } else {
            if (mounted) _showPaywallDialog(context, property, method);
            return;
          }
        }
      }
    } catch (_) {}

    // Fallback to local storage if network timeout
    final freeUsed = storage.getFreeContactsUsed();
    final freeRemaining = (3 - freeUsed).clamp(0, 3);

    if (freeRemaining > 0) {
      _showFreeUnlockDialog(context, property, method, freeRemaining);
    } else {
      _showPaywallDialog(context, property, method);
    }
  }

  void _showLoginPrompt(BuildContext context, Property property, String method) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              'உள்நுழைவு கட்டாயம் (Login Required)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            const Text(
              'உரிமையாளர் தொடர்பு எண்ணைப் பார்க்க அல்லது தொடர்பு கொள்ள, முதலில் Google மூலம் உள்நுழையவும்.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        onLoginSuccess: () {
                          _handleContactAction(context, property, method);
                        },
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.login_rounded, size: 20),
                label: const Text('Google மூலம் உள்நுழைக', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showFreeUnlockDialog(BuildContext context, Property property, String method, int freeRemaining) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.card_giftcard_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('இலவச தொடர்பு பார்வை'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('உங்களுக்கு 3 இலவச தொடர்புகளில் இன்னும் $freeRemaining மீதம் உள்ளது.'),
            const SizedBox(height: 10),
            Text(
              'இந்த சொத்தின் ("${property.title}") உரிமையாளர் (${property.agent.name}) தொடர்பு விவரங்களை இப்போது திறக்க விரும்புகிறீர்களா?',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ரத்து'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final user = ref.read(userProfileProvider);
              final storage = ref.read(localStorageServiceProvider);

              try {
                final url = Uri.parse('${ApiConfig.instance.serverUrl}/users.php');
                final userIdentifier = user.email.isNotEmpty ? user.email : user.phone;
                final res = await http.post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: jsonEncode({
                    'action': 'unlock_ad',
                    'user_id': userIdentifier,
                    'user_email': user.email,
                    'user_phone': user.phone,
                    'property_id': property.id,
                  }),
                ).timeout(const Duration(seconds: 5));

                if (res.statusCode == 200) {
                  final data = jsonDecode(res.body);
                  if (data['can_view'] == false || data['needs_payment'] == true) {
                    await storage.setFreeContactsUsed(3);
                    if (mounted) _showPaywallDialog(context, property, method);
                    return;
                  }
                  if (data['ads_viewed'] != null) {
                    await storage.setFreeContactsUsed(data['ads_viewed']);
                  }
                }
              } catch (_) {
                await storage.incrementFreeContactsUsed();
              }

              await storage.addUnlockedProperty(property.id);
              await _logContactActivity(property, 'Free Contact Unlock ($method)');
              if (!mounted) return;
              setState(() {});
              _performContactAction(property, method);
            },
            icon: const Icon(Icons.lock_open_rounded, size: 16),
            label: const Text('திறக்க (Unlock Now)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaywallDialog(BuildContext context, Property property, String method) {
    final messenger = ScaffoldMessenger.of(context);
    final user = ref.read(userProfileProvider);

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Stack(
                children: [
                  Container(
                    height: 90,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFB45309)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD97706).withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFCD34D)),
                      ),
                      child: const Text(
                        '💎 பிரீமியம் தொடர்பு திறப்பு',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Text(
                      property.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    Text(
                      '3 இலவச தொடர்புகள் முடிவடைந்தது. உரிமையாளர் (${property.agent.name}) தொடர்பு எண்ணை உடனே பெற மிகக் குறைந்த கட்டணம்:',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF475569),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    // Price Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'கட்டணம்: ',
                            style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                          const Text(
                            '₹30 ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF94A3B8),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '₹10',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '67% OFF',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Option 1: Razorpay Payment Gateway (Online - Inline Browser)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final buyerName = user.name.isNotEmpty ? user.name : 'Customer';
                          final buyerPhone = user.phone.isNotEmpty ? user.phone : '9894174944';
                          final baseWebUrl = ApiConfig.instance.serverUrl.replaceAll('/api', '');
                          final checkoutUrl = '$baseWebUrl/checkout.php?property_id=${property.id}&buyer_name=${Uri.encodeComponent(buyerName)}&buyer_phone=$buyerPhone&amount=10&method=$method';
                          
                          // Open in inline WebView browser inside the app
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => PaymentWebViewScreen(
                                url: checkoutUrl,
                                title: 'பாதுகாப்பான கட்டணம் (₹10)',
                                propertyId: property.id,
                              ),
                            ),
                          );

                          // Also unlock locally for seamless UX
                          final storage = ref.read(localStorageServiceProvider);
                          await storage.addUnlockedProperty(property.id);
                          await _logContactActivity(property, 'Paid Contact Unlock (Razorpay ₹10) ($method)');
                          if (!mounted) return;
                          setState(() {});
                          messenger.showSnackBar(
                            const SnackBar(
                              content: Text('🎉 Razorpay பேமெண்ட் திறக்கப்பட்டது! எண் திறக்கப்படுகிறது.'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                          _performContactAction(property, method);
                        },
                        icon: const Icon(Icons.payment_rounded, size: 20),
                        label: const Text(
                          '💳 Razorpay மூலம் செலுத்த (₹10)',
                          style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Option 2: Direct UPI (GPay / PhonePe / Paytm)
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final upiUri = Uri.parse('upi://pay?pa=9894174944@upi&pn=TenkasiDreams&am=10&cu=INR&tn=Unlock_${property.id}');
                          if (await canLaunchUrl(upiUri)) {
                            await launchUrl(upiUri, mode: LaunchMode.externalApplication);
                          } else {
                            final baseWebUrl = ApiConfig.instance.serverUrl.replaceAll('/api', '');
                            final checkoutUrl = '$baseWebUrl/checkout.php?property_id=${property.id}&amount=10';
                            if (!mounted) return;
                            await Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (_) => PaymentWebViewScreen(
                                  url: checkoutUrl,
                                  title: 'பாதுகாப்பான கட்டணம் (₹10)',
                                  propertyId: property.id,
                                ),
                              ),
                            );
                          }

                          final storage = ref.read(localStorageServiceProvider);
                          await storage.addUnlockedProperty(property.id);
                          await _logContactActivity(property, 'Paid Contact Unlock (UPI ₹10) ($method)');
                          if (!mounted) return;
                          setState(() {});
                          _performContactAction(property, method);
                        },
                        icon: const Icon(Icons.account_balance_wallet_rounded, size: 18, color: Color(0xFFD97706)),
                        label: const Text(
                          '⚡ GPay / PhonePe / UPI (₹10)',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFFD97706)),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD97706), width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Not now button
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'பிறகு செய்கிறேன் (Cancel)',
                        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _performContactAction(Property property, String method) {
    if (method == 'Call') {
      _launchCall(property.agent.phone);
    } else if (method == 'WhatsApp') {
      _launchWhatsApp(property.agent.phone, property.title, property.agent.name);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('உரிமையாளர் எண்: ${property.agent.phone}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
    }
  }

  Future<void> _launchCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final telUri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dialing $phone...'), backgroundColor: AppColors.primary),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(String phone, String title, String agentName) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final text = Uri.encodeComponent('பதிவு செய்தமைக்கு நன்றி');
    final uri = Uri.parse('https://wa.me/$cleanPhone?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _handleChatAction(BuildContext context, Property property) {
    final user = ref.read(userProfileProvider);
    if (!user.isLoggedIn) {
      _showLoginPrompt(context, property, 'Chat');
      return;
    }

    _handleChatAgent(context, property);
  }

  void _handleChatAgent(BuildContext context, Property property) async {
    await ref.read(conversationsProvider.notifier).startConversation(property);
    final convs = ref.read(conversationsProvider);
    final conv = convs.firstWhere(
      (c) => c.property.id == property.id,
      orElse: () => convs.first,
    );

    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ConversationScreen(conversationId: conv.id),
        ),
      );
    }
  }
}
