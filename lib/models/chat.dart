// lib/models/chat.dart
class Chat {
  final String id;
  final String title;
  final int createdAt;

  Chat({required this.id, required this.title, required this.createdAt});

  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'created_at': createdAt};
  }

  factory Chat.fromMap(Map<String, dynamic> map) {
    return Chat(
      id: map['id'] as String,
      title: map['title'] as String,
      createdAt: map['created_at'] as int,
    );
  }
}