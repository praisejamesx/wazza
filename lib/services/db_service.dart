// lib/services/db_service.dart - FINAL COMPLETE VERSION
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
  static const int freeTierLimit = 500;
  static const int periodHours = 24;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'wazza.db');

      final db = await openDatabase(
        path,
        version: 2,
        onCreate: _createTables,
        onUpgrade: _migrateDatabase,
      );

      await _ensureFirstUseTimestamp();
      developer.log('[DBService] Database initialized at $path');
      return db;
    } catch (e) {
      developer.log('[DBService] Init error: $e');
      rethrow;
    }
  }

  // NEW: Migration for existing users
  Future<void> _migrateDatabase(Database db, int oldVersion, int newVersion) async {
    developer.log('[DBService] Migrating from v$oldVersion to v$newVersion');
    
    if (oldVersion < 2) {
      // Add missing usage_logs table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS usage_logs(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          timestamp INTEGER NOT NULL,
          type TEXT NOT NULL DEFAULT 'message'
        )
      ''');
      developer.log('[DBService] Added usage_logs table for existing database');
    }
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

    // THIS TABLE WAS MISSING - NOW INCLUDED
    await db.execute('''
      CREATE TABLE IF NOT EXISTS usage_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        type TEXT NOT NULL DEFAULT 'message'
      )
    ''');
    
    developer.log('[DBService] All tables created successfully');
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
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT COUNT(*) as count FROM usage_logs 
        WHERE timestamp >= ? AND type = 'message'
      ''', [periodStartTimestamp]);
      
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      developer.log('[DBService] Error counting messages: $e');
      return 0;
    }
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
      // Create table if it doesn't exist (fallback)
      await _createTables(_db!, 2);
      // Retry
      await recordMessageSent();
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
      developer.log('[DBService] Chat saved: ${chat.id} - ${chat.title}');
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
      developer.log('[DBService] Loaded ${maps.length} chats from DB');
      return maps.map(Chat.fromMap).toList();
    } catch (e) {
      developer.log('[DBService] Error loading chats: $e');
      return [];
    }
  }

  Future<Chat?> getChat(String chatId) async {
    try {
      final db = await database;
      final maps = await db.query(
        'chats',
        where: 'id = ?',
        whereArgs: [chatId],
        limit: 1,
      );
      
      if (maps.isEmpty) return null;
      return Chat.fromMap(maps.first);
    } catch (e) {
      developer.log('[DBService] Error loading chat: $e');
      return null;
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
      developer.log('[DBService] Message saved for chat $chatId');
    } catch (e) {
      developer.log('[DBService] Error saving message: $e');
    }
  }

  Future<void> saveMessages(String chatId, List<Message> messages) async {
    try {
      final db = await database;
      final batch = db.batch();
      
      for (final message in messages) {
        batch.insert('messages', {
          'chat_id': chatId,
          'text': message.text,
          'is_user': message.isUser ? 1 : 0,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
      }
      
      await batch.commit();
      developer.log('[DBService] ${messages.length} messages saved for chat $chatId');
    } catch (e) {
      developer.log('[DBService] Error saving messages: $e');
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

  // ==================== UTILITY METHODS ====================

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }

  Future<void> clearDatabase() async {
    try {
      final db = await database;
      await db.delete('chats');
      await db.delete('messages');
      await db.delete('usage_logs');
      developer.log('[DBService] Database cleared');
    } catch (e) {
      developer.log('[DBService] Error clearing database: $e');
    }
  }

  Future<void> resetDatabaseIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final needsReset = prefs.getBool('needs_db_reset') ?? true;
      
      if (needsReset) {
        developer.log('[DBService] Performing one-time database reset');
        
        // Close and delete existing database
        await close();
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, 'wazza.db');
        await deleteDatabase(path);
        
        // Reset the database instance
        _db = null;
        
        // Reinitialize
        await database;
        
        // Mark as done
        await prefs.setBool('needs_db_reset', false);
        developer.log('[DBService] Database reset complete');
      }
    } catch (e) {
      developer.log('[DBService] Error during reset: $e');
    }
  }
}