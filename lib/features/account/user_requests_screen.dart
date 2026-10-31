import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/user_request.dart';
import '../../state/app_state_providers.dart';

class UserRequestsScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;

  const UserRequestsScreen({super.key, this.initialTabIndex = 0});

  @override
  ConsumerState<UserRequestsScreen> createState() => _UserRequestsScreenState();
}

class _UserRequestsScreenState extends ConsumerState<UserRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: widget.initialTabIndex);
    Future.microtask(() => ref.read(userRequestsProvider.notifier).fetchRequests());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _makeCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openWhatsApp(String phone, String title) async {
    final clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final msg = Uri.encodeComponent('வணக்கம், தென்காசி கனவுகள் மூலம் உங்கள் விளம்பரம் "$title" தொடர்பாக தொடர்பு கொள்கிறேன்.');
    final uri = Uri.parse('https://wa.me/91$clean?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reqState = ref.watch(userRequestsProvider);
    final user = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('தொடர்பு கோரிக்கைகள் (Requests)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'புதுப்பி',
            onPressed: () => ref.read(userRequestsProvider.notifier).fetchRequests(),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('வந்தவை (${reqState.received.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.send_rounded, size: 18),
                  const SizedBox(width: 8),
                  Text('அனுப்பியவை (${reqState.sent.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: !user.isLoggedIn
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 48, color: AppColors.textMuted),
                    const SizedBox(height: 12),
                    const Text(
                      'கோரிக்கைகளைக் காண உள்நுழையவும்',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'உங்கள் கணக்கிற்கு வந்த தொடர்பு கோரிக்கைகளை உடனுக்குடன் பார்க்க உள்நுழையவும்.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          : reqState.isLoading && reqState.received.isEmpty && reqState.sent.isEmpty
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildReceivedList(reqState.received),
                    _buildSentList(reqState.sent),
                  ],
                ),
    );
  }

  Widget _buildReceivedList(List<UserRequest> list) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'புதிய கோரிக்கைகள் எதுவும் இல்லை',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'உங்கள் விளம்பரங்களை வாங்குவோர் தொடர்பு கொள்ளும்போது இங்கே உடனடியாகத் தோன்றும்.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = list[index];
        return _buildReceivedCard(req);
      },
    );
  }

  Widget _buildReceivedCard(UserRequest req) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: req.isPending ? AppColors.accentGold.withValues(alpha: 0.5) : AppColors.border,
          width: req.isPending ? 1.5 : 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          req.senderName.isNotEmpty ? req.senderName[0] : 'U',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            req.senderName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            req.senderPhone,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(req.status),
            ],
          ),
          if (req.propertyTitle != null && req.propertyTitle!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.home_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      req.propertyTitle!,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (req.message != null && req.message!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              req.message!,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            DateFormatter.timeAgo(req.createdAt),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          if (req.isPending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => ref.read(userRequestsProvider.notifier).acceptRequest(req.id),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('ஏற்க (Accept)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.emerald,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => ref.read(userRequestsProvider.notifier).rejectRequest(req.id),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('நிராகரி (Reject)'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (req.isAccepted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makeCall(req.senderPhone),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: const Text('அழைக்க'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(req.senderPhone, req.propertyTitle ?? ''),
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSentList(List<UserRequest> list) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.outbox_rounded, size: 32, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text(
                'அனுப்பிய கோரிக்கைகள் எதுவும் இல்லை',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'விளம்பரங்களை பார்வையிட்டு உரிமையாளருக்கு கோரிக்கை அனுப்பினால் இங்கே பார்க்கலாம்.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final req = list[index];
        return _buildSentCard(req);
      },
    );
  }

  Widget _buildSentCard(UserRequest req) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: req.isAccepted
              ? AppColors.emerald.withValues(alpha: 0.5)
              : (req.isRejected ? AppColors.error.withValues(alpha: 0.3) : AppColors.border),
          width: req.isAccepted ? 1.5 : 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'உரிமையாளர்: ${req.receiverName}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.timeAgo(req.createdAt),
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(req.status),
            ],
          ),
          if (req.propertyTitle != null && req.propertyTitle!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.home_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      req.propertyTitle!,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (req.isAccepted) ...[
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
                  const Icon(Icons.check_circle_rounded, color: AppColors.emerald, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'உரிமையாளர் உங்கள் கோரிக்கையை ஏற்றுக்கொண்டார்! தொடர்பு எண்: ${req.receiverPhone}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makeCall(req.receiverPhone),
                    icon: const Icon(Icons.call_rounded, size: 16),
                    label: const Text('அழைக்க'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openWhatsApp(req.receiverPhone, req.propertyTitle ?? ''),
                    icon: const Icon(Icons.chat_rounded, size: 16),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (req.isRejected) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFECACA)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'உரிமையாளர் உங்கள் கோரிக்கையை ஏற்கவில்லை.',
                      style: TextStyle(fontSize: 12, color: AppColors.error),
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
    IconData icon;

    switch (status.toLowerCase()) {
      case 'accepted':
        bg = const Color(0xFFECFDF5);
        text = AppColors.emerald;
        label = '✓ ஏற்கப்பட்டது';
        icon = Icons.check_circle_rounded;
        break;
      case 'rejected':
        bg = const Color(0xFFFEF2F2);
        text = AppColors.error;
        label = '✕ நிராகரிக்கப்பட்டது';
        icon = Icons.cancel_rounded;
        break;
      default:
        bg = const Color(0xFFFFFBEB);
        text = const Color(0xFFD97706);
        label = '⏳ காத்திருப்பில்';
        icon = Icons.hourglass_top_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: text.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: text),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: text,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
