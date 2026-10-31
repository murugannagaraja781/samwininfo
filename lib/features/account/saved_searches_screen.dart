import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../state/app_state_providers.dart';
import '../search/search_screen.dart';

class SavedSearchesScreen extends ConsumerStatefulWidget {
  const SavedSearchesScreen({super.key});

  @override
  ConsumerState<SavedSearchesScreen> createState() => _SavedSearchesScreenState();
}

class _SavedSearchesScreenState extends ConsumerState<SavedSearchesScreen> {
  @override
  Widget build(BuildContext context) {
    final storage = ref.watch(localStorageServiceProvider);
    final savedSearches = storage.getSavedSearches();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Saved Searches'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: savedSearches.isEmpty
          ? EmptyStateView(
              icon: Icons.bookmark_border_rounded,
              title: 'No Saved Searches',
              message: 'Save your customized filter criteria to get instantly alerted about new matching properties.',
              actionText: 'Search Now',
              onAction: () => Navigator.pop(context),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: savedSearches.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final search = savedSearches[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.saved_search_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(search, style: AppTextStyles.labelLarge),
                            const SizedBox(height: 2),
                            Text('Custom Filter Alert', style: AppTextStyles.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primary),
                        onPressed: () {
                          ref.read(searchFilterProvider.notifier).updateQuery(search);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SearchScreen()),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                        onPressed: () async {
                          await storage.removeSavedSearch(search);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
