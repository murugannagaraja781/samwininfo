import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/chat_message.dart';
import '../../state/app_state_providers.dart';
import '../chat/conversation_screen.dart';

class AdminLiveChatScreen extends ConsumerStatefulWidget {
  const AdminLiveChatScreen({super.key});

  @override
  ConsumerState<AdminLiveChatScreen> createState() => _AdminLiveChatScreenState();
}

class _AdminLiveChatScreenState extends ConsumerState<AdminLiveChatScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _syncChats();
  }

  Future<void> _syncChats() async {
    setState(() => _isSyncing = true);
    try {
      await ref.read(conversationsProvider.notifier).syncAdminAllConversations();
    } catch (_) {}
    if (mounted) {
      setState(() => _isSyncing = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final convs = ref.watch(conversationsProvider);

    final filtered = convs.where((c) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      final agentName = c.agent.name.toLowerCase();
      final title = c.property.title.toLowerCase();
      final phone = c.agent.phone.toLowerCase();
      return agentName.contains(q) || title.contains(q) || phone.contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F3D6E),
        title: const Text(
          'Live User Chat (நேரலை உரையாடல்)',
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'புதுப்பி',
            onPressed: _isSyncing ? null : _syncChats,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
              decoration: InputDecoration(
                hintText: 'பயனர் பெயர், எண் அல்லது சொத்து தேடுக...',
                hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0284C7), size: 20),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          Expanded(
            child: RefreshIndicator(
              onRefresh: _syncChats,
              child: filtered.isEmpty
                  ? Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline_rounded, size: 52, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              _isSyncing ? 'உரையாடல்கள் பெறப்படுகின்றன...' : 'உரையாடல்கள் இல்லை',
                              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'பயனர்கள் சொத்து தொடர்பாக சாட் செய்யும்போது இங்கு தோன்றும்',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final conv = filtered[index];
                        return _buildChatTile(conv);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatConversation conv) {
    final timeStr = DateFormat('dd MMM, hh:mm a').format(conv.lastMessageTime);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationScreen(conversationId: conv.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF0F3D6E).withValues(alpha: 0.1),
              child: const Icon(Icons.forum_rounded, color: Color(0xFF0F3D6E), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conv.agent.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E293B)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.terrain_rounded, size: 13, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          conv.property.title,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF0284C7), fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conv.lastMessage.isNotEmpty ? conv.lastMessage : 'உரையாடல் தொடங்கப்பட்டது',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
          ],
        ),
      ),
    );
  }
}
