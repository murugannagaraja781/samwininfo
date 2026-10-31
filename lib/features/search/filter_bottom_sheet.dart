import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../state/app_state_providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FilterBottomSheet(),
    );
  }

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late String _selectedCategory;
  late String _selectedLocation;
  late RangeValues _priceRange;
  late List<String> _selectedBhks;
  late String _selectedFurnishing;
  late bool _verifiedOnly;
  late String _selectedSort;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(searchFilterProvider);
    _selectedCategory = filter.categoryId;
    _selectedLocation = filter.location;
    _priceRange = RangeValues(
      filter.minPrice.clamp(0.0, 50000000.0),
      filter.maxPrice.clamp(0.0, 50000000.0),
    );
    _selectedBhks = List.from(filter.bhkList);
    _selectedFurnishing = filter.furnishing;
    _verifiedOnly = filter.verifiedOnly;
    _selectedSort = filter.sortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Filter Properties', style: AppTextStyles.h3),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Offline Filter',
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.borderLight),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              physics: const BouncingScrollPhysics(),
              children: [
                // 1. Sort By
                Text('Sort By', style: AppTextStyles.labelLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildChoiceChip('Newest First', 'newest', _selectedSort, (val) => setState(() => _selectedSort = val)),
                    _buildChoiceChip('Price: Low to High', 'price_low_to_high', _selectedSort, (val) => setState(() => _selectedSort = val)),
                    _buildChoiceChip('Price: High to Low', 'price_high_to_low', _selectedSort, (val) => setState(() => _selectedSort = val)),
                    _buildChoiceChip('Most Popular', 'popular', _selectedSort, (val) => setState(() => _selectedSort = val)),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 20),

                // 2. Price Range Slider
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Price Range', style: AppTextStyles.labelLarge),
                    Text(
                      '${CurrencyFormatter.formatIndianPrice(_priceRange.start)} - ${CurrencyFormatter.formatIndianPrice(_priceRange.end)}',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                RangeSlider(
                  values: _priceRange,
                  min: 0,
                  max: 50000000,
                  divisions: 50,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.primaryLight,
                  labels: RangeLabels(
                    CurrencyFormatter.formatIndianPrice(_priceRange.start),
                    CurrencyFormatter.formatIndianPrice(_priceRange.end),
                  ),
                  onChanged: (values) {
                    setState(() => _priceRange = values);
                  },
                ),

                const SizedBox(height: 16),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 20),

                // 3. Property Type
                Text('Property Type', style: AppTextStyles.labelLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.categories.map((cat) {
                    return _buildChoiceChip(
                      cat.name,
                      cat.id,
                      _selectedCategory,
                      (val) => setState(() => _selectedCategory = val),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 20),

                // 4. Bedrooms (BHK)
                Text('Bedrooms (BHK)', style: AppTextStyles.labelLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.bhkOptions.map((bhk) {
                    final isSelected = _selectedBhks.contains(bhk);
                    return FilterChip(
                      label: Text(bhk),
                      selected: isSelected,
                      selectedColor: AppColors.primaryLight,
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedBhks.add(bhk);
                          } else {
                            _selectedBhks.remove(bhk);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 20),

                // 5. Furnishing Status
                Text('Furnishing', style: AppTextStyles.labelLarge),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Any', ...AppConstants.furnishingOptions].map((opt) {
                    return _buildChoiceChip(
                      opt,
                      opt,
                      _selectedFurnishing,
                      (val) => setState(() => _selectedFurnishing = val),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: AppColors.borderLight),
                const SizedBox(height: 16),

                // 6. Verified Properties Only Toggle
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Verified Properties Only', style: AppTextStyles.labelLarge),
                  subtitle: Text('Show only CMDA/DTCP and agent-verified properties', style: AppTextStyles.bodySmall),
                  value: _verifiedOnly,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _verifiedOnly = val);
                  },
                ),
              ],
            ),
          ),

          // Bottom Action Bar: Reset & Apply
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.border, width: 1.5),
                    ),
                    child: Text('Reset', style: AppTextStyles.buttonTextSmall.copyWith(color: AppColors.textSecondary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip(String label, String value, String currentSelected, ValueChanged<String> onSelected) {
    final isSelected = value == currentSelected;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryLight,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
        width: 1,
      ),
      onSelected: (_) => onSelected(value),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedCategory = 'all';
      _selectedLocation = 'All Locations';
      _priceRange = const RangeValues(0, 50000000);
      _selectedBhks.clear();
      _selectedFurnishing = 'Any';
      _verifiedOnly = false;
      _selectedSort = 'newest';
    });
  }

  void _applyFilters() {
    final stateNotifier = ref.read(searchFilterProvider.notifier);
    stateNotifier.resetFilters();
    stateNotifier.updateCategory(_selectedCategory);
    stateNotifier.updateLocation(_selectedLocation);
    stateNotifier.updatePriceRange(_priceRange.start, _priceRange.end);
    stateNotifier.updateFurnishing(_selectedFurnishing);
    stateNotifier.toggleVerifiedOnly(_verifiedOnly);
    stateNotifier.updateSortBy(_selectedSort);
    for (final bhk in _selectedBhks) {
      stateNotifier.toggleBhk(bhk);
    }

    Navigator.pop(context);
  }
}
