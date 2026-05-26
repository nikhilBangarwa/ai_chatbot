import 'package:flutter/material.dart';

import '../../core/theme/chat_theme.dart';
import '../../models/chat_session.dart';
import '../../services/auth/auth_service.dart';
import '../../services/chat/chat_service.dart';
import 'chat_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, this.authService});

  final AuthService? authService;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ChatTheme.background,
      appBar: AppBar(
        backgroundColor: ChatTheme.surfaceHigh,
        title: const Text('Chat History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_outlined),
            onPressed: () {
              Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ChatScreen(authService: widget.authService),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ChatSession>>(
        stream: ChatService.instance.sessionsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: ChatTheme.accent),
            );
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return const Center(
              child: Text(
                'Koi chat history nahi',
                style: TextStyle(color: ChatTheme.textMuted),
              ),
            );
          }

          return ListView.builder(
            itemCount: sessions.length,
            itemBuilder: (_, i) {
              final s = sessions[i];
              return Dismissible(
                key: ValueKey(s.id),
                direction: DismissDirection.endToStart,
                onDismissed: (_) =>
                    ChatService.instance.deleteSession(s.id),
                background: const ColoredBox(
                  color: Colors.redAccent,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                  ),
                ),
                child: ListTile(
                  tileColor: ChatTheme.surfaceHigh,
                  title: Text(
                    s.displayTitle,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${s.messages.length} messages · ${s.lastMessage}',
                    style: const TextStyle(color: ChatTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right,
                      color: ChatTheme.textMuted),
                  onTap: () {
                    Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          sessionId: s.id,
                          authService: widget.authService,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
