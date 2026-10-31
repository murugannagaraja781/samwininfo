import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StepCategory extends ConsumerWidget {
  const StepCategory({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  final String selectedType;
  final ValueChanged<String> onTypeSelected;

  static const List<Map<String, dynamic>> propertyCategories = [
    {
      'id': 'Plots',
      'title': 'Plots & Land',
      'title_ta': 'மனைகள் & காலி நிலம்',
      'desc': 'Residential plots, DTCP layouts & investment sites',
      'desc_ta': 'குடியிருப்பு மனைகள் மற்றும் முதலீட்டு இடங்கள்',
      'icon': Icons.crop_square_rounded,
    },
    {
      'id': 'Farm Land',
      'title': 'Agricultural & Farm Land',
      'title_ta': 'விவசாய மற்றும் பண்ணை நிலம்',
      'desc': 'Coconut groves, fertile wet lands & farm houses',
      'desc_ta': 'தென்னந்தோப்புகள், நன்செய் நிலங்கள் மற்றும் பண்ணை வீடு',
      'icon': Icons.grass_rounded,
    },
    {
      'id': 'House',
      'title': 'Individual House & Villa',
      'title_ta': 'தனி வீடு மற்றும் வில்லா',
      'desc': 'Gated community villas, independent houses & duplexes',
      'desc_ta': 'தனி வீடுகள் மற்றும் சொகுசு வில்லாக்கள்',
      'icon': Icons.home_rounded,
    },
    {
      'id': 'Commercial',
      'title': 'Commercial & Shops',
      'title_ta': 'வணிக வளாகம் & கடைகள்',
      'desc': 'Commercial plots, roadside shops & showrooms',
      'desc_ta': 'பிரதான சாலை கடைகள் மற்றும் வணிக இடங்கள்',
      'icon': Icons.storefront_rounded,
    },
    {
      'id': 'Rental',
      'title': 'House / Commercial Rental',
      'title_ta': 'வாடகை வீடு / வணிக இடம்',
      'desc': 'Residential houses or commercial spaces for rent',
      'desc_ta': 'வாடகைக்கு விடப்படும் வீடுகள் மற்றும் அலுவலகங்கள்',
      'icon': Icons.vpn_key_rounded,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTamil = ref.watch(localeProvider).languageCode == 'ta';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('step_category'),
            style: AppTextStyles.h2.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isTamil
                ? 'உங்கள் விளம்பரத்திற்கு மிகவும் பொருத்தமான வகையைத் தேர்ந்தெடுக்கவும்'
                : 'Choose the most suitable category for your listing in Tenkasi',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Categories List
          ...propertyCategories.map((cat) {
            final isSelected = selectedType.toLowerCase() == (cat['id'] as String).toLowerCase();
            final title = isTamil ? cat['title_ta'] : cat['title'];
            final desc = isTamil ? cat['desc_ta'] : cat['desc'];

            return GestureDetector(
              onTap: () => onTypeSelected(cat['id'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceAlt,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        color: isSelected ? Colors.white : AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.h4.copyWith(
                              color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            desc,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                      size: 22,
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
