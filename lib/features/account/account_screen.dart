import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../state/app_state_providers.dart';
import '../auth/login_screen.dart';
import '../calculator/land_calculator_screen.dart';
import '../requirements/buyer_requirements_screen.dart';
import 'favorites_screen.dart';
import 'notifications_screen.dart';
import 'saved_searches_screen.dart';
import 'user_leads_and_activities_screen.dart';
import 'user_requests_screen.dart';
import '../legal/legal_policy_screen.dart';
import '../../core/l10n/locale_provider.dart';

class AccountScreen extends ConsumerStatefulWidget {
  final VoidCallback? onNavigateToMyAds;

  const AccountScreen({super.key, this.onNavigateToMyAds});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(propertiesProvider.notifier).syncWithServer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(userProfileProvider);
    final favCount = profile.isLoggedIn ? ref.watch(favoritesListProvider).length : 0;
    final cleanUserPhone = profile.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final allUserAds = ref.watch(propertiesProvider).where((p) {
      if (!profile.isLoggedIn) return false;

      // 1. Strict primary match: Match by Google email
      final hasProfileEmail = profile.email.trim().isNotEmpty;
      final hasAgentEmail = p.agent.email.trim().isNotEmpty;

      if (hasProfileEmail && hasAgentEmail) {
        return p.agent.email.trim().toLowerCase() == profile.email.trim().toLowerCase();
      }

      // 2. Secondary match: Match by phone ONLY IF email does not belong to someone else
      if (cleanUserPhone.length >= 10) {
        if (hasProfileEmail && hasAgentEmail && p.agent.email.trim().toLowerCase() != profile.email.trim().toLowerCase()) {
          return false;
        }
        final userSuffix = cleanUserPhone.substring(cleanUserPhone.length - 10);
        final cleanContact = (p.contactPhone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
        final cleanAgentPhone = p.agent.phone.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanContact.length >= 10 && cleanContact.endsWith(userSuffix)) return true;
        if (cleanAgentPhone.length >= 10 && cleanAgentPhone.endsWith(userSuffix)) return true;
      }

      return false;
    }).toList();

    final myTotalCount = allUserAds.length;
    final myApprovedCount = allUserAds.where((p) => p.status.toLowerCase() == 'active' || p.status.toLowerCase() == 'published').length;
    final myPendingCount = allUserAds.where((p) => p.status.toLowerCase() == 'pending').length;
    final myRejectedCount = allUserAds.where((p) => p.status.toLowerCase() == 'rejected').length;

