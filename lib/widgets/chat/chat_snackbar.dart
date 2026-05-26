import 'package:flutter/material.dart';

import '../../core/theme/chat_theme.dart';

void showChatSnack(BuildContext context, String message,
    {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.redAccent : ChatTheme.surfaceHigh,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
