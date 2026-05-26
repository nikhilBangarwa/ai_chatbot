enum MessageType { text, image, pdf }

class ChatMessage {
  ChatMessage({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? time,
    this.type = MessageType.text,
    this.filePath,
    this.fileName,
    this.isFavorite = false,
  })  : id = id ?? DateTime.now().microsecondsSinceEpoch.toString(),
        time = time ?? DateTime.now();

  final String id;
  final String text;
  final bool isUser;
  final DateTime time;
  final MessageType type;
  final String? filePath;
  final String? fileName;
  bool isFavorite;

  Map<String, dynamic> toMap() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'time': time.toIso8601String(),
        'type': type.name,
        'filePath': filePath,
        'fileName': fileName,
        'isFavorite': isFavorite,
      };

  Map<String, dynamic> toJson() => toMap();

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String?,
      text: map['text'] as String,
      isUser: map['isUser'] as bool,
      time: DateTime.tryParse(map['time'] as String? ?? '') ?? DateTime.now(),
      type: MessageType.values.byName(map['type'] as String? ?? 'text'),
      filePath: map['filePath'] as String?,
      fileName: map['fileName'] as String?,
      isFavorite: map['isFavorite'] as bool? ?? false,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      ChatMessage.fromMap(json);
}
