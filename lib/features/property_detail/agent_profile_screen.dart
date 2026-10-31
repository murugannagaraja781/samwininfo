import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/property_card.dart';
import '../../models/agent.dart';
import '../../state/app_state_providers.dart';
import 'property_detail_screen.dart';

class AgentProfileScreen extends ConsumerWidget {
  final Agent agent;

  const AgentProfileScreen({super.key, required this.agent});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(propertyRepositoryProvider);
    ref.watch(propertiesProvider); // for favorites reactivity
    final agentProperties = repo.getPropertiesByAgent(agent.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Agent Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agent Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1),
                boxShadow: AppColors.cardShadow,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryMedium],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryLight, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            agent.name.isNotEmpty ? agent.name[0] : 'A',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    agent.name,
                                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (agent.isVerified) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified_rounded, size: 18, color: AppColors.primary),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              agent.agencyName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, size: 16, color: AppColors.accentGold),
                                const SizedBox(width: 3),
                                Text(
                                  '${agent.rating} (${agent.reviewsCount} reviews)',
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 16),
                  // Stats Grid
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatColumn('Experience', '${agent.experienceYears} Years'),
                      _buildDivider(),
                      _buildStatColumn('Listings', '${agent.totalListings}+'),
                      _buildDivider(),
                      _buildStatColumn('Rating', '${agent.rating} ★'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            Text('About Agent', style: AppTextStyles.h4),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Text(
                agent.about,
                style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
              ),
            ),

            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Properties by ${agent.name}', style: AppTextStyles.h4),
                Text(
                  '${agentProperties.length} active',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (agentProperties.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    'No active public listings currently.',
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: agentProperties.length,
                itemBuilder: (context, index) {
                  final prop = agentProperties[index];
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
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.h4.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTextStyles.labelSmall),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 28, color: AppColors.borderLight);
  }
}
