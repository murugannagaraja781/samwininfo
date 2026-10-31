import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/property_card.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';
import '../property_detail/property_detail_screen.dart';
import 'filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    final currentQuery = ref.read(searchFilterProvider).query;
    if (currentQuery.isNotEmpty) {
      _searchController.text = currentQuery;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(searchFilterProvider);
    final results = ref.watch(searchResultsProvider);
    final storage = ref.watch(localStorageServiceProvider);
    final recentSearches = storage.getRecentSearches();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Properties'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_agenda_outlined : Icons.grid_view_rounded),
            tooltip: _isGridView ? 'List View' : 'Grid View',
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Filter Button Row
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: Row(
              children: [
                // Input TextField
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border, width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.search,
                      onChanged: (val) {
                        ref.read(searchFilterProvider.notifier).updateQuery(val);
                      },
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          storage.addRecentSearch(val.trim());
                          setState(() {});
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Search location, BHK, type, keyword...',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 22),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  ref.read(searchFilterProvider.notifier).updateQuery('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Filter Trigger Button
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: () => FilterBottomSheet.show(context),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: filterState.hasActiveFilters ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: filterState.hasActiveFilters ? AppColors.primary : AppColors.border,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: filterState.hasActiveFilters
                                  ? AppColors.primary.withValues(alpha: 0.25)
                                  : Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 22,
                          color: filterState.hasActiveFilters ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (filterState.hasActiveFilters)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: AppColors.accentGold,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${filterState.activeFilterCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Horizontal Categories
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: AppConstants.categories.length,
              itemBuilder: (context, index) {
                final cat = AppConstants.categories[index];
                final isSelected = cat.id == filterState.categoryId;
                return CategoryChip(
                  category: cat,
                  isSelected: isSelected,
                  onTap: () {
                    ref.read(searchFilterProvider.notifier).updateCategory(cat.id);
                  },
                );
              },
            ),
          ),

          // 3. Recent searches (only if search field empty and recent searches exist)
          if (_searchController.text.isEmpty && recentSearches.isNotEmpty && !filterState.hasActiveFilters) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Searches', style: AppTextStyles.labelMedium),
                  InkWell(
                    onTap: () async {
                      await storage.clearRecentSearches();
                      setState(() {});
                    },
                    child: Text(
                      'Clear',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: recentSearches.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final query = recentSearches[index];
                  return InkWell(
                    onTap: () {
                      _searchController.text = query;
                      ref.read(searchFilterProvider.notifier).updateQuery(query);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.history_rounded, size: 14, color: AppColors.textMuted),
                          const SizedBox(width: 6),
                          Text(query, style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          // 4. Results Header Counter & Clear Filters CTA
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${results.length} Properties Found',
                  style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
                ),
                if (filterState.hasActiveFilters)
                  InkWell(
                    onTap: () {
                      _searchController.clear();
                      ref.read(searchFilterProvider.notifier).resetFilters();
                    },
                    child: Text(
                      'Reset All',
                      style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
          ),

          // 5. Results List or Grid
          Expanded(
            child: results.isEmpty
                ? EmptyStateView(
                    icon: Icons.search_off_rounded,
                    title: 'No Properties Found',
                    message: 'Try modifying your search keywords or adjusting your price and BHK filters.',
                    actionText: 'Reset Filters',
                    onAction: () {
                      _searchController.clear();
                      ref.read(searchFilterProvider.notifier).resetFilters();
                    },
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.63,
                        ),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final prop = results[index];
                          return PropertyCard(
                            property: prop,
                            isHorizontal: true,
                            width: double.infinity,
                            onTap: () => _openDetail(context, prop),
                            onFavoriteToggle: () {
                              ref.read(propertiesProvider.notifier).toggleFavorite(prop.id);
                            },
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
                        physics: const BouncingScrollPhysics(),
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final prop = results[index];
                          return PropertyCard(
                            property: prop,
                            onTap: () => _openDetail(context, prop),
                            onFavoriteToggle: () {
                              ref.read(propertiesProvider.notifier).toggleFavorite(prop.id);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  void _openDetail(BuildContext context, Property property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(propertyId: property.id),
      ),
    );
  }
}
