import 'package:flutter/material.dart';

import '../../services/auth/auth_service.dart';
import '../../widgets/common/app_logo_widget.dart';
import '../chat/chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.authService,
    this.onOpenSettings,
    this.onSignedOut,
  });

  final AuthService authService;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onSignedOut;

  Future<void> _signOut(BuildContext context) async {
    await authService.signOut();
    onSignedOut?.call();
  }

  void _openChat(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatScreen(
          authService: authService,
          onOpenSettings: onOpenSettings,
          onSignedOut: onSignedOut,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.currentUser!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chatbot'),
        actions: [
          if (onOpenSettings != null)
            IconButton(
              tooltip: 'Settings',
              onPressed: onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Center(child: AppLogoWidget(size: 80)),
            const SizedBox(height: 24),
            if (user.photoUrl != null)
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundImage: NetworkImage(user.photoUrl!),
                ),
              )
            else
              Center(
                child: CircleAvatar(
                  radius: 36,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    user.displayName.substring(0, 1).toUpperCase(),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              'Hello, ${user.displayName}!',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _openChat(context),
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Start chatting'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onOpenSettings,
              icon: const Icon(Icons.palette_outlined),
              label: const Text('Appearance & API key'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
