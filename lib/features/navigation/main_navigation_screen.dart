import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/api_config.dart';
import '../../components/common/bottom_nav_bar.dart';
import '../../models/notification_item.dart';
import '../../state/app_state_providers.dart';
import '../../core/theme/app_colors.dart';
import '../account/account_screen.dart';
import '../auth/login_screen.dart';
import '../chat/chat_list_screen.dart';
import '../home/home_screen.dart';
import '../my_ads/my_ads_screen.dart';
import '../post_property/post_property_wizard.dart';
import '../search/search_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  Timer? _heartbeatTimer;
  final Set<String> _shownAdminMsgIds = {};
  String _lastBroadcastId = '';

  @override
  void initState() {
    super.initState();
    _loadLastBroadcastId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sendHeartbeat();
      _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _sendHeartbeat();
      });
    });
  }

  Future<void> _loadLastBroadcastId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastBroadcastId = prefs.getString('last_seen_broadcast_id') ?? '';
    } catch (_) {}
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }

  String _getScreenName(int index) {
    switch (index) {
      case 0:
        return 'முகப்பு (Home)';
      case 1:
        return 'செய்திகள் (Chat Messages)';
      case 2:
        return 'எனது விளம்பரங்கள் (My Ads)';
      case 3:
        return 'கணக்கு (Profile/Account)';
      default:
        return 'App Screen';
    }
  }

  Future<void> _sendHeartbeat() async {
    try {
      final user = ref.read(userProfileProvider);
      final url = '${ApiConfig.instance.serverUrl}/users.php';
      final userId = user.phone.isNotEmpty 
          ? user.phone 
          : (user.email.isNotEmpty ? user.email : 'mobile_guest');

      final res = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'heartbeat',
          'user_id': userId,
          'user_name': user.name.isNotEmpty ? user.name : 'Mobile App User',
          'user_phone': user.phone,
          'user_email': user.email,
          'platform': 'Android App (Flutter)',
          'current_screen': _getScreenName(_currentIndex),
          'role': 'buyer',
          'last_broadcast_id': _lastBroadcastId,
        }),
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['success'] == true && data['unread_admin_messages'] is List) {
          final unreadMsgs = data['unread_admin_messages'] as List;
          if (unreadMsgs.isNotEmpty && mounted) {
            for (final m in unreadMsgs) {
              final msgId = (m['id'] ?? '').toString();
              if (msgId.isNotEmpty && _shownAdminMsgIds.contains(msgId)) {
                continue;
              }
              if (msgId.isNotEmpty) {
                _shownAdminMsgIds.add(msgId);
              }

              // Update last seen broadcast ID
              if (msgId.startsWith('broad_')) {
                _lastBroadcastId = msgId;
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setString('last_seen_broadcast_id', msgId);
                } catch (_) {}
              }

              // Show real-time alert dialog
              _showAdminMessageDialog(m);

              // Add to notification inbox
              try {
                ref.read(notificationsProvider.notifier).addNotification(
                  NotificationItem(
                    id: msgId.isNotEmpty ? msgId : 'notif_${DateTime.now().millisecondsSinceEpoch}',
                    title: m['title'] ?? m['admin_name'] ?? 'Super Admin செய்தி',
                    message: m['message'] ?? '',
                    timestamp: DateTime.tryParse(m['created_at'] ?? '') ?? DateTime.now(),
                    type: 'system',
                    isRead: false,
                  ),
                );
              } catch (_) {}

              // Mark as read on server
              http.post(
                Uri.parse('${ApiConfig.instance.serverUrl}/users.php'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode({
                  'action': 'mark_read',
                  'message_id': msgId,
                  'user_phone': user.phone,
                  'user_id': userId,
                }),
              ).then((_) {}).catchError((_) {});
            }
          }
        }
      }

      // Also sync remote chats
      if (user.phone.isNotEmpty) {
        ref.read(conversationsProvider.notifier).syncRemoteConversations();
      }
    } catch (_) {}
  }

  void _showAdminMessageDialog(dynamic msg) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Header with Gradient
              Stack(
                children: [
                  Container(
                    height: 85,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF1565C0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF0284C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.admin_panel_settings_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      msg['title'] ?? msg['admin_name'] ?? 'Super Admin செய்தி',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        msg['message'] ?? '',
                        style: const TextStyle(
                          fontSize: 14.5,
                          height: 1.55,
                          color: Color(0xFF334155),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text(
                          'சரி (OK)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  void _openPostAdWizard({bool force = false}) {
    final user = ref.read(userProfileProvider);
    if (!force && !user.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    final activeCat = ref.read(selectedCategoryProvider);
    final catToUse = (activeCat == 'all' || activeCat.isEmpty) ? 'land' : activeCat;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostPropertyWizard(initialCategory: catToUse),
        fullscreenDialog: true,
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top decorative gradient header bar with close button
              Stack(
                children: [
                  Container(
                    height: 100,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF0284C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: InkWell(
                      onTap: () => Navigator.pop(ctx),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                  // Centered Floating Hero Icon Badge
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1565C0), Color(0xFF0284C7)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add_business_rounded,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Content Body
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Offer / Value Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('⚡ ', style: TextStyle(fontSize: 12)),
                          Text(
                            '100% இலவச விளம்பரம் • 0% கமிஷன்',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    const Text(
                      'விளம்பரம் பதிவிட உள்நுழைக',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    const Text(
                      'உங்கள் நிலம், வீடு அல்லது தோட்டத்தை தென்காசி கனவுகள் தளத்தில் உடனே விளம்பரம் செய்து, நேரடி வாங்குபவர்களிடம் விற்பனை செய்யுங்கள்.',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF475569),
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 18),

                    // 3 Feature Highlight Badges
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildBenefitRow(
                            icon: Icons.flash_on_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            title: 'உடனடி நேரலை விளம்பரம்',
                            desc: 'பதிவிட்ட உடனே தளத்தில் தோன்றும்',
                          ),
                          const Divider(height: 16, thickness: 0.8, color: Color(0xFFE2E8F0)),
                          _buildBenefitRow(
                            icon: Icons.groups_rounded,
                            iconColor: const Color(0xFF0284C7),
                            title: '10,000+ வாங்குபவர்களை சென்றடையும்',
                            desc: 'தென்காசி மாவட்டத்தின் முன்னணி தளம்',
                          ),
                          const Divider(height: 16, thickness: 0.8, color: Color(0xFFE2E8F0)),
                          _buildBenefitRow(
                            icon: Icons.phone_in_talk_rounded,
                            iconColor: const Color(0xFF10B981),
                            title: 'நேரடி அழைப்புகள் & சாட்',
                            desc: 'வாங்குபவர் உங்களுடன் நேரடியாக பேசுவர்',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Primary Login Button (Full Width Gradient CTA)
                    Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF0284C7)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1565C0).withValues(alpha: 0.38),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LoginScreen(
                                  onLoginSuccess: () {
                                    _openPostAdWizard(force: true);
                                  },
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.login_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'உள்நுழைக (Sign In to Post)',
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Dismiss / Cancel Button
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      child: const Text(
                        'பிறகு செய்கிறேன் (Not Now)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String desc,
  }) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Unread messages count for chat badge
    final conversations = ref.watch(conversationsProvider);
    final totalUnreadChats = conversations.fold<int>(0, (sum, c) => sum + c.unreadCount);

    final screens = [
      HomeScreen(
        onNavigateToSearch: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
      ),
      const ChatListScreen(),
      const MyAdsScreen(),
      AccountScreen(onNavigateToMyAds: () => _onTabTapped(2)),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        onPostAdTap: _openPostAdWizard,
        unreadChatsCount: totalUnreadChats,
      ),
    );
  }
}
