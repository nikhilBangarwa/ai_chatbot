import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/theme/chat_theme.dart';

class ChatModeChips extends StatelessWidget {
  const ChatModeChips({super.key, required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          height: 48,
          color: ChatTheme.surface,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemCount: ChatController.modes.length,
            itemBuilder: (_, i) {
              final mode = ChatController.modes[i];
              final selected = mode == controller.selectedMode;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(mode),
                  selected: selected,
                  onSelected: (_) => controller.setMode(mode),
                  backgroundColor: ChatTheme.surfaceHigh,
                  selectedColor: ChatTheme.accent,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white : ChatTheme.textMuted,
                  ),
                  side: BorderSide(
                    color: selected ? ChatTheme.accent : ChatTheme.border,
                  ),
                  showCheckmark: false,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
