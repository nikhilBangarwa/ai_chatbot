import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/theme/chat_theme.dart';

class ChatRegenerateBar extends StatelessWidget {
  const ChatRegenerateBar({super.key, required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final show = !controller.isLoading &&
            controller.messages.isNotEmpty &&
            !controller.messages.last.isUser;
        if (!show) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Center(
            child: OutlinedButton.icon(
              onPressed: controller.regenerate,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Regenerate Answer'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ChatTheme.accentLight,
                side: BorderSide(
                  color: ChatTheme.accent.withValues(alpha: 0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
