import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/theme/chat_theme.dart';
import 'chat_empty_state.dart';
import 'chat_message_bubble.dart';
import 'chat_typing_indicator.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.controller,
    required this.typingAnimation,
    required this.onSuggestionTap,
    required this.onMessageOptions,
  });

  final ChatController controller;
  final Animation<double> typingAnimation;
  final void Function(String) onSuggestionTap;
  final void Function(dynamic message) onMessageOptions;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.filteredMessages.isEmpty &&
            controller.searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_rounded,
                    color: ChatTheme.textDim, size: 48),
                const SizedBox(height: 12),
                Text(
                  '"${controller.searchQuery}" nahi mila',
                  style: const TextStyle(color: ChatTheme.textMuted),
                ),
              ],
            ),
          );
        }

        if (controller.messages.isEmpty) {
          return ChatEmptyState(
            controller: controller,
            onSuggestionTap: onSuggestionTap,
          );
        }

        final list = controller.filteredMessages;
        final itemCount = list.length + (controller.isLoading ? 1 : 0);

        return ListView.builder(
          controller: controller.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          itemCount: itemCount,
          itemBuilder: (_, index) {
            if (index == list.length && controller.isLoading) {
              return ChatTypingIndicator(animation: typingAnimation);
            }
            final msg = list[index];
            return ChatMessageBubble(
              message: msg,
              controller: controller,
              typingAnimation: typingAnimation,
              onLongPress: () => onMessageOptions(msg),
            );
          },
        );
      },
    );
  }
}
