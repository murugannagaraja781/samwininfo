import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/animated_favorite_btn.dart';
import '../../core/widgets/property_visual.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';

class ListingPropertyCard extends ConsumerWidget {
  const ListingPropertyCard({
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

    final areaDisplay = property.landUnit != null && property.landUnitValue != null
        ? '${property.landUnitValue} ${property.landUnit}'
        : '${property.areaSqFt} sq.ft';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Thumbnail (OLX style)
                Stack(
                  children: [
                    PropertyVisual(
                      propertyType: property.propertyType,
                      visualIndex: property.id.hashCode.abs() % 4,
                      customImageBase64: property.customImageBase64,
                      imageUrl: property.primaryImageUrl,
                      width: 115,
                      height: 110,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    if (property.isFeatured)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC9A227),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'HOT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),

                // Details Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Price & Favorite Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              priceStr,
                              style: AppTextStyles.h3.copyWith(
                                color: AppColors.primary,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AnimatedFavoriteButton(
                            isFavorite: property.isFavorite,
                            size: 19,
                            onToggle: () {
                              ref.read(propertiesProvider.notifier).toggleFavorite(property.id);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),

                      // Title
                      Text(
                        property.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h4.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),

                      // Area + Facing
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              areaDisplay,
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (property.facing.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            Text(
                              '• ${property.facing}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Location & Date
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
                                Expanded(
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
                              ],
                            ),
                          ),
                          Text(
                            DateFormatter.timeAgo(property.postedDate),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textMuted,
                              fontSize: 10,
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
      ),
    );
  }
}
