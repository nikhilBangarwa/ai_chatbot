import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/chat_theme.dart';

class ChatTypingIndicator extends StatelessWidget {
  const ChatTypingIndicator({super.key, required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(AppAssets.appLogo, width: 28, height: 28),
          ),
          const SizedBox(width: 10),
          AnimatedBuilder(
            animation: animation,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: ChatTheme.surfaceHigh,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
                border: Border.all(color: ChatTheme.border, width: 0.5),
              ),
              child: Row(
                children: List.generate(3, (i) {
                  final v = (animation.value - i * 0.15).clamp(0.0, 1.0);
                  return Container(
                    margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.lerp(
                        ChatTheme.textDim,
                        ChatTheme.accent,
                        v,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
