import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StepDetails extends ConsumerWidget {
  const StepDetails({
    super.key,
    required this.titleController,
    required this.descController,
    required this.selectedFacing,
    required this.onFacingSelected,
    required this.isDtcpVerified,
    required this.onDtcpToggled,
  });

  final TextEditingController titleController;
  final TextEditingController descController;
  final String selectedFacing;
  final ValueChanged<String> onFacingSelected;
  final bool isDtcpVerified;
  final ValueChanged<bool> onDtcpToggled;

  static const List<String> facingDirections = [
    'North',
    'East',
    'South',
    'West',
    'North-East',
    'South-East',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTamil = ref.watch(localeProvider).languageCode == 'ta';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ref.tr('step_details'),
            style: AppTextStyles.h2.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isTamil
                ? 'உங்கள் நிலம் அல்லது சொத்தின் தலைப்பு மற்றும் முக்கிய சிறப்பம்சங்களை உள்ளிடவும்'
                : 'Enter a clear title and description highlighting the unique features',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 22),

          // Title field
          Text(
            ref.tr('field_title'),
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: titleController,
            decoration: InputDecoration(
              hintText: ref.tr('field_title_hint'),
              prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(height: 18),

          // Facing Direction selector chips
          Text(
            ref.tr('field_facing'),
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: facingDirections.map((dir) {
              final isSelected = selectedFacing == dir;
              return ChoiceChip(
                label: Text(dir),
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
                  fontSize: 12.5,
                ),
                onSelected: (selected) {
                  if (selected) onFacingSelected(dir);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 18),

          // DTCP Verified Switch Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDtcpVerified ? AppColors.primaryLight : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDtcpVerified ? AppColors.primary : AppColors.border,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: isDtcpVerified ? AppColors.primary : AppColors.textMuted,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ref.tr('dtcp_verified_label'),
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDtcpVerified ? AppColors.primaryDark : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        isTamil
                            ? 'அரசுDTCP/RERA மனைப்பிரிவு ஒப்புதல் பெற்ற சொத்து'
                            : 'Has approved layout / RERA registration',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDtcpVerified,
                  activeThumbColor: AppColors.primary,
                  onChanged: onDtcpToggled,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Description field
          Text(
            ref.tr('field_desc'),
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: descController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: ref.tr('field_desc_hint'),
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}
