import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../state/app_state_providers.dart';
import '../property_detail/property_detail_screen.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark All Read'),
            ),
          const SizedBox(width: 6),
        ],
      ),
      body: notifications.isEmpty
          ? const EmptyStateView(
              icon: Icons.notifications_none_rounded,
              title: 'No Notifications',
              message: 'You are all caught up! Updates regarding your ads and enquiries will appear here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return InkWell(
                  onTap: () {
                    ref.read(notificationsProvider.notifier).markAsRead(notif.id);
                    if (notif.propertyId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PropertyDetailScreen(propertyId: notif.propertyId!),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: notif.isRead ? AppColors.surface : AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: notif.isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTypeIcon(notif.type),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: AppTextStyles.h4.copyWith(
                                        fontSize: 15,
                                        fontWeight: notif.isRead ? FontWeight.w600 : FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    DateFormatter.timeAgo(notif.timestamp),
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.message,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: notif.isRead ? AppColors.textSecondary : AppColors.textPrimary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (!notif.isRead)
                          Container(
                            margin: const EdgeInsets.only(left: 8, top: 4),
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;

    switch (type) {
      case 'price_drop':
        icon = Icons.trending_down_rounded;
        color = const Color(0xFF2E7D32);
        break;
      case 'enquiry':
        icon = Icons.chat_rounded;
        color = AppColors.primary;
        break;
      case 'ad_approved':
        icon = Icons.check_circle_rounded;
        color = AppColors.accentGold;
        break;
      default:
        icon = Icons.notifications_rounded;
        color = AppColors.accentBlue;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
