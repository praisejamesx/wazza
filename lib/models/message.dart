class Message {
  final int id;
  final String text;
  final bool isUser;
  final int timestamp;
  final String? imagePath;

  const Message({
    this.id = 0,
    required this.text,
    required this.isUser,
    this.timestamp = 0,
    this.imagePath,
  });

  Message copyWith({
    int? id,
    String? text,
    bool? isUser,
    int? timestamp,
    String? imagePath,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}
