import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
class Message with _$Message {
  const factory Message({
    @Default(0) int id,
    required String chatId,
    required String text,
    required bool isUser,
    required int createdAt,
    String? imagePath,
    String? modelId,
  }) = _Message;
}
