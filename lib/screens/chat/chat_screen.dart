import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/theme/chat_theme.dart';
import '../../models/chat_message.dart';
import '../../services/auth/auth_service.dart';
import '../../widgets/chat/chat_app_bar.dart';
import '../../widgets/chat/chat_bottom_sheets.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/chat/chat_message_list.dart';
import '../../widgets/chat/chat_mode_chips.dart';
import '../../widgets/chat/chat_pending_previews.dart';
import '../../widgets/chat/chat_regenerate_bar.dart';
import '../../widgets/chat/chat_search_bar.dart';
import '../../widgets/chat/chat_snackbar.dart';
import 'history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    this.sessionId,
    this.authService,
    this.onSignedOut,
    this.onOpenSettings,
  });

  final String? sessionId;
  final AuthService? authService;
  final VoidCallback? onSignedOut;
  final VoidCallback? onOpenSettings;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  late final ChatController _controller;
  late final AnimationController _typingAnim;
  bool _apiMissing = false;

  @override
  void initState() {
    super.initState();
    _controller = ChatController(initialSessionId: widget.sessionId);
    _typingAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await _controller.initialize();
    if (!mounted) return;
    setState(() {
      _apiMissing = _controller.needsApiKey;
    });
    if (_apiMissing) {
      showChatSnack(
        context,
        'Chat abhi configure nahi hai. Admin Firebase mein API key add kare.',
        isError: true,
      );
    }
  }

  Future<void> _send() async {
    if (_controller.needsApiKey) {
      await _controller.reloadApiKey();
      if (_controller.needsApiKey) {
        if (mounted) {
          showChatSnack(
            context,
            'Chat service unavailable. Please try again later.',
            isError: true,
          );
        }
        return;
      }
      setState(() => _apiMissing = false);
    }
    final err = await _controller.sendMessage();
    if (err != null && mounted) {
      showChatSnack(context, err, isError: true);
    }
  }

  void _confirmClear() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatTheme.surfaceHigh,
        title: const Text('Clear chat?',
            style: TextStyle(color: Colors.white)),
        content: const Text('Current messages will be removed.',
            style: TextStyle(color: ChatTheme.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _controller.clearChat();
              Navigator.pop(ctx);
            },
            child: const Text('Clear',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _typingAnim.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.isReady) {
      return const Scaffold(
        backgroundColor: ChatTheme.background,
        body: Center(
          child: CircularProgressIndicator(color: ChatTheme.accent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ChatTheme.background,
      appBar: ChatAppBar(
        controller: _controller,
        showBack: widget.sessionId != null,
        typingAnimation: _typingAnim,
        onHistory: () async {
          await Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => HistoryScreen(authService: widget.authService),
            ),
          );
          if (mounted) setState(() {});
        },
        onNewChat: _controller.newChat,
        onClearChat: _confirmClear,
        onFavorites: () => ChatFavoritesSheet.show(context, _controller),
        onLanguage: () => ChatLanguageSheet.show(context, _controller),
        onSettings: widget.onOpenSettings,
        onLogout: widget.authService == null
            ? null
            : () async {
                await widget.authService!.signOut();
                widget.onSignedOut?.call();
              },
      ),
      body: Column(
        children: [
          if (_apiMissing)
            MaterialBanner(
              content: const Text(
                'AI chat configure ho raha hai. Thodi der baad try karein.',
                style: TextStyle(fontSize: 13),
              ),
              backgroundColor: ChatTheme.surfaceHigh,
              actions: [
                TextButton(
                  onPressed: () async {
                    await _controller.reloadApiKey();
                    if (mounted) {
                      setState(() => _apiMissing = _controller.needsApiKey);
                    }
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          if (_controller.isSearchMode)
            ChatSearchBar(controller: _controller)
          else
            ChatModeChips(controller: _controller),
          Expanded(
            child: ChatMessageList(
              controller: _controller,
              typingAnimation: _typingAnim,
              onSuggestionTap: (q) {
                _controller.messageController.text = q;
                _send();
              },
              onMessageOptions: (msg) => ChatMessageOptionsSheet.show(
                context,
                _controller,
                msg as ChatMessage,
              ),
            ),
          ),
          ChatRegenerateBar(controller: _controller),
          ChatImagesPreview(controller: _controller),
          ChatPdfPreview(controller: _controller),
          ChatInputBar(
            controller: _controller,
            onAttach: () => ChatAttachmentSheet.show(
              context,
              _controller,
              onPickImage: (source) async {
                final msg = await _controller.pickImages(source);
                if (msg != null && mounted) {
                  showChatSnack(context, msg, isError: msg.contains('limit'));
                }
              },
              onPickFile: () async {
                final msg = await _controller.pickFile();
                if (msg != null && mounted) showChatSnack(context, msg);
              },
            ),
            onSend: _send,
          ),
        ],
      ),
    );
  }
}
