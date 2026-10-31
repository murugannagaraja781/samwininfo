import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/property_visual.dart';
import '../../models/chat_message.dart';
import '../../state/app_state_providers.dart';
import '../property_detail/agent_profile_screen.dart';
import '../property_detail/property_detail_screen.dart';

class ConversationScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const ConversationScreen({super.key, required this.conversationId});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _quickReplies = [
    'விலை பேசலாமா? (Is price negotiable?)',
    'நாளை இடம் பார்க்க வரலாமா? (Visit tomorrow?)',
    'வங்கி கடன் வசதி உள்ளதா? (Bank loan available?)',
    'பத்திர நகல் பார்க்க முடியுமா? (Patta copy?)',
  ];

  Timer? _pollingTimer;
  bool _isAgentTyping = false;

  // WhatsApp Color Palette
  static const Color _waTeal = Color(0xFF008069);
  static const Color _waTealDark = Color(0xFF075E54);
  static const Color _waChatBackground = Color(0xFFECE5DD);
  static const Color _waSentBubble = Color(0xFFE7FFDB);
  static const Color _waReceivedBubble = Color(0xFFFFFFFF);
  static const Color _waTextPrimary = Color(0xFF111B21);
  static const Color _waTextMuted = Color(0xFF667781);
  static const Color _waBlueTick = Color(0xFF53BDEB);
  static const Color _waGreenBtn = Color(0xFF00A884);

  @override
  void initState() {
    super.initState();
    _syncMessages();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _syncMessages();
    });
  }

  Future<void> _syncMessages() async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      await repo.syncRemoteMessages(widget.conversationId);
      ref.read(conversationsProvider.notifier).refresh();
    } catch (_) {}
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final convs = ref.watch(conversationsProvider);
    final conv = convs.cast<ChatConversation?>().firstWhere(
          (c) => c?.id == widget.conversationId,
          orElse: () => null,
        );

    if (conv == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: _waTeal,
          title: const Text('Chat', style: TextStyle(color: Colors.white)),
        ),
        body: const Center(child: Text('Conversation not found.')),
      );
    }

    _scrollToBottom();

    return Scaffold(
      backgroundColor: _waChatBackground,
      appBar: AppBar(
        backgroundColor: _waTeal,
        elevation: 1,
        titleSpacing: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AgentProfileScreen(agent: conv.agent)),
            );
          },
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.white24,
                    child: Text(
                      conv.agent.name.isNotEmpty ? conv.agent.name[0] : 'A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFF25D366),
                        shape: BoxShape.circle,
                        border: Border.all(color: _waTeal, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conv.agent.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _isAgentTyping ? 'typing...' : 'online • ${conv.agent.agencyName}',
                      style: const TextStyle(
                        color: Color(0xFFD1FADF),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.videocam_rounded, size: 24),
            tooltip: 'Video Call',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📹 வீடியோ அழைப்பு வசதி விரைவில்... (Video Call coming soon)'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.phone_rounded, size: 21),
            tooltip: 'Voice Call',
            onPressed: () async {
              final phone = conv.agent.phone.replaceAll(RegExp(r'[^0-9+]'), '');
              final uri = Uri.parse('tel:$phone');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              }
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
            onSelected: (val) {
              if (val == 'view_property') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PropertyDetailScreen(propertyId: conv.property.id)),
                );
              } else if (val == 'view_profile') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AgentProfileScreen(agent: conv.agent)),
                );
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'view_property', child: Text('சொத்தின் விவரம் (View Property)')),
              const PopupMenuItem(value: 'view_profile', child: Text('சுயவிவரம் (View Profile)')),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: _waChatBackground,
        ),
        child: Column(
          children: [
            // Pinned Property Summary Card (WhatsApp Style Header)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PropertyDetailScreen(propertyId: conv.property.id),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    PropertyVisual(
                      propertyType: conv.property.propertyType,
                      customImageBase64: conv.property.customImageBase64,
                      imageUrl: conv.property.imageUrl,
                      width: 50,
                      height: 50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            conv.property.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: _waTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            conv.property.location,
                            style: const TextStyle(fontSize: 11, color: _waTextMuted),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 1),
                          Text(
                            CurrencyFormatter.formatIndianPrice(conv.property.price),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _waTealDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: _waTextMuted),
                  ],
                ),
              ),
            ),

            // Date Badge (WhatsApp Style: "TODAY")
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: const Text(
                'இன்று (TODAY)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF54656F),
                ),
              ),
            ),

            // Messages List (WhatsApp Left-Right Alignment)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                itemCount: conv.messages.length,
                itemBuilder: (context, index) {
                  final msg = conv.messages[index];
                  return _buildWhatsAppBubble(msg);
                },
              ),
            ),

            // Typing Indicator Simulation
            if (_isAgentTyping)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _waReceivedBubble,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${conv.agent.name.split(' ').first} தட்டச்சு செய்கிறார்...',
                          style: const TextStyle(fontSize: 11.5, color: _waTextMuted),
                        ),
                        const SizedBox(width: 8),
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(strokeWidth: 1.5, color: _waTeal),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Quick Replies Chips
            Container(
              height: 34,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final reply = _quickReplies[index];
                  return ActionChip(
                    label: Text(
                      reply,
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: _waTextPrimary),
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300, width: 0.8),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    onPressed: () => _sendMessage(reply),
                  );
                },
              ),
            ),

            // WhatsApp Bottom Input Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 2, 8, 14),
              child: Row(
                children: [
                  // WhatsApp Floating Input Capsule
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Emoji Icon
                          IconButton(
                            icon: const Icon(Icons.emoji_emotions_outlined, color: Color(0xFF8696A0), size: 23),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {},
                          ),
                          const SizedBox(width: 4),

                          // Text Input
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              textCapitalization: TextCapitalization.sentences,
                              style: const TextStyle(fontSize: 15, color: _waTextPrimary),
                              decoration: const InputDecoration(
                                hintText: 'செய்தி தட்டச்சு செய்யவும்... (Message)',
                                hintStyle: TextStyle(color: Color(0xFF8696A0), fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 10),
                              ),
                              onSubmitted: (val) {
                                if (val.trim().isNotEmpty) {
                                  _sendMessage(val.trim());
                                }
                              },
                            ),
                          ),

                          // Attachment Paperclip Icon
                          IconButton(
                            icon: const Icon(Icons.attach_file_rounded, color: Color(0xFF8696A0), size: 22),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('📎 ஆவணம் / புகைப்படம் அனுப்ப தயாராக உள்ளது'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            },
                          ),

                          // Camera Icon
                          IconButton(
                            icon: const Icon(Icons.camera_alt_rounded, color: Color(0xFF8696A0), size: 21),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // WhatsApp Green Circular Send Button
                  Container(
                    width: 46,
                    height: 46,
                    decoration: const BoxDecoration(
                      color: _waGreenBtn,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      onPressed: () {
                        final text = _textController.text.trim();
                        if (text.isNotEmpty) {
                          _sendMessage(text);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Authentic WhatsApp Message Bubble (Right for User, Left for Agent)
  Widget _buildWhatsAppBubble(ChatMessage msg) {
    final isMe = msg.isFromUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 10, 6),
              decoration: BoxDecoration(
                color: isMe ? _waSentBubble : _waReceivedBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(12),
                  topRight: const Radius.circular(12),
                  bottomLeft: Radius.circular(isMe ? 12 : 2),
                  bottomRight: Radius.circular(isMe ? 2 : 12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Wrap(
                alignment: WrapAlignment.end,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 2),
                    child: Text(
                      msg.text,
                      style: const TextStyle(
                        color: _waTextPrimary,
                        fontSize: 14.5,
                        height: 1.35,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormatter.formatChatTime(msg.timestamp),
                        style: const TextStyle(
                          color: _waTextMuted,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMe) ...[
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.done_all_rounded,
                          size: 15,
                          color: _waBlueTick,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String text) async {
    _textController.clear();
    await ref.read(conversationsProvider.notifier).sendMessage(widget.conversationId, text);
    _scrollToBottom();
  }
}
