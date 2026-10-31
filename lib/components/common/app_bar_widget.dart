import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../features/account/favorites_screen.dart';
import '../../features/account/notifications_screen.dart';
import '../../features/home/location_dialog.dart';
import '../../features/search/search_screen.dart';
import '../../core/utils/location_service.dart';
import '../../state/app_state_providers.dart';

class AppBarWidget extends ConsumerWidget {
  const AppBarWidget({super.key, this.onNavigateToSearch});

  final VoidCallback? onNavigateToSearch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(selectedLocationProvider);
    final userLoc = ref.watch(userLocationProvider);
    final unreadNotifs = ref.watch(unreadNotificationsCountProvider);

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Row 1: Logo + Location Selector
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
              child: Row(
                children: [
                  // Official Logo Image with max constraints
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 145, maxHeight: 36),
                    child: Image.asset(
                      'assets/images/app_logo.png',
                      height: 36,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.terrain_rounded, color: AppColors.primary, size: 22),
                            const SizedBox(width: 4),
                            Text(
                              ref.tr('app_title_ta'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0D47A1),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Vertical thin divider
                  Container(
                    height: 20,
                    width: 1,
                    color: const Color(0xFFCBD5E1),
                  ),

                  const SizedBox(width: 4),

                  // Location Pin & Dropdown (Flexible with ellipsis so it NEVER overflows!)
                  Expanded(
                    child: InkWell(
                      onTap: () => LocationDialog.show(context),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              userLoc.isLiveGps ? Icons.my_location_rounded : Icons.location_on,
                              size: 16,
                              color: userLoc.isLiveGps ? const Color(0xFF10B981) : const Color(0xFF1565C0),
                            ),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                userLoc.areaName.isNotEmpty
                                    ? userLoc.areaName
                                    : (location.isNotEmpty
                                        ? location.split(',').first.trim()
                                        : ref.tr('location_default')),
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (userLoc.isLiveGps) ...[
                              const SizedBox(width: 3),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(color: const Color(0xFF86EFAC), width: 0.8),
                                ),
                                child: const Text(
                                  'LIVE',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ],
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: Color(0xFF0F172A),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Language Switcher Toggle Pill (தமிழ் / English)
                  InkWell(
                    onTap: () {
                      ref.read(localeProvider.notifier).toggleLocale();
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: ref.isTamil
                              ? [const Color(0xFF1E3A8A), const Color(0xFF2563EB)]
                              : [const Color(0xFF065F46), const Color(0xFF059669)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: (ref.isTamil ? const Color(0xFF2563EB) : const Color(0xFF059669)).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.language_rounded, size: 12, color: Colors.white),
                          const SizedBox(width: 3),
                          Text(
                            ref.isTamil ? 'தமிழ்' : 'Eng',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Row 2: Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 2, 14, 12),
            child: GestureDetector(
              onTap: () {
                if (onNavigateToSearch != null) {
                  onNavigateToSearch!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                }
              },
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF1E293B),
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ref.tr('search_placeholder'),
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Divider before action icons
                    Container(
                      width: 1,
                      height: 22,
                      color: const Color(0xFFE2E8F0),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                    ),

                    // Voice Search
                    GestureDetector(
                      onTap: () {
                        if (onNavigateToSearch != null) {
                          onNavigateToSearch!();
                        }
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          Icons.mic_none_rounded,
                          color: Color(0xFF1565C0),
                          size: 22,
                        ),
                      ),
                    ),

                    // Favorites
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          Icons.favorite_border_rounded,
                          color: Color(0xFF1E293B),
                          size: 22,
                        ),
                      ),
                    ),

                    // Notifications with red dot badge
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                        );
                      },
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            child: Icon(
                              Icons.notifications_none_rounded,
                              color: Color(0xFF1E293B),
                              size: 22,
                            ),
                          ),
                          if (unreadNotifs > 0)
                            Positioned(
                              top: 1,
                              right: 5,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE53935),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Row 3: GPS Location Quick Search & Area Chips (Below Search Box)
          Container(
            height: 38,
            margin: const EdgeInsets.only(bottom: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              children: [
                // 1. Live GPS Location Detector Button
                InkWell(
                  onTap: () async {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Row(
                          children: [
                            SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text('📍 GPS மூலம் நேரலை இருப்பிடம் பெறப்படுகிறது...'),
                            ),
                          ],
                        ),
                        duration: Duration(seconds: 4),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    final loc = await LocationService.getCurrentLiveLocation(context: context);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    if (loc.isLiveGps) {
                      ref.read(userLocationProvider.notifier).setLiveLocation(loc);
                      final area = loc.estimatedArea.isNotEmpty ? loc.estimatedArea : loc.estimatedCity;
                      if (area.isNotEmpty) {
                        ref.read(selectedLocationProvider.notifier).setLocation('$area, ${loc.estimatedCity}');
                        ref.read(localStorageServiceProvider).setCurrentLocation('$area, ${loc.estimatedCity}');
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text('✅ நேரலை GPS: $area (${loc.formattedCoordinates})'),
                              ),
                            ],
                          ),
                          backgroundColor: const Color(0xFF2E7D32),
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else if (loc.error != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('⚠️ ${loc.error}'),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF4CAF50), width: 1.2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4CAF50).withValues(alpha: 0.18),
                          blurRadius: 4,
                          offset: const Offset(0, 1.5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.my_location_rounded, size: 11, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '📍 GPS என் இடம்',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // 2. Tenkasi Location Chips
                ...[
                  'தென்காசி',
                  'குற்றாலம்',
                  'செங்கோட்டை',
                  'சுரண்டை',
                  'கடையநல்லூர்',
                  'இலஞ்சி',
                  'பாவூர்சத்திரம்',
                  'அனைத்து இடங்கள்',
                ].map((loc) {
                  final isSelected = (loc == 'அனைத்து இடங்கள்' && location.isEmpty) ||
                      (loc != 'அனைத்து இடங்கள்' && location.contains(loc));

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () {
                        if (loc == 'அனைத்து இடங்கள்') {
                          ref.read(selectedLocationProvider.notifier).setLocation('');
                          ref.read(userLocationProvider.notifier).setManualLocation('');
                        } else {
                          ref.read(selectedLocationProvider.notifier).setLocation('$loc, Tenkasi');
                          ref.read(userLocationProvider.notifier).setManualLocation(loc);
                        }
                      },
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF0D47A1) : const Color(0xFFCBD5E1),
                            width: 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF0D47A1).withValues(alpha: 0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1.5),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 13,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              loc,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                color: isSelected ? Colors.white : const Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
