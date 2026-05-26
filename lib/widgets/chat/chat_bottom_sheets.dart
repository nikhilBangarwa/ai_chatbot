import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/chat_controller.dart';
import '../../core/theme/chat_theme.dart';
import '../../models/chat_message.dart';

class ChatAttachmentSheet {
  static Future<void> show(
    BuildContext context,
    ChatController controller, {
    required Future<void> Function(ImageSource) onPickImage,
    required Future<void> Function() onPickFile,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: ChatTheme.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Attachment choose karo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<int>(
              future: controller.todayImageCount(),
              builder: (_, snap) {
                final used = snap.data ?? 0;
                final rem = ChatController.dailyImageLimit - used;
                return Text(
                  'Images aaj: $used/${ChatController.dailyImageLimit}',
                  style: TextStyle(
                    color: rem > 0 ? ChatTheme.textMuted : Colors.redAccent,
                    fontSize: 11,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _opt(Icons.camera_alt_rounded, 'Camera', ChatTheme.accent,
                    () {
                  Navigator.pop(ctx);
                  onPickImage(ImageSource.camera);
                }),
                _opt(Icons.photo_library_rounded, 'Gallery',
                    const Color(0xFF3B82F6), () {
                  Navigator.pop(ctx);
                  onPickImage(ImageSource.gallery);
                }),
                _opt(Icons.insert_drive_file_rounded, 'File',
                    Colors.redAccent, () {
                  Navigator.pop(ctx);
                  onPickFile();
                }),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  static Widget _opt(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label,
              style: const TextStyle(color: ChatTheme.textMuted, fontSize: 12)),
        ],
      ),
    );
  }
}

class ChatLanguageSheet {
  static Future<void> show(
    BuildContext context,
    ChatController controller,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: ChatTheme.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => ListenableBuilder(
        listenable: controller,
        builder: (_, __) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Voice language',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...ChatController.languages.map((lang) {
                final selected = controller.voiceLocale == lang['code'];
                return ListTile(
                  title: Text(
                    lang['label']!,
                    style: TextStyle(
                      color: selected ? ChatTheme.accentLight : Colors.white,
                    ),
                  ),
                  trailing: selected
                      ? const Icon(Icons.check_circle,
                          color: ChatTheme.accent)
                      : null,
                  onTap: () {
                    controller.setVoiceLocale(lang['code']!);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatFavoritesSheet {
  static Future<void> show(BuildContext context, ChatController controller) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: ChatTheme.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (_, scroll) => ListenableBuilder(
          listenable: controller,
          builder: (_, __) {
            final favs = controller.favoriteMessages;
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Favorite messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                if (favs.isEmpty)
                  const Center(
                    child: Text(
                      'Koi favorite nahi — message pe ⭐ dabao',
                      style: TextStyle(color: ChatTheme.textMuted),
                    ),
                  )
                else
                  ...favs.map(
                    (m) => Card(
                      color: ChatTheme.background,
                      child: ListTile(
                        title: Text(
                          m.text.length > 80
                              ? '${m.text.substring(0, 80)}...'
                              : m.text,
                          style: const TextStyle(
                            color: ChatTheme.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                        subtitle: Text(m.isUser ? 'You' : 'AI',
                            style: const TextStyle(fontSize: 11)),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () =>
                              controller.copyMessage(m.text),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ChatMessageOptionsSheet {
  static Future<void> show(
    BuildContext context,
    ChatController controller,
    ChatMessage message,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: ChatTheme.surfaceHigh,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy, color: ChatTheme.accent),
              title: const Text('Copy', style: TextStyle(color: Colors.white)),
              onTap: () {
                controller.copyMessage(message.text);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFF3B82F6)),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                controller.shareMessage(message.text);
                Navigator.pop(ctx);
              },
            ),
            if (!message.isUser)
              ListTile(
                leading: const Icon(Icons.volume_up, color: ChatTheme.accentBlue),
                title: const Text('Read aloud',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  controller.toggleSpeak(message);
                },
              ),
            ListTile(
              leading: Icon(
                message.isFavorite ? Icons.star : Icons.star_outline,
                color: ChatTheme.favorite,
              ),
              title: Text(
                message.isFavorite ? 'Remove favorite' : 'Add favorite',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                controller.toggleFavorite(message);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
