// lib/services/db_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wazza/models/chat.dart';
import 'package:wazza/models/message.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:flutter/foundation.dart';

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wazza.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE chats(
            id TEXT PRIMARY KEY,
            title TEXT,
            created_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE messages(
            id TEXT PRIMARY KEY,
            chat_id TEXT,
            text TEXT,
            is_user INTEGER,
            created_at INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE usage(
            date TEXT PRIMARY KEY,
            message_count INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE downloaded_models(
            id TEXT PRIMARY KEY,
            name TEXT,
            size_mb INTEGER,
            quant TEXT,
            local_path TEXT,
            template_type TEXT
          )
        ''');
      },
    );
  }

  // Chats
  Future<void> saveChat(Chat chat) async {
    final db = await database;
    await db.insert('chats', chat.toMap());
  }

  Future<List<Chat>> getChats() async {
    final db = await database;
    final maps = await db.query('chats', orderBy: 'created_at DESC');
    return maps.map((e) => Chat.fromMap(e)).toList();
  }

  // Messages
  Future<void> saveMessage(String chatId, Message msg) async {
    final db = await database;
    await db.insert('messages', {
      'id': DateTime.now().microsecondsSinceEpoch.toString(),
      'chat_id': chatId,
      'text': msg.text,
      'is_user': msg.isUser ? 1 : 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Message>> getMessages(String chatId) async {
    final db = await database;
    final maps = await db.query(
      'messages',
      where: 'chat_id = ?',
      whereArgs: [chatId],
      orderBy: 'created_at ASC',
    );
    return maps.map((e) => Message(
      text: e['text'] as String,
      isUser: e['is_user'] == 1,
    )).toList();
  }

  // Usage (for rate limits)
  Future<int> getMessageCountToday() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final db = await database;
    final list = await db.query('usage', where: 'date = ?', whereArgs: [today]);
    return list.isEmpty ? 0 : list[0]['message_count'] as int;
  }

  Future<void> incrementMessageCount() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final db = await database;
    final count = await getMessageCountToday();
    if (count == 0) {
      await db.insert('usage', {'date': today, 'message_count': 1});
    } else {
      await db.update('usage', {'message_count': count + 1}, where: 'date = ?', whereArgs: [today]);
    }
  }

  // Save downloaded model
Future<void> saveDownloadedModel(AIModel model) async {
  final db = await database;
  await db.insert('downloaded_models', {
    'id': model.id,
    'name': model.name,
    'size_mb': model.sizeMB,
    'quant': model.quant,
    'local_path': model.localPath,
    'template_type': describeEnum(model.templateType),
  });
}

  // Load downloaded models on startup
  Future<List<AIModel>> getDownloadedModels() async {
    final db = await database;
    final maps = await db.query('downloaded_models');
    return maps.map((e) {
      final type = TemplateType.values.firstWhere(
        (t) => describeEnum(t) == e['template_type'] as String,
        orElse: () => TemplateType.chatml,
      );
      return AIModel(
        id: e['id'] as String,
        name: e['name'] as String,
        sizeMB: e['size_mb'] as int,
        quant: e['quant'] as String,
        isDownloaded: true,
        localPath: e['local_path'] as String?,
        templateType: type,
        description: '',
        bestFor: ''
      );
    }).toList();
  }

  static const int freeTierLimit = 10;
}