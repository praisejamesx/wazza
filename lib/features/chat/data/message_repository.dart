import 'package:drift/drift.dart';
import 'package:wazza/core/database/app_database.dart' hide Chat, Message;
import 'package:wazza/features/chat/domain/message.dart';

class MessageRepository {
  final AppDatabase _db;
  MessageRepository(this._db);

  Stream<List<Message>> watchMessages(String chatId) {
    return (_db.select(_db.messages)..where((t) => t.chatId.equals(chatId))..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).watch().map((rows) {
      return rows.map((row) => Message(
        id: row.id, chatId: row.chatId, text: row.content,
        isUser: row.isUser == 1, createdAt: row.createdAt,
        imagePath: row.imagePath, modelId: row.modelId,
      )).toList();
    });
  }

  Future<List<Message>> getMessages(String chatId) async {
    final rows = await (_db.select(_db.messages)..where((t) => t.chatId.equals(chatId))..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return rows.map((row) => Message(
      id: row.id, chatId: row.chatId, text: row.content,
      isUser: row.isUser == 1, createdAt: row.createdAt,
      imagePath: row.imagePath, modelId: row.modelId,
    )).toList();
  }

  Future<void> saveMessage(String chatId, Message message) async {
    await _db.into(_db.messages).insert(MessagesCompanion.insert(
      chatId: chatId,
      content: message.text,
      isUser: message.isUser ? 1 : 0,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      imagePath: Value(message.imagePath),
      modelId: Value(message.modelId),
    ));
    await _db.customStatement('UPDATE chats SET message_count = message_count + 1 WHERE id = ?', [chatId]);
  }

  Future<void> deleteMessage(int messageId) async {
    await (_db.delete(_db.messages)..where((t) => t.id.equals(messageId))).go();
  }

  Future<void> clearMessages(String chatId) async {
    await (_db.delete(_db.messages)..where((t) => t.chatId.equals(chatId))).go();
    await _db.customStatement('UPDATE chats SET message_count = 0 WHERE id = ?', [chatId]);
  }
}
