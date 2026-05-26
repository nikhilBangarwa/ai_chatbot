import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/chat_theme.dart';

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar({
    super.key,
    required this.controller,
    required this.onHistory,
    required this.onNewChat,
    required this.onClearChat,
    required this.onFavorites,
    required this.onLanguage,
    this.onSettings,
    this.onLogout,
    this.showBack = false,
    this.typingAnimation,
  });

  final ChatController controller;
  final VoidCallback onHistory;
  final VoidCallback onNewChat;
  final VoidCallback onClearChat;
  final VoidCallback onFavorites;
  final VoidCallback onLanguage;
  final VoidCallback? onSettings;
  final VoidCallback? onLogout;
  final bool showBack;
  final Animation<double>? typingAnimation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return AppBar(
          backgroundColor: ChatTheme.surfaceHigh,
          elevation: 0,
          leading: showBack
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new,
                      color: ChatTheme.textMuted, size: 18),
                  onPressed: () => Navigator.pop(context),
                )
              : null,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(AppAssets.appLogo, width: 36, height: 36),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShaderMask(
                    shaderCallback: (b) =>
                        ChatTheme.brandText.createShader(b),
                    child: const Text(
                      'AI Chatbot',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (typingAnimation != null)
                    AnimatedBuilder(
                      animation: typingAnimation!,
                      builder: (_, __) => Text(
                        controller.isLoading
                            ? 'AI is typing...'
                            : 'Powered by Groq',
                        style: TextStyle(
                          fontSize: 11,
                          color: controller.isLoading
                              ? Color.lerp(
                                  ChatTheme.accent,
                                  ChatTheme.accentBlue,
                                  typingAnimation!.value,
                                )
                              : ChatTheme.textDim,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                controller.isSearchMode
                    ? Icons.search_off_rounded
                    : Icons.search_rounded,
                color: controller.isSearchMode
                    ? ChatTheme.accent
                    : ChatTheme.textMuted,
              ),
              onPressed: controller.toggleSearch,
            ),
            IconButton(
              icon: const Icon(Icons.language_rounded,
                  color: ChatTheme.textMuted),
              onPressed: onLanguage,
            ),
            IconButton(
              icon: const Icon(Icons.history_rounded,
                  color: ChatTheme.textMuted),
              onPressed: onHistory,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded,
                  color: ChatTheme.textMuted),
              color: ChatTheme.surfaceHigh,
              onSelected: (v) {
                switch (v) {
                  case 'new':
                    onNewChat();
                  case 'favorites':
                    onFavorites();
                  case 'clear':
                    onClearChat();
                  case 'settings':
                    onSettings?.call();
                  case 'logout':
                    onLogout?.call();
                }
              },
              itemBuilder: (_) => [
                _item('new', Icons.add_circle_outline, 'New Chat'),
                _item('favorites', Icons.star_rounded, 'Favorites',
                    color: ChatTheme.favorite),
                _item('clear', Icons.delete_outline, 'Clear Chat'),
                if (onSettings != null)
                  _item('settings', Icons.palette_outlined, 'Appearance'),
                if (onLogout != null)
                  _item('logout', Icons.logout_rounded, 'Logout',
                      color: Colors.redAccent),
              ],
            ),
          ],
        );
      },
    );
  }

  PopupMenuItem<String> _item(String v, IconData icon, String label,
      {Color? color}) {
    return PopupMenuItem(
      value: v,
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.white, size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color ?? Colors.white)),
        ],
      ),
    );
  }
}
