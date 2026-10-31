import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/location_service.dart';
import '../../state/app_state_providers.dart';

class LocationDialog extends ConsumerStatefulWidget {
  const LocationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationDialog(),
    );
  }

  @override
  ConsumerState<LocationDialog> createState() => _LocationDialogState();
}

class _LocationDialogState extends ConsumerState<LocationDialog> {
  bool _isDetecting = false;

  Future<void> _detectLiveLocation() async {
    setState(() => _isDetecting = true);

    try {
      final result = await LocationService.getCurrentLiveLocation(context: context);

      if (!mounted) return;

      final area = result.estimatedArea.isNotEmpty ? result.estimatedArea : 'Tenkasi';
      final fullLoc = '$area, ${result.estimatedCity.isNotEmpty ? result.estimatedCity : "Tamil Nadu"}';

      // Update state
      ref.read(selectedLocationProvider.notifier).setLocation(fullLoc);
      ref.read(userLocationProvider.notifier).setLiveLocation(result);
      ref.read(localStorageServiceProvider).setCurrentLocation(fullLoc);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  result.isLiveGps
                      ? '📍 நேரலை இடம்: $area கண்டறியப்பட்டது!'
                      : '📍 இருப்பிடம்: $area தேர்ந்தெடுக்கப்பட்டது!',
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('GPS கண்டறிய முடியவில்லை: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDetecting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocation = ref.watch(selectedLocationProvider);
    final userLoc = ref.watch(userLocationProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('இருப்பிடம் தேர்வு (Select Location)', style: AppTextStyles.h3.copyWith(fontSize: 18)),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, size: 20),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'உங்கள் அருகிலுள்ள சொத்துக்களை கண்டறிய நேரலை GPS அல்லது ஊரை தேர்வு செய்யவும்',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.3),
          ),
          const SizedBox(height: 16),

          // 1. Prominent Live GPS Location Button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isDetecting ? null : _detectLiveLocation,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isDetecting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Icon(Icons.my_location_rounded, color: Colors.white, size: 22),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'தற்போதைய இடம் கண்டறி',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'LIVE GPS',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            userLoc.isLiveGps
                                ? 'தற்போது: ${userLoc.areaName} (நேரலையில் இணைக்கப்பட்டுள்ளது)'
                                : 'உங்கள் மொபைல் GPS மூலம் அருகிலுள்ள சொத்துக்களை வரிசைப்படுத்தும்',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 16),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),

          const Text(
            'பிரபலமான பகுதிகள் (Popular Towns)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Popular Towns List
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.40,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: AppConstants.popularLocations.length,
              separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
              itemBuilder: (context, index) {
                final loc = AppConstants.popularLocations[index];
                final isSelected = loc == currentLocation;
                final townShort = loc.split(',').first.trim();

                // Calculate distance if user coords known
                String? distText;
                if (userLoc.latitude != null && userLoc.longitude != null) {
                  final coords = LocationService.getCoordinatesForTown(townShort);
                  if (coords != null) {
                    final dist = LocationService.calculateDistanceKm(
                      userLoc.latitude!,
                      userLoc.longitude!,
                      coords['lat']!,
                      coords['lng']!,
                    );
                    if (dist < 100) {
                      distText = dist < 1.0 ? '${(dist * 1000).round()} m' : '${dist.toStringAsFixed(1)} km';
                    }
                  }
                }

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryLight : AppColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 18,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        loc,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (distText != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            distText,
                            style: const TextStyle(
                              color: Color(0xFF2563EB),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22)
                      : null,
                  onTap: () {
                    ref.read(selectedLocationProvider.notifier).setLocation(loc);
                    ref.read(userLocationProvider.notifier).setManualLocation(loc);
                    ref.read(localStorageServiceProvider).setCurrentLocation(loc);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
