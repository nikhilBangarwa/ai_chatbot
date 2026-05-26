import 'dart:io';

import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/chat_theme.dart';
import '../../models/chat_message.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.controller,
    required this.onLongPress,
    required this.typingAnimation,
  });

  final ChatMessage message;
  final ChatController controller;
  final VoidCallback onLongPress;
  final Animation<double> typingAnimation;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(AppAssets.appLogo, width: 28, height: 28),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.image &&
                    message.filePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      File(message.filePath!),
                      width: 220,
                      height: 160,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (message.type == MessageType.pdf)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.insert_drive_file_rounded,
                            color: Colors.redAccent, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          message.fileName ?? 'File',
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (message.text.isNotEmpty) ...[
                  if (message.type != MessageType.text)
                    const SizedBox(height: 6),
                  GestureDetector(
                    onLongPress: onLongPress,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isUser ? ChatTheme.userBubble : null,
                        color: isUser ? null : ChatTheme.surfaceHigh,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(isUser ? 18 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 18),
                        ),
                        border: isUser
                            ? null
                            : Border.all(color: ChatTheme.border, width: 0.5),
                      ),
                      child: SelectableText(
                        message.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : ChatTheme.textPrimary,
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _iconBtn(Icons.copy_rounded,
                        () => controller.copyMessage(message.text)),
                    const SizedBox(width: 8),
                    _iconBtn(Icons.share_rounded,
                        () => controller.shareMessage(message.text)),
                    if (!isUser) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => controller.toggleSpeak(message),
                        child: AnimatedBuilder(
                          animation: typingAnimation,
                          builder: (_, __) => Icon(
                            controller.speakingMsgId == message.id
                                ? Icons.stop_circle_rounded
                                : Icons.volume_up_rounded,
                            size: 16,
                            color: controller.speakingMsgId == message.id
                                ? Color.lerp(
                                    ChatTheme.accent,
                                    ChatTheme.accentBlue,
                                    typingAnimation.value,
                                  )
                                : ChatTheme.textDim,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => controller.toggleFavorite(message),
                      child: Icon(
                        message.isFavorite
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: message.isFavorite
                            ? ChatTheme.favorite
                            : ChatTheme.textDim,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                gradient: ChatTheme.userBubble,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: const Icon(Icons.person_rounded,
                  size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 15, color: ChatTheme.textDim),
    );
  }
}
