import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/theme/chat_theme.dart';

class ChatSearchBar extends StatelessWidget {
  const ChatSearchBar({super.key, required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: ChatTheme.surface,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.searchController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: controller.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Chat mein search karo...',
                    hintStyle: const TextStyle(color: ChatTheme.textDim),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: ChatTheme.accent, size: 20),
                    filled: true,
                    fillColor: ChatTheme.surfaceHigh,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ChatTheme.accent),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              if (controller.searchQuery.isNotEmpty) ...[
                const SizedBox(width: 8),
                Chip(
                  label: Text('${controller.filteredMessages.length}'),
                  backgroundColor: ChatTheme.accent.withValues(alpha: 0.2),
                  labelStyle: const TextStyle(color: ChatTheme.accentLight),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
