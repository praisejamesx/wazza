import 'package:drift/drift.dart';
import 'package:wazza/core/database/app_database.dart' hide Chat, Message;
import 'package:wazza/features/chat/domain/chat.dart';
import 'package:uuid/uuid.dart';

class ChatRepository {
  final AppDatabase _db;
  ChatRepository(this._db);

  Future<Chat> createChat({String? title, String? modelId}) async {
    const uuid = Uuid();
    final id = uuid.v4();
    final chat = ChatsCompanion.insert(
      id: id,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      title: Value(title ?? 'New Chat'),
      modelId: Value(modelId),
    );
    await _db.into(_db.chats).insert(chat);
    return Chat(id: id, title: title ?? 'New Chat', createdAt: DateTime.now().millisecondsSinceEpoch, modelId: modelId);
  }

  Stream<List<Chat>> watchChats() {
    return _db.select(_db.chats).watch().map((rows) {
      return rows.map((row) => Chat(
        id: row.id,
        title: row.title,
        createdAt: row.createdAt,
        messageCount: row.messageCount,
        systemPrompt: row.systemPrompt,
        modelId: row.modelId,
        isPinned: row.isPinned == 1,
      )).toList();
    });
  }

  Future<List<Chat>> getChats() async {
    final rows = await (_db.select(_db.chats)..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows.map((row) => Chat(
      id: row.id,
      title: row.title,
      createdAt: row.createdAt,
      messageCount: row.messageCount,
      systemPrompt: row.systemPrompt,
      modelId: row.modelId,
      isPinned: row.isPinned == 1,
    )).toList();
  }

  Future<void> updateTitle(String chatId, String title) async {
    await (_db.update(_db.chats)..where((t) => t.id.equals(chatId))).write(ChatsCompanion(title: Value(title)));
  }

  Future<void> updateSystemPrompt(String chatId, String prompt) async {
    await (_db.update(_db.chats)..where((t) => t.id.equals(chatId))).write(ChatsCompanion(systemPrompt: Value(prompt)));
  }

  Future<void> deleteChat(String chatId) async {
    await (_db.delete(_db.messages)..where((t) => t.chatId.equals(chatId))).go();
    await (_db.delete(_db.chats)..where((t) => t.id.equals(chatId))).go();
  }

  Future<void> togglePin(String chatId) async {
    final chat = await (_db.select(_db.chats)..where((t) => t.id.equals(chatId))).getSingleOrNull();
    if (chat != null) {
      await (_db.update(_db.chats)..where((t) => t.id.equals(chatId)))
          .write(ChatsCompanion(isPinned: Value(chat.isPinned == 1 ? 0 : 1)));
    }
  }

  Future<List<Chat>> searchChats(String query) async {
    final rows = await (_db.select(_db.chats)..where((t) => t.title.like('%$query%'))).get();
    return rows.map((row) => Chat(
      id: row.id, title: row.title, createdAt: row.createdAt,
      messageCount: row.messageCount, modelId: row.modelId,
    )).toList();
  }
}
