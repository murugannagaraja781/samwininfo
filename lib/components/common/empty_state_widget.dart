import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class EmptyStateWidget extends ConsumerWidget {
  const EmptyStateWidget({
    super.key,
    this.title,
    this.subtitle,
    this.buttonText,
    this.onAction,
    this.icon = Icons.search_off_rounded,
  });

  final String? title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onAction;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title ?? ref.tr('sec_no_properties'),
              textAlign: TextAlign.center,
              style: AppTextStyles.h4.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle ?? ref.tr('sec_try_another'),
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText ?? ref.tr('sec_show_all'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
