import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class StepContact extends ConsumerWidget {
  const StepContact({
    super.key,
    required this.locationController,
    required this.sellerNameController,
    required this.phoneController,
    required this.selectedPhotoIndex,
    required this.onPhotoSelected,
  });

  final TextEditingController locationController;
  final TextEditingController sellerNameController;
  final TextEditingController phoneController;
  final int selectedPhotoIndex;
  final ValueChanged<int> onPhotoSelected;

  static const List<String> popularTenkasiAreas = [
    'Surandai Road, Tenkasi',
    'Pavoorchatram, Tenkasi',
    'Courtallam Main Road',
    'Shenkottai Road',
    'Tenkasi Old Bus Stand',
    'Kadayanallur Highway',
    'Alangulam Bypass',
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
            ref.tr('step_contact'),
            style: AppTextStyles.h2.copyWith(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isTamil
                ? 'விற்பனையாளர் விவரங்கள் மற்றும் தென்காசி நிலப்பகுதியை உள்ளிடவும்'
                : 'Provide your contact details so verified buyers can reach out directly',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 22),

          // Locality / Area in Tenkasi
          Text(
            ref.tr('field_location'),
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: locationController,
            decoration: InputDecoration(
              hintText: ref.tr('field_location_hint'),
              prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(height: 10),

          // Quick locality suggestion pills
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: popularTenkasiAreas.map((loc) {
              return ActionChip(
                label: Text(loc.split(',').first),
                backgroundColor: AppColors.surfaceAlt,
                side: const BorderSide(color: AppColors.border),
                labelStyle: const TextStyle(fontSize: 11, color: AppColors.primaryDark),
                onPressed: () {
                  locationController.text = loc;
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Seller Name
          Text(
            ref.tr('field_seller_name'),
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: sellerNameController,
            decoration: const InputDecoration(
              hintText: 'e.g., Murugan / Nagaraj',
              prefixIcon: Icon(Icons.person_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(height: 20),

          // Phone Number
          Text(
            ref.tr('field_phone'),
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: ref.tr('field_phone_hint'),
              prefixText: '+91 ',
              prefixIcon: const Icon(Icons.phone_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          const SizedBox(height: 22),

          // Photos Card / Selector
          Text(
            isTamil ? 'சொத்து புகைப்படத் தோற்றம்' : 'Property Cover Visual Style',
            style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, idx) {
                final isSelected = selectedPhotoIndex == idx;
                return GestureDetector(
                  onTap: () => onPhotoSelected(idx),
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : AppColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_library_rounded,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                          size: 26,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Style ${idx + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // Safety & Guidelines Notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.security_rounded, color: AppColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isTamil
                        ? 'உங்கள் விளம்பரம் உடனடியாக சரிபார்க்கப்பட்டு முகப்பு பக்கத்தில் தோன்றும்.'
                        : 'Your ad will be verified and published instantly on SamWin.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
