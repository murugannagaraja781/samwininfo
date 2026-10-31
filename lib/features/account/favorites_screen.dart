import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/property_card.dart';
import '../../state/app_state_providers.dart';
import '../property_detail/property_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Favorite Properties (${favorites.length})'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: favorites.isEmpty
          ? EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: 'No Favorites Saved',
              message: 'Tap the heart icon on any property to save it to your local wishlist for quick reference.',
              actionText: 'Explore Properties',
              onAction: () => Navigator.pop(context),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              physics: const BouncingScrollPhysics(),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final prop = favorites[index];
                return PropertyCard(
                  property: prop,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PropertyDetailScreen(propertyId: prop.id),
                      ),
                    );
                  },
                  onFavoriteToggle: () {
                    ref.read(propertiesProvider.notifier).toggleFavorite(prop.id);
                  },
                );
              },
            ),
    );
  }
}
