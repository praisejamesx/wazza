// lib/services/db_service.dart - COMPLETE CLEAN VERSION
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazza/models/chat.dart';
import 'package:wazza/models/message.dart';
import 'package:wazza/models/ai_model.dart';
import 'dart:developer' as developer;

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _db;
  
  // === RATE LIMIT CONFIG ===
  static const String _firstUseKey = 'first_use_timestamp';
  static const int freeTierLimit = 50;
  static const int periodHours = 24;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wazza.db');

    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );

    await _ensureFirstUseTimestamp();
    return db;
  }

  Future<void> _ensureFirstUseTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_firstUseKey)) {
      await prefs.setInt(_firstUseKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chats(
        id TEXT PRIMARY KEY,
        title TEXT,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id TEXT,
        text TEXT,
        is_user INTEGER,
        created_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS downloaded_models(
        id TEXT PRIMARY KEY,
        name TEXT,
        size_mb INTEGER,
        quant TEXT,
        local_path TEXT NOT NULL,
        template_type TEXT,
        description TEXT,
        best_for TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS usage_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        type TEXT NOT NULL DEFAULT 'message'
      )
    ''');
    
    developer.log('[DBService] Tables created');
  }

  // ==================== SECURE RATE LIMITING ====================
  
  Future<int> _getFirstUseTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_firstUseKey) ?? DateTime.now().millisecondsSinceEpoch;
  }

  int _getCurrentPeriodStart(int firstUseTimestamp) {
    final firstUse = DateTime.fromMillisecondsSinceEpoch(firstUseTimestamp);
    final now = DateTime.now();
    
    final hoursSinceFirstUse = now.difference(firstUse).inHours;
    final periodsElapsed = hoursSinceFirstUse ~/ periodHours;
    
    final periodStart = firstUse.add(Duration(hours: periodsElapsed * periodHours));
    return periodStart.millisecondsSinceEpoch;
  }

  Future<int> _getMessagesInPeriod(int periodStartTimestamp) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM usage_logs 
      WHERE timestamp >= ? AND type = 'message'
    ''', [periodStartTimestamp]);
    
    return result.first['count'] as int;
  }

  Future<bool> canSendMessage() async {
    try {
      final firstUseTimestamp = await _getFirstUseTimestamp();
      final periodStart = _getCurrentPeriodStart(firstUseTimestamp);
      final messagesInPeriod = await _getMessagesInPeriod(periodStart);
      
      developer.log('[DBService] Rate check: $messagesInPeriod/$freeTierLimit');
      return messagesInPeriod < freeTierLimit;
    } catch (e) {
      developer.log('[DBService] Error in canSendMessage: $e');
      return true;
    }
  }

  Future<int> getMessagesUsedInCurrentPeriod() async {
    try {
      final firstUseTimestamp = await _getFirstUseTimestamp();
      final periodStart = _getCurrentPeriodStart(firstUseTimestamp);
      return await _getMessagesInPeriod(periodStart);
    } catch (e) {
      developer.log('[DBService] Error getting messages used: $e');
      return 0;
    }
  }

  Future<void> recordMessageSent() async {
    try {
      final db = await database;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await db.insert('usage_logs', {
        'timestamp': timestamp,
        'type': 'message',
      });
      
      developer.log('[DBService] Message recorded at $timestamp');
    } catch (e) {
      developer.log('[DBService] Error recording message: $e');
    }
  }

  // ==================== MODEL MANAGEMENT ====================

  Future<bool> saveDownloadedModel(AIModel model) async {
    try {
      if (model.localPath == null || model.localPath!.isEmpty) {
        throw Exception('Cannot save model: localPath is null or empty');
      }

      final db = await database;
      final result = await db.insert(
        'downloaded_models',
        {
          'id': model.id,
          'name': model.name,
          'size_mb': model.sizeMB,
          'quant': model.quant,
          'local_path': model.localPath!,
          'template_type': model.templateType.name,
          'description': model.description,
          'best_for': model.bestFor,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      developer.log('[DBService] Model saved: ${model.id}');
      return result > 0;
    } catch (e) {
      developer.log('[DBService] FAILED to save model: $e');
      return false;
    }
  }

  Future<List<AIModel>> getDownloadedModels() async {
    try {
      final db = await database;
      final maps = await db.query('downloaded_models');

      return maps.map((e) {
        final templateType = TemplateType.values.firstWhere(
          (t) => t.name == (e['template_type'] as String? ?? 'chatml'),
          orElse: () => TemplateType.chatml,
        );

        return AIModel(
          id: e['id'] as String,
          name: e['name'] as String,
          sizeMB: e['size_mb'] as int? ?? 0,
          quant: e['quant'] as String? ?? 'Q4_K_M',
          isDownloaded: true,
          localPath: e['local_path'] as String,
          templateType: templateType,
          description: e['description'] as String? ?? '',
          bestFor: e['best_for'] as String? ?? '',
        );
      }).toList();
    } catch (e) {
      developer.log('[DBService] ERROR loading models: $e');
      return [];
    }
  }

  Future<void> deleteDownloadedModel(String modelId) async {
    try {
      final db = await database;
      await db.delete(
        'downloaded_models',
        where: 'id = ?',
        whereArgs: [modelId],
      );
      developer.log('[DBService] Model deleted: $modelId');
    } catch (e) {
      developer.log('[DBService] Error deleting model: $e');
    }
  }

  // ==================== CHAT PERSISTENCE ====================

  Future<void> saveChat(Chat chat) async {
    try {
      final db = await database;
      await db.insert(
        'chats',
        chat.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      developer.log('[DBService] Chat saved: ${chat.id}');
    } catch (e) {
      developer.log('[DBService] Error saving chat: $e');
    }
  }

  Future<List<Chat>> getChats() async {
    try {
      final db = await database;
      final maps = await db.query(
        'chats',
        orderBy: 'created_at DESC',
      );
      
      return maps.map(Chat.fromMap).toList();
    } catch (e) {
      developer.log('[DBService] Error loading chats: $e');
      return [];
    }
  }

  Future<void> updateChatTitle(String chatId, String newTitle) async {
    try {
      final db = await database;
      await db.update(
        'chats',
        {'title': newTitle},
        where: 'id = ?',
        whereArgs: [chatId],
      );
      developer.log('[DBService] Chat title updated: $chatId');
    } catch (e) {
      developer.log('[DBService] Error updating chat title: $e');
    }
  }

  Future<void> deleteChat(String chatId) async {
    try {
      final db = await database;
      
      await db.delete(
        'messages',
        where: 'chat_id = ?',
        whereArgs: [chatId],
      );
      
      await db.delete(
        'chats',
        where: 'id = ?',
        whereArgs: [chatId],
      );
      
      developer.log('[DBService] Chat deleted: $chatId');
    } catch (e) {
      developer.log('[DBService] Error deleting chat: $e');
    }
  }

  // ==================== MESSAGE MANAGEMENT ====================

  Future<void> saveMessage(String chatId, Message message) async {
    try {
      final db = await database;
      await db.insert('messages', {
        'chat_id': chatId,
        'text': message.text,
        'is_user': message.isUser ? 1 : 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      developer.log('[DBService] Error saving message: $e');
    }
  }

  Future<List<Message>> getMessages(String chatId) async {
    try {
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
    } catch (e) {
      developer.log('[DBService] Error loading messages: $e');
      return [];
    }
  }

  // ==================== BACKWARD COMPATIBILITY ====================
  
  Future<int> getMessageCountToday() async {
    return await getMessagesUsedInCurrentPeriod();
  }

  Future<void> incrementMessageCount() async {
    await recordMessageSent();
  }

}