import 'package:flutter/material.dart';

import '../../controllers/chat_controller.dart';
import '../../core/theme/chat_theme.dart';

class ChatImagesPreview extends StatelessWidget {
  const ChatImagesPreview({super.key, required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.pendingImages.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          color: ChatTheme.surface,
          child: Row(
            children: [
              SizedBox(
                height: 64,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.pendingImages.length,
                  itemBuilder: (_, i) => Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            controller.pendingImages[i],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => controller.removePendingImage(i),
                          child: const CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.redAccent,
                            child: Icon(Icons.close, size: 12, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                '${controller.pendingImages.length} image(s) ready',
                style: const TextStyle(color: ChatTheme.textMuted, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ChatPdfPreview extends StatelessWidget {
  const ChatPdfPreview({super.key, required this.controller});

  final ChatController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (controller.pendingPdfName == null) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          color: ChatTheme.surface,
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.insert_drive_file_rounded,
                    color: Colors.redAccent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      controller.pendingPdfName!,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Text(
                      'File ready — type your question',
                      style: TextStyle(color: ChatTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: ChatTheme.textMuted),
                onPressed: controller.clearPendingPdf,
              ),
            ],
          ),
        );
      },
    );
  }
}
