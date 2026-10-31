import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../features/search/filter_bottom_sheet.dart';
import '../../features/search/search_screen.dart';

class PropertySearchBar extends ConsumerWidget {
  const PropertySearchBar({
    super.key,
    this.onTap,
    this.readOnly = true,
    this.controller,
    this.onChanged,
  });

  final VoidCallback? onTap;
  final bool readOnly;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: readOnly
              ? () {
                  if (onTap != null) {
                    onTap!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  }
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                const Icon(
                  Icons.search_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: readOnly
                      ? Text(
                          ref.tr('search_placeholder'),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 13.5,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : TextField(
                          controller: controller,
                          onChanged: onChanged,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: ref.tr('search_placeholder'),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          style: AppTextStyles.bodyMedium,
                        ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => FilterBottomSheet.show(context),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      size: 17,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
