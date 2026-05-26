import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/theme/chat_theme.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({
    super.key,
    required this.controller,
    required this.onAttach,
    required this.onSend,
  });

  final ChatController controller;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
          decoration: const BoxDecoration(
            color: ChatTheme.surfaceHigh,
            border: Border(top: BorderSide(color: ChatTheme.border, width: 0.5)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  onPressed: onAttach,
                  icon: const Icon(Icons.attach_file_rounded,
                      color: ChatTheme.accent),
                ),
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: 4,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    decoration: InputDecoration(
                      hintText: controller.isListening
                          ? 'Bol raha hun...'
                          : controller.pendingImages.isNotEmpty
                              ? '${controller.pendingImages.length} image(s)...'
                              : controller.pendingPdfName != null
                                  ? 'File ready — pooch kuch bhi'
                                  : 'Ask anything...',
                      hintStyle: TextStyle(
                        color: controller.isListening
                            ? ChatTheme.accent
                            : ChatTheme.textDim,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: ChatTheme.background,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: controller.isListening
                              ? ChatTheme.accent
                              : ChatTheme.border,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: controller.toggleListening,
                  icon: Icon(
                    controller.isListening
                        ? Icons.mic_rounded
                        : Icons.mic_none_rounded,
                    color: controller.isListening
                        ? ChatTheme.accent
                        : ChatTheme.textMuted,
                  ),
                ),
                FloatingActionButton.small(
                  onPressed: controller.isLoading ? null : onSend,
                  backgroundColor:
                      controller.isLoading ? ChatTheme.border : ChatTheme.accent,
                  child: Icon(
                    controller.isLoading
                        ? Icons.hourglass_top_rounded
                        : Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