    final currentLocale = ref.watch(localeProvider);
    final isTamil = currentLocale.languageCode == 'ta';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Account'),
        actions: [
          IconButton(
            icon: const Icon(Icons.login_rounded),
            tooltip: 'Google Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(propertiesProvider.notifier).syncWithServer(),
        child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Profile Header Card
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
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryMedium],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryLight, width: 3),
                        ),
                        child: Center(
                          child: Text(
                            profile.name.isNotEmpty ? profile.name[0] : 'M',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
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
                                    profile.name,
                                    style: AppTextStyles.h3.copyWith(fontSize: 18),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (profile.isVerified) ...[
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified_rounded, size: 18, color: AppColors.primary),
                                ],
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              profile.email.isNotEmpty ? profile.email : profile.phone,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                                const SizedBox(width: 3),
                                Text(
                                  profile.city,
                                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Google Sign-In / Switch Account Action Button
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_circle_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Google Login / Sign In',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Google மூலம் உள்நுழைக அல்லது கணக்கை மாற்றுக',
                                  style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),

                  if (profile.isLoggedIn) ...[
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        await ref.read(userProfileProvider.notifier).logout();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('கணக்கிலிருந்து வெற்றிகரமாக வெளியேறினீர்கள் (Signed Out)'),
                              behavior: SnackBarBehavior.floating,
                              backgroundColor: AppColors.textPrimary,
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout_rounded, color: AppColors.error, size: 16),
                            SizedBox(width: 8),
                            Text(
                              'வெளியேறு (Sign Out)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 14),

                  // Profile Completion Bar
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Profile Strength: Highly Completed',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${(profile.completionPercentage * 100).toInt()}%',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: profile.completionPercentage,
                          backgroundColor: AppColors.primaryLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Activity Section
            Text('My Real Estate Activity', style: AppTextStyles.h4),
            const SizedBox(height: 10),
            _buildGroupedCard([
              _buildSettingsTile(
                icon: Icons.holiday_village_outlined,
                title: 'My Property Listings',
                subtitle: profile.isLoggedIn
                    ? 'Total: $myTotalCount (✅ $myApprovedCount Live • ⏳ $myPendingCount Pending • ❌ $myRejectedCount Rejected)'
                    : '0 active & pending ads (உள்நுழையவும்)',
                badge: (profile.isLoggedIn && myTotalCount > 0) ? '$myTotalCount' : null,
                onTap: () {
                  if (profile.isLoggedIn) {
                    if (widget.onNavigateToMyAds != null) {
                      widget.onNavigateToMyAds!();
                    }
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(
                          onLoginSuccess: () {
                            if (widget.onNavigateToMyAds != null) {
                              widget.onNavigateToMyAds!();
                            }
                          },
                        ),
                      ),
                    );
                  }
                },
              ),
              _buildSettingsTile(
                icon: Icons.favorite_border_rounded,
                title: 'Favorite Properties',
                subtitle: profile.isLoggedIn ? '$favCount saved in wishlist' : '0 saved in wishlist (விருப்பப்பட்டியல்)',
                badge: (profile.isLoggedIn && favCount > 0) ? '$favCount' : null,
                onTap: () {
                  if (profile.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
              _buildSettingsTile(
                icon: Icons.contact_phone_rounded,
                iconColor: const Color(0xFFD97706),
                title: 'என் விளம்பரங்களை பார்த்தவர்கள் (My Leads)',
                subtitle: profile.isLoggedIn ? 'யார் உங்கள் தொடர்பு எண்ணை பார்த்தார்கள்?' : 'உள்நுழைந்து லீட்ஸ்களை பார்க்கவும்',
                onTap: () {
                  if (profile.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserLeadsAndActivitiesScreen(initialTabIndex: 0),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
              _buildSettingsTile(
                icon: Icons.history_rounded,
                iconColor: const Color(0xFF0284C7),
                title: 'நான் பார்த்த தொடர்புகள் (Unlocked Contacts)',
                subtitle: profile.isLoggedIn ? 'நீங்கள் அன்லாக் செய்த உரிமையாளர் விவரங்கள்' : 'உள்நுழைந்து விவரங்களை பார்க்கவும்',
                onTap: () {
                  if (profile.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const UserLeadsAndActivitiesScreen(initialTabIndex: 1),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
              _buildSettingsTile(
                icon: Icons.mark_email_unread_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'தொடர்பு கோரிக்கைகள் (Requests)',
                subtitle: 'உடனுக்குடன் கோரிக்கை ஒப்புதல் & ஏற்பு',
                badge: (profile.isLoggedIn && ref.watch(userRequestsProvider).received.where((r) => r.isPending).isNotEmpty)
                    ? '${ref.watch(userRequestsProvider).received.where((r) => r.isPending).length}'
                    : null,
                onTap: () {
                  if (profile.isLoggedIn) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UserRequestsScreen()),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
              ),
              _buildSettingsTile(
                icon: Icons.saved_search_rounded,
                title: 'Saved Searches & Alerts',
                subtitle: 'Custom filter notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SavedSearchesScreen()),
                  );
                },
                isLast: true,
              ),
            ]),

            const SizedBox(height: 24),

            // 2.5 Quick Tools & Community
            Text('Quick Tools & Community', style: AppTextStyles.h4),
            const SizedBox(height: 10),
            _buildGroupedCard([
              _buildSettingsTile(
                icon: Icons.calculate_rounded,
                iconColor: const Color(0xFF059669),
                title: 'Land Unit Calculator',
                subtitle: 'நில அளவை மாற்றி (Cent, Kuzhi, Acre, Hectare)',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LandCalculatorScreen()),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.people_alt_rounded,
                iconColor: const Color(0xFF9333EA),
                title: 'Buyer & Tenant Requirements',
                subtitle: 'மக்களின் தேவை (Post & Find Matching Buyers)',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BuyerRequirementsScreen()),
                  );
                },
                isLast: true,
              ),
            ]),

            const SizedBox(height: 24),

            // 3. Preferences Section
            Text('Preferences & Settings', style: AppTextStyles.h4),
            const SizedBox(height: 10),
            _buildGroupedCard([
              _buildSettingsTile(
                icon: Icons.notifications_none_rounded,
                title: 'Notification Center',
                subtitle: 'Alerts, price drops, messages',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.language_rounded,
                iconColor: const Color(0xFF2563EB),
                title: isTamil ? 'பயன்பாட்டு மொழி (App Language)' : 'App Language',
                subtitle: isTamil ? 'தமிழ் (Tamil) - மாற்ற தட்டவும்' : 'English (UK / India) - Tap to switch',
                trailingText: isTamil ? 'தமிழ்' : 'English',
                onTap: () {
                  ref.read(localeProvider.notifier).toggleLocale();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isTamil
                            ? 'App language switched to English'
                            : 'பயன்பாட்டு மொழி தமிழுக்கு மாற்றப்பட்டது',
                      ),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.currency_rupee_rounded,
                title: 'Currency Format',
                subtitle: 'Indian Lakhs & Crores (INR)',
                trailingText: '₹ INR',
                onTap: () {
                  _showToast(context, 'Default Currency: Indian Rupee (₹)');
                },
                isLast: true,
              ),
            ]),

            const SizedBox(height: 24),

            // 4. Support & About
            Text('Support & Legal', style: AppTextStyles.h4),
            const SizedBox(height: 10),
            _buildGroupedCard([
              _buildSettingsTile(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support FAQs',
                subtitle: 'Frequently asked questions',
                onTap: () {
                  _showFAQDialog(context);
                },
              ),
              _buildSettingsTile(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF0F172A),
                title: 'விதிமுறைகள் (Terms & Conditions)',
                subtitle: 'பயன்பாட்டு விதிமுறைகள் மற்றும் நிபந்தனைகள்',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalPolicyScreen(initialTabIndex: 0),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.privacy_tip_outlined,
                iconColor: const Color(0xFF059669),
                title: 'தனியுரிமைக் கொள்கை (Privacy Policy)',
                subtitle: 'Google Play Store இணக்கமான தரவுப் பாதுகாப்பு',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalPolicyScreen(initialTabIndex: 1),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.currency_rupee_rounded,
                iconColor: const Color(0xFFD97706),
                title: 'பணத்தைத் திரும்பப்பெறுதல் (Refund Policy)',
                subtitle: 'ரீஃபண்ட் மற்றும் ரத்து செய்யும் கொள்கை',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LegalPolicyScreen(initialTabIndex: 2),
                    ),
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.info_outline_rounded,
                title: 'About SamWin',
                subtitle: 'தென்காசி கனவுகள் - Land Promoters',
                onTap: () {
                  _showAboutDialog(context);
                },
                isLast: true,
              ),
            ]),

            const SizedBox(height: 24),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildGroupedCard(List<Widget> children) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String subtitle,
    String? badge,
    String? trailingText,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          ),
          title: Text(title, style: AppTextStyles.labelLarge),
          subtitle: Text(subtitle, style: AppTextStyles.bodySmall),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (trailingText != null)
                Text(
                  trailingText,
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
          onTap: onTap,
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.borderLight),
      ],
    );
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primaryDark,
      ),
    );
  }

  void _showFAQDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Help & FAQs'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Q: How does offline mode work?', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('A: All properties, chats, bookmarks, and new postings are saved directly into your device local storage. You do not need internet to search, filter, or post listings!'),
              SizedBox(height: 12),
              Text('Q: How do I post a property?', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('A: Tap "+ Post Property" on the My Ads tab and complete the 8-step wizard form.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/logo.png',
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'SamWin',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                height: 90,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'தென்காசி கனவுகள்',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const Text(
              'LAND PROMOTERS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.accentGold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'A modern real estate marketplace application dedicated to lands, plots, villas, and properties in Tenkasi and Tamil Nadu.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}

