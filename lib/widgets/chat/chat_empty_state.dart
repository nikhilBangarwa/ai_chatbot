import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/chat_theme.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.controller,
    required this.onSuggestionTap,
  });

  final ChatController controller;
  final void Function(String) onSuggestionTap;

  static const _suggestions = [
    'Flutter kya hai?',
    'Spring Boot API banana',
    'GetX vs Provider',
    'Explain AI simply',
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Image.asset(AppAssets.appLogo, width: 96, height: 96),
                const SizedBox(height: 24),
                ShaderMask(
                  shaderCallback: (b) => ChatTheme.brandText.createShader(b),
                  child: const Text(
                    'How can I help you?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mode: ${controller.selectedMode} · Text · Image · PDF · Voice',
                  style: const TextStyle(color: ChatTheme.textDim, fontSize: 12),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: _suggestions
                      .map(
                        (q) => ActionChip(
                          label: Text(q),
                          onPressed: () => onSuggestionTap(q),
                          backgroundColor: ChatTheme.surfaceHigh,
                          side: const BorderSide(color: ChatTheme.border),
                          labelStyle:
                              const TextStyle(color: ChatTheme.textMuted),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
