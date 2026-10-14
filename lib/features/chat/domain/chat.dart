import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';

@freezed
class Chat with _$Chat {
  const factory Chat({
    required String id,
    String? title,
    required int createdAt,
    @Default(0) int messageCount,
    String? systemPrompt,
    String? modelId,
    @Default(false) bool isPinned,
  }) = _Chat;
}
