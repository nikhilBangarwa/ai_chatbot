import 'package:flutter/material.dart';

import '../../core/theme/chat_theme.dart';
import '../../services/chat/api_key_storage.dart';

/// Shows Groq API key dialog. Returns saved key or null if cancelled.
class ApiKeyDialog {
  static Future<String?> show(BuildContext context, {String? initial}) async {
    final controller = TextEditingController(text: initial ?? '');
    final saved = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: ChatTheme.surfaceHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Groq API Key',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Key ek baar save hogi — har baar chat open par load hogi.',
              style: TextStyle(color: ChatTheme.textMuted, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              obscureText: true,
              style: const TextStyle(color: Colors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'gsk_...',
                hintStyle: const TextStyle(color: ChatTheme.textDim),
                filled: true,
                fillColor: ChatTheme.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: ChatTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: ChatTheme.accent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later',
                style: TextStyle(color: ChatTheme.textMuted)),
          ),
          FilledButton(
            onPressed: () {
              final key = controller.text.trim();
              if (key.isNotEmpty) Navigator.pop(ctx, key);
            },
            style: FilledButton.styleFrom(backgroundColor: ChatTheme.accent),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (saved != null && saved.isNotEmpty) {
      await ApiKeyStorage.save(saved);
    }
    return saved;
  }
}
