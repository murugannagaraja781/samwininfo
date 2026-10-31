import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/location_service.dart';
import '../../core/widgets/animated_favorite_btn.dart';
import '../../core/widgets/property_visual.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';

class OlxGridCard extends ConsumerWidget {
  const OlxGridCard({
    super.key,
    required this.property,
    this.onTap,
  });

  final Property property;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priceStr = CurrencyFormatter.formatIndianPrice(
      property.price,
      isRental: property.isRental,
    );

    final userLoc = ref.watch(userLocationProvider);
    String? distanceBadge;
    if (userLoc.latitude != null && userLoc.longitude != null) {
      final pLat = property.latitude ?? LocationService.getCoordinatesForTown(property.location)?['lat'];
      final pLng = property.longitude ?? LocationService.getCoordinatesForTown(property.location)?['lng'];
      if (pLat != null && pLng != null) {
        final dist = LocationService.calculateDistanceKm(userLoc.latitude!, userLoc.longitude!, pLat, pLng);
        if (dist < 150) {
          distanceBadge = dist < 1.0 ? '${(dist * 1000).round()} m' : '${dist.toStringAsFixed(1)} km';
        }
      }
    }

    final areaDisplay = property.landUnit != null && property.landUnitValue != null
        ? '${property.landUnitValue} ${property.landUnit}'
        : '${property.areaSqFt} sq.ft';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: property.isPremium ? const Color(0xFFD97706) : const Color(0xFFE2E8F0),
          width: property.isPremium ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: property.isPremium
                ? const Color(0xFFF59E0B).withValues(alpha: 0.22)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: property.isPremium ? 10 : 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Image Thumbnail with Featured Badge & Favorite Icon
              Stack(
                children: [
                  PropertyVisual(
                    propertyType: property.propertyType,
                    visualIndex: property.id.hashCode.abs() % 4,
                    customImageBase64: property.customImageBase64,
                    imageUrl: property.primaryImageUrl,
                    height: 118,
                    width: double.infinity,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                  ),

                  // OLX Signature Yellow "FEATURED" pill
                  if (property.isFeatured)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.olxYellow,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          ref.tr('sec_hot'),
                          style: const TextStyle(
                            color: AppColors.olxNavy,
                            fontSize: 8.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),

                  // Premium or Free Contact Badge
                  Positioned(
                    top: 6,
                    left: property.isFeatured ? 64 : 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: property.isPremium
                            ? const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              )
                            : null,
                        color: property.isPremium ? null : const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            property.isPremium
                                ? Icons.workspace_premium_rounded
                                : Icons.lock_open_rounded,
                            size: 9.5,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 2.5),
                          Text(
                            property.isPremium
                                ? (ref.isTamil ? 'பிரீமியம்' : 'PREMIUM')
                                : (ref.isTamil ? 'இலவச தொடர்பு' : 'FREE'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Circular Favorite Heart Button
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedFavoriteButton(
                          isFavorite: property.isFavorite,
                          size: 16,
                          onToggle: () {
                            ref.read(propertiesProvider.notifier).toggleFavorite(property.id);
                          },
                        ),
                      ),
                    ),
                  ),

                  // Verified badge
                  if (property.isVerified)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.olxNavy.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 9, color: Color(0xFF23E5DB)),
                            const SizedBox(width: 2.5),
                            Text(
                              ref.tr('verified_badge'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // 2. Card Content (OLX Typography)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Bold Price (Classic OLX Dark Navy or Amber Gold for Premium)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  priceStr,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: property.isPremium ? const Color(0xFFB45309) : AppColors.olxNavy,
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (property.isPremium)
                                const Icon(Icons.star_rounded, size: 15, color: Color(0xFFD97706)),
                            ],
                          ),
                          const SizedBox(height: 2),

                          // Area & Facing
                          Text(
                            '$areaDisplay ${property.facing.isNotEmpty ? "• ${property.facing.split('(').first.trim()}" : ""}',
                            style: const TextStyle(
                              color: AppColors.olxNavy,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),

                          // Title
                          Text(
                            property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              color: AppColors.olxTextSecondary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),

                      // Location & Date (OLX Footer in small uppercase)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${property.location.split(',').first.trim().toUpperCase()}${distanceBadge != null ? " • 📍 $distanceBadge" : ""}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.olxTextMuted,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormatter.timeAgo(property.postedDate).toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.olxTextMuted,
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
