import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/location_service.dart';
import '../../core/widgets/animated_favorite_btn.dart';
import '../../core/widgets/property_visual.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';

class FeaturedPropertyCard extends ConsumerWidget {
  const FeaturedPropertyCard({
    super.key,
    required this.property,
    this.onTap,
    this.width = 280,
  });

  final Property property;
  final VoidCallback? onTap;
  final double width;

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
      width: width,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: property.isPremium ? const Color(0xFFD97706) : AppColors.border,
          width: property.isPremium ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: property.isPremium
                ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: property.isPremium ? 14 : 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with overlays
              Stack(
                children: [
                  PropertyVisual(
                    propertyType: property.propertyType,
                    visualIndex: property.id.hashCode.abs() % 4,
                    customImageBase64: property.customImageBase64,
                    imageUrl: property.primaryImageUrl,
                    height: 125,
                    width: width,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                  ),

                  // "FEATURED" / "HOT" Badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFC9A227),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            ref.tr('sec_hot'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Premium or Free Contact Badge
                  Positioned(
                    top: 10,
                    left: 88,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: property.isPremium
                            ? const LinearGradient(
                                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                              )
                            : null,
                        color: property.isPremium ? null : const Color(0xFF059669),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            property.isPremium ? Icons.workspace_premium_rounded : Icons.lock_open_rounded,
                            size: 11,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            property.isPremium
                                ? (ref.isTamil ? 'பிரீமியம்' : 'PREMIUM')
                                : (ref.isTamil ? 'இலவசம்' : 'FREE'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AnimatedFavoriteButton(
                        isFavorite: property.isFavorite,
                        size: 20,
                        onToggle: () {
                          ref.read(propertiesProvider.notifier).toggleFavorite(property.id);
                        },
                      ),
                    ),
                  ),

                  // DTCP Verified chip on image bottom
                  if (property.isVerified)
                    Positioned(
                      bottom: 8,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.verified_rounded, size: 11, color: Color(0xFF81C784)),
                            const SizedBox(width: 4),
                            Text(
                              ref.tr('verified_badge'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Property Details Body
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            priceStr,
                            style: AppTextStyles.priceLarge.copyWith(
                              fontSize: 18,
                              color: property.isPremium ? const Color(0xFFB45309) : AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        if (property.isPremium)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.workspace_premium_rounded, size: 12, color: Color(0xFFD97706)),
                                SizedBox(width: 2),
                                Text(
                                  'PREMIUM',
                                  style: TextStyle(
                                    color: Color(0xFFD97706),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Title
                    Text(
                      property.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h4.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Area & Facing Chip
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            areaDisplay,
                            style: const TextStyle(
                              color: AppColors.primaryDark,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (property.facing.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '${property.facing} Facing',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 8),

                    // Location & Posting Date
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 13,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 3),
                              Flexible(
                                child: Text(
                                  property.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              if (distanceBadge != null) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(3),
                                    border: Border.all(color: const Color(0xFFBFDBFE), width: 0.5),
                                  ),
                                  child: Text(
                                    '📍 $distanceBadge',
                                    style: const TextStyle(
                                      color: Color(0xFF1D4ED8),
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          DateFormatter.timeAgo(property.postedDate),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 10.5,
                          ),
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
}
