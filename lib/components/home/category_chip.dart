import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';

class PropertyCategoryChip extends ConsumerWidget {
  const PropertyCategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  final CategoryItem category;
  final bool isSelected;
  final VoidCallback onTap;

  String _getCategoryName(WidgetRef ref, CategoryItem cat) {
    final locale = ref.watch(localeProvider);
    if (locale.languageCode == 'ta' && cat.nameTa != null) {
      return cat.nameTa!;
    }
    switch (cat.id) {
      case 'all':
        return ref.tr('cat_all');
      case 'land':
      case 'plots':
        return ref.tr('cat_land');
      case 'farmland':
        return ref.tr('cat_farmland');
      case 'house':
      case 'villa':
        return ref.tr('cat_house');
      case 'apartment':
        return ref.tr('cat_apartment');
      case 'shop':
      case 'commercial':
        return ref.tr('cat_shop');
      case 'rental':
        return ref.tr('cat_rental');
      default:
        return cat.name;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayName = _getCategoryName(ref, category);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Photographic Card
          Container(
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 2.2 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isSelected ? 0.15 : 0.06),
                  blurRadius: isSelected ? 8 : 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isSelected ? 10 : 12),
              child: category.imagePath != null
                  ? Image.asset(
                      category.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildIconFallback(),
                    )
                  : _buildIconFallback(),
            ),
          ),
          const SizedBox(height: 6),
          // Tamil Label below image
          SizedBox(
            height: 32,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? AppColors.primary : const Color(0xFF0F172A),
                    height: 1.15,
                  ),
                  maxLines: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconFallback() {
    return Container(
      color: const Color(0xFFF1F5F9),
      child: Center(
        child: Icon(
          isSelected ? category.activeIcon : category.icon,
          size: 28,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
