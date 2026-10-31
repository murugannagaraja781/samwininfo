import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/land_units.dart';

class StepPricing extends ConsumerWidget {
  const StepPricing({
    super.key,
    required this.priceController,
    required this.areaController,
    required this.selectedUnit,
    required this.onUnitSelected,
  });

  final TextEditingController priceController;
  final TextEditingController areaController;
  final String selectedUnit;
  final ValueChanged<String> onUnitSelected;

  static const List<String> landUnits = ['Cents', 'Acres', 'Grounds', 'Sq.Ft'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTamil = ref.watch(localeProvider).languageCode == 'ta';

    final enteredPrice = double.tryParse(priceController.text.replaceAll(',', '')) ?? 0;
    final enteredArea = double.tryParse(areaController.text) ?? 0;
    final sqFtEquiv = LandUnitConverter.toSqFt(enteredArea, selectedUnit);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('step_pricing'),
            style: AppTextStyles.h2.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isTamil
                ? 'விலை மற்றும் நிலத்தின் அளவை குறிப்பிடவும் (தென்காசியில் பொதுவாக சென்ட் அல்லது ஏக்கர்)'
                : 'Set a competitive price and accurate land measurement for Tenkasi buyers',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 22),

          // Price Field
          Text(
            ref.tr('field_price'),
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: ref.tr('field_price_hint'),
              prefixIcon: const Icon(Icons.currency_rupee_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          if (enteredPrice > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${isTamil ? 'மதிப்பு' : 'Readout'}: ${CurrencyFormatter.formatIndianPrice(enteredPrice)}',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Land Unit Selection
          Text(
            ref.tr('field_unit'),
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: landUnits.map((unit) {
              final isSelected = selectedUnit == unit;
              final localizedUnitName = _getUnitName(ref, unit);

              return ChoiceChip(
                label: Text(localizedUnitName),
                selected: isSelected,
                selectedColor: AppColors.primaryLight,
                backgroundColor: Colors.white,
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 1.5 : 1,
                ),
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryDark : AppColors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 13,
                ),
                onSelected: (selected) {
                  if (selected) onUnitSelected(unit);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Land Size Value
          Text(
            ref.tr('field_area'),
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: areaController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: ref.tr('field_area_hint'),
              suffixText: selectedUnit,
              prefixIcon: const Icon(Icons.square_foot_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          if (enteredArea > 0) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Equivalent: $sqFtEquiv Sq.Ft',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getUnitName(WidgetRef ref, String unit) {
    switch (unit) {
      case 'Cents':
        return ref.tr('unit_cents');
      case 'Acres':
        return ref.tr('unit_acres');
      case 'Grounds':
        return ref.tr('unit_grounds');
      case 'Sq.Ft':
        return ref.tr('unit_sqft');
      default:
        return unit;
    }
  }
}
