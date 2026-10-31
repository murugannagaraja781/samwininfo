import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../core/config/api_config.dart';
import '../../core/theme/app_colors.dart';
import '../../state/app_state_providers.dart';

class UserLeadsAndActivitiesScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const UserLeadsAndActivitiesScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<UserLeadsAndActivitiesScreen> createState() => _UserLeadsAndActivitiesScreenState();
}

class _UserLeadsAndActivitiesScreenState extends ConsumerState<UserLeadsAndActivitiesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  List<dynamic> _myLeads = []; // Buyers who viewed my ads
  List<dynamic> _myViewedContacts = []; // Contacts I unlocked/viewed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final user = ref.read(userProfileProvider);
    final userPhone = user.phone.trim();
    final userEmail = user.email.trim();
    final baseUrl = ApiConfig.instance.serverUrl;

    if (!user.isLoggedIn || (userPhone.isEmpty && userEmail.isEmpty)) {
      if (mounted) {
        setState(() {
          _myLeads = [];
          _myViewedContacts = [];
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cleanUserP = userPhone.replaceAll(RegExp(r'[^0-9]'), '');

      // 1. Fetch leads on my properties
      final leadsUri = Uri.parse('$baseUrl/activities.php?seller_phone=${Uri.encodeComponent(cleanUserP)}&seller_email=${Uri.encodeComponent(userEmail)}');
      final leadsRes = await http.get(leadsUri).timeout(const Duration(seconds: 5));
      if (leadsRes.statusCode == 200) {
        final data = jsonDecode(leadsRes.body);
        if (data['success'] == true) {
          _myLeads = data['activities'] ?? [];
        }
      }

      // 2. Fetch contacts I viewed
      final myUri = Uri.parse('$baseUrl/activities.php?user_phone=${Uri.encodeComponent(cleanUserP)}&user_email=${Uri.encodeComponent(userEmail)}');
      final myRes = await http.get(myUri).timeout(const Duration(seconds: 5));
      if (myRes.statusCode == 200) {
        final data = jsonDecode(myRes.body);
        if (data['success'] == true) {
          _myViewedContacts = data['activities'] ?? [];
        }
      }
    } catch (e) {
      debugPrint('Activities fetch error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _makeCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('அழைக்க இயலவில்லை: $phone')),
        );
      }
    }
  }

  Future<void> _openWhatsApp(String phone, String name, String propTitle) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = Uri.encodeComponent('வணக்கம் $name, தென்காசி கனவுகள் ஆப் மூலம் நீங்கள் பார்த்த "$propTitle" சொத்து தொடர்பாக பேச அழைக்கிறேன்.');
    final uri = Uri.parse('https://wa.me/91$clean?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WhatsApp திறக்க முடியவில்லை: $phone')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('செயல்பாடுகள் & லீட்ஸ் (Leads)'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(
              icon: const Icon(Icons.contact_phone_rounded, size: 20),
              text: 'என் விளம்பரங்களை பார்த்தவர்கள் (${_myLeads.length})',
            ),
            Tab(
              icon: const Icon(Icons.history_rounded, size: 20),
              text: 'நான் பார்த்த தொடர்புகள் (${_myViewedContacts.length})',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMyLeadsTab(),
                _buildMyViewedContactsTab(),
              ],
            ),
    );
  }

  // --- TAB 1: Buyers Who Viewed My Ads ---
  Widget _buildMyLeadsTab() {
    if (_myLeads.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 60),
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_outline_rounded, size: 48, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'விளம்பரங்களை யாரும் இன்னும் பார்க்கவில்லை',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'நீங்கள் பதிவிட்ட விளம்பரங்களின் தொடர்பு எண்களை வாங்குபவர்கள் திறக்கும்போது, அவர்களின் பெயர் மற்றும் போன் நம்பர் இங்கே தோன்றும்.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myLeads.length,
        itemBuilder: (context, index) {
          final item = _myLeads[index];
          final buyerName = item['user_name'] ?? item['userName'] ?? 'வாடிக்கையாளர் (Buyer)';
          final buyerPhone = item['user_phone'] ?? item['userPhone'] ?? '';
          final buyerEmail = item['user_email'] ?? item['userEmail'] ?? '';
          final propTitle = item['property_title'] ?? item['propertyTitle'] ?? 'சொத்து விவரம்';
          final propLocation = item['property_location'] ?? item['propertyLocation'] ?? 'Tenkasi';
          final dateStr = item['created_at'] ?? item['createdAt'] ?? '';
          final actType = item['action_type'] ?? item['actionType'] ?? '';

          final isPaid = actType == 'contact_unlock_paid';

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isPaid ? const Color(0xFFFDE68A) : AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid ? const Color(0xFFFEF3C7) : const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPaid ? Icons.monetization_on_rounded : Icons.lock_open_rounded,
                            size: 13,
                            color: isPaid ? const Color(0xFFD97706) : const Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPaid ? 'கட்டண தொடர்பு (Paid ₹30)' : 'இலவச தொடர்பு திறப்பு',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isPaid ? const Color(0xFFB45309) : const Color(0xFF0369A1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr,
                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Buyer Information
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          buyerName.isNotEmpty ? buyerName[0] : 'B',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buyerName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            buyerPhone.isNotEmpty ? buyerPhone : 'செல்போன் எண் பதிவாகவில்லை',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary),
                          ),
                          if (buyerEmail.isNotEmpty) ...[
                            const SizedBox(height: 1),
                            Text(
                              buyerEmail,
                              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ]
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Viewed Property Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.home_work_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '$propTitle ($propLocation)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Quick Connect Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: buyerPhone.isNotEmpty ? () => _makeCall(buyerPhone) : null,
                        icon: const Icon(Icons.call_rounded, size: 16, color: AppColors.primary),
                        label: const Text('அழைக்க (Call)'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: buyerPhone.isNotEmpty ? () => _openWhatsApp(buyerPhone, buyerName, propTitle) : null,
                        icon: const Icon(Icons.chat_rounded, size: 16, color: Colors.white),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- TAB 2: Contacts I Viewed / Unlocked ---
  Widget _buildMyViewedContactsTab() {
    if (_myViewedContacts.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 60),
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.remove_red_eye_outlined, size: 48, color: Color(0xFF3B82F6)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'தொடர்புகள் எதுவும் இன்னும் பார்க்கவில்லை',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'நீங்கள் ஏதேனும் சொத்தின் உரிமையாளர் எண்ணை திறக்கும்போது அல்லது அழைக்கும்போது, அந்த விவரங்கள் இங்கே சேமிக்கப்படும்.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _myViewedContacts.length,
        itemBuilder: (context, index) {
          final item = _myViewedContacts[index];
          final sellerName = item['seller_name'] ?? item['sellerName'] ?? 'உரிமையாளர் (Owner)';
          final sellerPhone = item['seller_phone'] ?? item['sellerPhone'] ?? '';
          final propTitle = item['property_title'] ?? item['propertyTitle'] ?? 'சொத்து விவரம்';
          final propLocation = item['property_location'] ?? item['propertyLocation'] ?? 'Tenkasi';
          final dateStr = item['created_at'] ?? item['createdAt'] ?? '';

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      propTitle,
                      style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    ),
                    Text(
                      dateStr.length >= 10 ? dateStr.substring(0, 10) : dateStr,
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '📍 $propLocation',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_pin_rounded, color: AppColors.primary, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sellerName,
                              style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF065F46)),
                            ),
                            Text(
                              sellerPhone.isNotEmpty ? sellerPhone : 'எண் விபரம் இல்லை',
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF047857)),
                            ),
                          ],
                        ),
                      ),
                      if (sellerPhone.isNotEmpty) ...[
                        IconButton(
                          icon: const Icon(Icons.call_rounded, color: AppColors.primary),
                          onPressed: () => _makeCall(sellerPhone),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
                          onPressed: () => _openWhatsApp(sellerPhone, sellerName, propTitle),
                        ),
                      ]
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
