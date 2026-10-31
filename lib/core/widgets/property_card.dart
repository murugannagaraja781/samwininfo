import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/property.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../utils/land_units.dart';
import 'animated_favorite_btn.dart';
import 'property_visual.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final bool isHorizontal;
  final double? width;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onFavoriteToggle,
    this.isHorizontal = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (isHorizontal) {
      return _buildHorizontalCard(context);
    }
    return _buildVerticalCard(context);
  }

  // Large Featured Horizontal Slider Card
  Widget _buildHorizontalCard(BuildContext context) {
    final cardWidth = width ?? 295.0;

    return Container(
      width: cardWidth,
      margin: cardWidth == double.infinity ? EdgeInsets.zero : const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with tags
              Stack(
                children: [
                  PropertyVisual(
                    propertyType: property.propertyType,
                    customImageBase64: property.customImageBase64,
                    imageUrl: property.primaryImageUrl,
                    height: 150,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  // Top badges
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBadge(
                          text: property.approvalType != null && property.approvalType!.isNotEmpty
                              ? property.approvalType!
                              : property.propertyType,
                          backgroundColor: AppColors.primary,
                          textColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  // Poster type badge (Direct Owner)
                  Positioned(
                    top: 10,
                    right: 48,
                    child: _buildBadge(
                      text: property.posterType ?? 'Direct Owner',
                      backgroundColor: Colors.black.withValues(alpha: 0.75),
                      textColor: Colors.white,
                    ),
                  ),
                  // Heart button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedFavoriteButton(
                      isFavorite: property.isFavorite,
                      onToggle: onFavoriteToggle,
                    ),
                  ),
                  // Price pill over image bottom
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24, width: 0.6),
                      ),
                      child: Text(
                        property.isRental
                            ? '₹${property.price.toInt()}/mo'
                            : CurrencyFormatter.formatIndianPrice(property.price),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content Details
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(fontSize: 14),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 13, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            property.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 8),
                    // Quick Specs & Area
                    _buildSpecsRow(property),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Full-width Vertical Listing Card (Matching User's Handwritten Sketch)
  Widget _buildVerticalCard(BuildContext context) {
    final areaStr = LandUnitConverter.formatDisplayArea(
      sqFt: property.areaSqFt,
      landUnit: property.landUnit,
      landUnitValue: property.landUnitValue,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Stack
              Stack(
                children: [
                  PropertyVisual(
                    propertyType: property.propertyType,
                    customImageBase64: property.customImageBase64,
                    imageUrl: property.primaryImageUrl,
                    height: 180,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
                  ),
                  // Badges top-left (Approval / Category)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildBadge(
                          text: property.approvalType != null && property.approvalType!.isNotEmpty
                              ? property.approvalType!
                              : (property.propertyType == 'Farmland' ? 'தோட்டம்' : property.propertyType),
                          backgroundColor: AppColors.primary,
                          textColor: Colors.white,
                        ),
                        if (property.isVerified) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: AppColors.accentGoldLight,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.accentGold, width: 0.8),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified_rounded, size: 12, color: AppColors.accentGold),
                                SizedBox(width: 3),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: AppColors.accentGold,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Poster Badge (Direct Owner) Top-Right
                  Positioned(
                    top: 12,
                    right: 48,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.white30, width: 0.5),
                      ),
                      child: Text(
                        property.posterType ?? 'Direct Owner',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  // Heart top-right
                  Positioned(
                    top: 8,
                    right: 8,
                    child: AnimatedFavoriteButton(
                      isFavorite: property.isFavorite,
                      onToggle: onFavoriteToggle,
                    ),
                  ),

                  // Posted time badge bottom-right
                  Positioned(
                    bottom: 10,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        DateFormatter.timeAgo(property.postedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Details Body
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price & Negotiable tag row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          property.isRental
                              ? '₹${property.price.toInt()}/மாதம்'
                              : CurrencyFormatter.formatIndianPrice(property.price),
                          style: AppTextStyles.priceLarge.copyWith(fontSize: 21),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: property.isPriceNegotiable ? Colors.green.shade50 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: property.isPriceNegotiable ? Colors.green : Colors.grey.shade400,
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            property.isPriceNegotiable ? 'பேசலாம் (Negotiable)' : 'Fixed',
                            style: TextStyle(
                              color: property.isPriceNegotiable ? Colors.green.shade800 : Colors.grey.shade700,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Title
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(fontSize: 15),
                    ),
                    const SizedBox(height: 4),

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            property.location,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Feature Chips (Borewell, EB, Fence, etc.)
                    if (property.landFeatures.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: property.landFeatures.take(4).map((feat) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              feat,
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],

                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 10),

                    // Specs & Action Buttons (Call & WhatsApp)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Area & Facing Chip
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.straighten_rounded, size: 13, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    areaStr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            if (property.facing.isNotEmpty)
                              Text(
                                property.facing.split(' ').first,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                          ],
                        ),

                        // Quick Call & WhatsApp Action Buttons
                        Row(
                          children: [
                            // Call Button
                            InkWell(
                              onTap: () => _launchCall(property.contactPhone ?? property.agent.phone),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.call, size: 13, color: AppColors.primary),
                                    SizedBox(width: 4),
                                    Text(
                                      'Call',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            // WhatsApp Button
                            InkWell(
                              onTap: () => _launchWhatsApp(
                                property.contactPhone ?? property.agent.phone,
                                property.title,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF25D366).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.chat, size: 13, color: Color(0xFF1B8A44)),
                                    SizedBox(width: 4),
                                    Text(
                                      'Chat',
                                      style: TextStyle(
                                        color: Color(0xFF1B8A44),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
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

  Widget _buildSpecsRow(Property prop) {
    final areaStr = LandUnitConverter.formatDisplayArea(
      sqFt: prop.areaSqFt,
      landUnit: prop.landUnit,
      landUnitValue: prop.landUnitValue,
    );

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _buildSpecChip(
          icon: Icons.straighten_rounded,
          label: areaStr,
        ),
        if (prop.bedrooms != null)
          _buildSpecChip(
            icon: Icons.bed_outlined,
            label: '${prop.bedrooms} BHK',
          ),
        if (prop.hasLift)
          _buildSpecChip(
            icon: Icons.elevator_outlined,
            label: 'Lift',
          ),
      ],
    );
  }

  Widget _buildSpecChip({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: AppColors.textMuted),
        const SizedBox(width: 3),
        Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 11.5,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required String text,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Future<void> _launchCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone, String title) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final text = Uri.encodeComponent('பதிவு செய்தமைக்கு நன்றி');
    final uri = Uri.parse('https://wa.me/$clean?text=$text');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
