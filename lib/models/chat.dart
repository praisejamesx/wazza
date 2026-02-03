// lib/models/chat.dart - UPDATED
class Chat {
  final String id;
  final String title;
  final int createdAt;
  final int messageCount; // Add this field

  Chat({
    required this.id,
    required this.title,
    required this.createdAt,
    this.messageCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'created_at': createdAt,
      'message_count': messageCount,
    };
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: map['created_at'] as int,
      messageCount: map['message_count'] as int? ?? 0,
    );
  }

  Chat copyWith({
    String? id,
    String? title,
    int? createdAt,
    int? messageCount,
  }) {
    return Chat(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      messageCount: messageCount ?? this.messageCount,
    );
  }
}