import 'chat_message.dart';

class ChatSession {
  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get displayTitle =>
      title.length > 50 ? '${title.substring(0, 50)}...' : title;

  String get lastMessage =>
      messages.isNotEmpty ? messages.last.text : 'No messages';

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  Map<String, dynamic> toJson() => toMap();

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? 'Untitled Chat',
      messages: (map['messages'] as List<dynamic>? ?? [])
          .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
          .toList(),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse(map['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  factory ChatSession.fromJson(Map<String, dynamic> json) =>
      ChatSession.fromMap(json);
}
