import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/property_visual.dart';
import '../../models/property.dart';
import '../../state/app_state_providers.dart';
import '../auth/login_screen.dart';
import '../post_property/post_property_wizard.dart';
import '../property_detail/property_detail_screen.dart';
import 'edit_property_screen.dart';

class MyAdsScreen extends ConsumerStatefulWidget {
  const MyAdsScreen({super.key});

  @override
  ConsumerState<MyAdsScreen> createState() => _MyAdsScreenState();
}

class _MyAdsScreenState extends ConsumerState<MyAdsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['All', 'Active', 'Pending', 'Rejected', 'Sold'];

  void _handlePostAdClick() {
    final user = ref.read(userProfileProvider);
    if (!user.isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            onLoginSuccess: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PostPropertyWizard()),
              );
            },
          ),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostPropertyWizard()),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(propertiesProvider.notifier).syncWithServer();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfile = ref.watch(userProfileProvider);
    final cleanUserPhone = userProfile.phone.replaceAll(RegExp(r'[^0-9]'), '');
    final myAds = ref.watch(propertiesProvider).where((p) {
      if (!userProfile.isLoggedIn) return false;

      // 1. Strict primary match: Match by Google email
      final hasProfileEmail = userProfile.email.trim().isNotEmpty;
      final hasAgentEmail = p.agent.email.trim().isNotEmpty;

      if (hasProfileEmail && hasAgentEmail) {
        return p.agent.email.trim().toLowerCase() == userProfile.email.trim().toLowerCase();
      }

      // 2. Secondary match: Match by phone ONLY IF email does not belong to someone else
      if (cleanUserPhone.length >= 10) {
        if (hasProfileEmail && hasAgentEmail && p.agent.email.trim().toLowerCase() != userProfile.email.trim().toLowerCase()) {
          return false;
        }
        final userSuffix = cleanUserPhone.substring(cleanUserPhone.length - 10);
        final cleanContact = (p.contactPhone ?? '').replaceAll(RegExp(r'[^0-9]'), '');
        final cleanAgentPhone = p.agent.phone.replaceAll(RegExp(r'[^0-9]'), '');
        if (cleanContact.length >= 10 && cleanContact.endsWith(userSuffix)) {
          return true;
        }
        if (cleanAgentPhone.length >= 10 && cleanAgentPhone.endsWith(userSuffix)) {
          return true;
        }
      }

      return false;
    }).toList();

    // Stats calculations
    final activeCount = myAds.where((p) => p.status.toLowerCase() == 'active' || p.status.toLowerCase() == 'published').length;
    final pendingCount = myAds.where((p) => p.status.toLowerCase() == 'pending').length;
    final rejectedCount = myAds.where((p) => p.status.toLowerCase() == 'rejected').length;
    final soldCount = myAds.where((p) => p.status.toLowerCase() == 'sold').length;
    final totalViews = myAds.fold<int>(0, (sum, p) => sum + p.views);
    final totalEnquiries = myAds.fold<int>(0, (sum, p) => sum + p.enquiries);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('எனது விளம்பரங்கள் (My Ads)'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTextStyles.labelLarge,
          isScrollable: true,
          tabs: [
            Tab(text: 'அனைத்தும் (${myAds.length})'),
            Tab(text: 'நேரலை ($activeCount)'),
            Tab(text: 'காத்திருப்பு ($pendingCount)'),
            Tab(text: 'நிராகரிப்பு ($rejectedCount)'),
            Tab(text: 'விற்பனை ($soldCount)'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handlePostAdClick,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded, size: 22),
        label: const Text(
          'Post Property',
          style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),
      body: !userProfile.isLoggedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock_person_rounded, size: 56, color: AppColors.primary),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'உங்கள் விளம்பரங்களை காண உள்நுழையவும்',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Sign in with your Google account to view, manage, and edit your property listings.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.login_rounded, size: 20),
                      label: const Text('Google Login / உள்நுழைக', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await ref.read(propertiesProvider.notifier).syncWithServer();
              },
              child: Column(
                children: [
                  // Dashboard Summary Banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(bottom: BorderSide(color: AppColors.borderLight)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Total Listings', '${myAds.length}', Icons.apartment_rounded),
                        _buildDivider(),
                        _buildStatItem('Total Views', '$totalViews', Icons.visibility_outlined),
                        _buildDivider(),
                        _buildStatItem('Total Enquiries', '$totalEnquiries', Icons.chat_bubble_outline_rounded),
                      ],
                    ),
                  ),

                  // Tab Views (5 Tabs: All, Approved, Pending, Rejected, Sold)
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAdsList(myAds, 'all'),
                        _buildAdsList(myAds.where((p) => p.status.toLowerCase() == 'active' || p.status.toLowerCase() == 'published').toList(), 'active'),
                        _buildAdsList(myAds.where((p) => p.status.toLowerCase() == 'pending').toList(), 'pending'),
                        _buildAdsList(myAds.where((p) => p.status.toLowerCase() == 'rejected').toList(), 'rejected'),
                        _buildAdsList(myAds.where((p) => p.status.toLowerCase() == 'sold').toList(), 'sold'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: AppTextStyles.h4.copyWith(fontSize: 16, color: AppColors.textPrimary)),
            Text(label, style: AppTextStyles.labelSmall.copyWith(fontSize: 10, color: AppColors.textMuted)),
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 28, color: AppColors.borderLight);
  }

  Widget _buildAdsList(List<Property> ads, String tabType) {
    if (ads.isEmpty) {
      String title = 'No $tabType listings';
      String msg = tabType == 'active'
          ? 'You do not have any active ads right now. Post your property in 2 minutes!'
          : 'No properties currently in $tabType status.';

      return EmptyStateView(
        icon: Icons.holiday_village_outlined,
        title: title,
        message: msg,
        actionText: '+ புதிய விளம்பரம் பதிவு செய்',
        onAction: _handlePostAdClick,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
      physics: const BouncingScrollPhysics(),
      itemCount: ads.length,
      itemBuilder: (context, index) {
        final ad = ads[index];
        return _buildUserAdCard(ad);
      },
    );
  }

  Widget _buildUserAdCard(Property ad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border, width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        children: [
          // Top row: thumbnail + details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                PropertyVisual(
                  propertyType: ad.propertyType,
                  customImageBase64: ad.customImageBase64,
                  imageUrl: ad.primaryImageUrl,
                  width: 95,
                  height: 95,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 14),
                // Title, Price, Location, Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatusBadge(ad.status),
                          Text(
                            ad.propertyType,
                            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        ad.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.h4.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyFormatter.formatIndianPrice(ad.price, isRental: ad.isRental),
                        style: AppTextStyles.priceMedium.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              ad.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Stats Bar: Views & Enquiries
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.surfaceAlt,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.remove_red_eye_outlined, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text('${ad.views} Views', style: AppTextStyles.labelSmall),
                    const SizedBox(width: 14),
                    const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text('${ad.enquiries} Enquiries', style: AppTextStyles.labelSmall),
                  ],
                ),
                Text(
                  'ID: ${ad.id.split('_').last}',
                  style: AppTextStyles.labelSmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.borderLight),

          // Actions Row: Preview, Edit, Mark as Sold, Delete
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Preview
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PropertyDetailScreen(propertyId: ad.id)),
                    );
                  },
                  icon: const Icon(Icons.visibility_outlined, size: 16),
                  label: const Text('Preview'),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),

                // Edit
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditPropertyScreen(property: ad)),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                ),

                // Mark Sold
                if (ad.status != 'sold')
                  TextButton.icon(
                    onPressed: () => _confirmMarkSold(ad),
                    icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppColors.warning),
                    label: Text('Sold', style: TextStyle(color: AppColors.warning, fontSize: 13)),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),

                // Delete
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.error),
                  tooltip: 'Delete Ad',
                  onPressed: () => _confirmDelete(ad),
                ),
              ],
            ),
          ),

          // Prominent Processing / Under Review notice for Pending ads
          if (ad.status.toLowerCase() == 'pending') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFFBEB),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border(top: BorderSide(color: Color(0xFFFDE68A))),
              ),
              child: const Row(
                children: [
                  Icon(Icons.hourglass_top_rounded, size: 16, color: Color(0xFFD97706)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '⏳ காத்திருப்பு (Waiting for Approval): Super Admin சரிபார்த்தவுடன் உங்கள் விளம்பரம் நேரலையாக தோன்றும்.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Prominent notice for Rejected ads
          if (ad.status.toLowerCase() == 'rejected') ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEF2F2),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border(top: BorderSide(color: Color(0xFFFECACA))),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cancel_rounded, size: 16, color: Color(0xFFDC2626)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '❌ இந்த விளம்பரம் Super Admin-ஆல் நிராகரிக்கப்பட்டது. திருத்தி மீண்டும் சமர்ப்பிக்கவும்.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF991B1B), fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status.toLowerCase()) {
      case 'active':
      case 'published':
        bg = const Color(0xFFDCFCE7);
        text = const Color(0xFF16A34A);
        label = '✅ ஒப்புதல் (Approved)';
        break;
      case 'pending':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFFD97706);
        label = '⏳ காத்திருப்பு (Pending)';
        break;
      case 'rejected':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFFDC2626);
        label = '❌ நிராகரிப்பு (Rejected)';
        break;
      case 'sold':
        bg = const Color(0xFFECEFF1);
        text = const Color(0xFF455A64);
        label = '🏷️ விற்பனையானது (Sold)';
        break;
      default:
        bg = AppColors.surfaceAlt;
        text = AppColors.textSecondary;
        label = 'வரைவு (Draft)';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: text.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: text, fontSize: 10.5, fontWeight: FontWeight.w800),
      ),
    );
  }

  void _confirmMarkSold(Property ad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Mark as Sold/Rented?'),
        content: Text('Are you sure you want to mark "${ad.title}" as Sold? It will be moved to the Sold tab.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(propertiesProvider.notifier).markAsSold(ad.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Listing marked as Sold!'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Confirm Sold'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Property ad) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Delete Listing?'),
        content: Text('This will remove "${ad.title}" permanently from your local device listings.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(propertiesProvider.notifier).deleteProperty(ad.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Property deleted from device storage.'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
