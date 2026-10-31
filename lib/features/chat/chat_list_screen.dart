import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../state/app_state_providers.dart';
import 'conversation_screen.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(conversationsProvider.notifier).syncRemoteConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversations = ref.watch(conversationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('செய்திகள் (Messages)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.read(conversationsProvider.notifier).syncRemoteConversations(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(conversationsProvider.notifier).syncRemoteConversations();
        },
        child: conversations.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 80),
                  EmptyStateView(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'உரையாடல்கள் இல்லை (No Chats)',
                    message: 'சொத்து விவரம் குறித்து நீங்கள் வாங்குபவர் அல்லது விற்பனையாளருடன் பேசும்போது உரையாடல்கள் இங்கு தோன்றும்.',
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                itemCount: conversations.length,
                separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConversationScreen(conversationId: conv.id),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      child: Row(
                        children: [
                          // Agent Avatar
                          Stack(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.primary, AppColors.primaryMedium],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    conv.agent.name.isNotEmpty ? conv.agent.name[0] : 'A',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(width: 14),

                          // Content
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
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.h4.copyWith(fontSize: 15),
                                      ),
                                    ),
                                    Text(
                                      DateFormatter.timeAgo(conv.lastMessageTime),
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: conv.unreadCount > 0 ? AppColors.primary : AppColors.textMuted,
                                        fontWeight: conv.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                // Property Title Tag
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    conv.property.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        conv.lastMessage,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: conv.unreadCount > 0 ? AppColors.textPrimary : AppColors.textSecondary,
                                          fontWeight: conv.unreadCount > 0 ? FontWeight.w600 : FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    if (conv.unreadCount > 0)
                                      Container(
                                        margin: const EdgeInsets.only(left: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          '${conv.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
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
                  );
                },
              ),
      ),
    );
  }
}
