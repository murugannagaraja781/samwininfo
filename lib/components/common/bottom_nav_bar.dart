import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';

class BottomNavBar extends ConsumerWidget {
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onPostAdTap,
    this.unreadChatsCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onPostAdTap;
  final int unreadChatsCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // 1. Home Tab
              _buildTabItem(
                ref: ref,
                index: 0,
                label: ref.tr('nav_home'),
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
              ),

              // 2. Chats Tab
              _buildTabItem(
                ref: ref,
                index: 1,
                label: ref.tr('nav_chats'),
                icon: Icons.chat_bubble_outline_rounded,
                activeIcon: Icons.chat_bubble_rounded,
                badgeCount: unreadChatsCount,
              ),

              // 3. Center Prominent "POST AD" Button — Blue solid circle
              GestureDetector(
                onTap: onPostAdTap,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1565C0), Color(0xFF1976D2)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      SizedBox(
                        width: 70,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            ref.tr('nav_sell'),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 4. My Ads Tab
              _buildTabItem(
                ref: ref,
                index: 2,
                label: ref.tr('nav_my_ads'),
                icon: Icons.article_outlined,
                activeIcon: Icons.article_rounded,
              ),

              // 5. Account Tab
              _buildTabItem(
                ref: ref,
                index: 3,
                label: ref.tr('nav_account'),
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required WidgetRef ref,
    required int index,
    required String label,
    required IconData icon,
    required IconData activeIcon,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 23,
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -3,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$badgeCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
