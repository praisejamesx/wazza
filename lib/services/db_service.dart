// lib/services/db_service.dart - CORRECTED VERSION
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:wazza/models/chat.dart';
import 'package:wazza/models/message.dart';
import 'package:wazza/models/ai_model.dart';
import 'dart:developer' as developer; // For better logging

class DBService {
  static final DBService _instance = DBService._internal();
  factory DBService() => _instance;
  DBService._internal();

  static Database? _db;
  bool _tablesVerified = false;

  Future<Database> get database async {
    if (_db != null && _tablesVerified) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'wazza.db');

    // Open database. onCreate is our first line of defense.
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );

    // SECOND LINE OF DEFENSE: Explicitly verify tables exist
    await _verifyTables(db);
    _tablesVerified = true;

    return db;
  }

  Future<void> _createTables(Database db, int version) async {
    developer.log('Creating database tables for the first time...');
    await _executeTableCreation(db);
  }

  Future<void> _verifyTables(Database db) async {
    try {
      // Try a simple query on the critical table. If it fails, create it.
      await db.rawQuery('SELECT 1 FROM downloaded_models LIMIT 1');
      developer.log('Database table verified successfully.');
    } catch (e) {
      developer.log('Table missing or corrupt. Recreating...', error: e);
      await _executeTableCreation(db);
    }
  }

  Future<void> _executeTableCreation(Database db) async {
    await db.execute('''
      CREATE TABLE chats(
        id TEXT PRIMARY KEY,
        title TEXT,
        created_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE messages(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        chat_id TEXT,
        text TEXT,
        is_user INTEGER,
        created_at INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE usage(
        date TEXT PRIMARY KEY,
        message_count INTEGER DEFAULT 0
      )
    ''');
    // THE CRITICAL TABLE:
    await db.execute('''
      CREATE TABLE downloaded_models(
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
    developer.log('All tables created successfully.');
  }

  // Save downloaded model (RELIABLE VERSION)
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

      developer.log('Model saved to DB with ID: ${model.id}, path: ${model.localPath}');
      return result > 0;
    } catch (e, stack) {
      developer.log('FAILED to save model to DB', error: e, stackTrace: stack);
      return false;
    }
  }

  // Load downloaded models (WITH BETTER ERROR REPORTING)
  Future<List<AIModel>> getDownloadedModels() async {
    try {
      final db = await database;
      final maps = await db.query('downloaded_models');

      developer.log('Loaded ${maps.length} models from database.');

      return maps.map((e) {
        final templateType = TemplateType.values.firstWhere(
          (t) => t.name == e['template_type'] as String?,
          orElse: () => TemplateType.chatml,
        );

        return AIModel(
          id: e['id'] as String,
          name: e['name'] as String,
          sizeMB: e['size_mb'] as int,
          quant: e['quant'] as String,
          isDownloaded: true,
          localPath: e['local_path'] as String? ?? '', // Ensure not null
          templateType: templateType,
          description: e['description'] as String? ?? '',
          bestFor: e['best_for'] as String? ?? '',
        );
      }).toList();
    } catch (e, stack) {
      developer.log('ERROR loading models from DB. Returning empty list.', error: e, stackTrace: stack);
      return [];
    }
  }

  // Delete model from DB
  Future<void> deleteDownloadedModel(String modelId) async {
    try {
      final db = await database;
      await db.delete(
        'downloaded_models',
        where: 'id = ?',
        whereArgs: [modelId],
      );
    } catch (e) {
      // Ignore errors if table doesn't exist
    }
  }

  // Rest of your existing methods remain...
  Future<void> saveChat(Chat chat) async {
    final db = await database;
    await db.insert('chats', chat.toMap());
  }

  Future<List<Chat>> getChats() async {
    try {
      final db = await database;
      final maps = await db.query('chats', orderBy: 'created_at DESC');
      return maps.map((e) => Chat.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

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
      return [];
    }
  }

  Future<int> getMessageCountToday() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final db = await database;
      final list = await db.query('usage', where: 'date = ?', whereArgs: [today]);
      return list.isEmpty ? 0 : list[0]['message_count'] as int;
    } catch (e) {
      return 0;
    }
  }

  Future<void> incrementMessageCount() async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final db = await database;
      final count = await getMessageCountToday();
      if (count == 0) {
        await db.insert('usage', {'date': today, 'message_count': 1});
      } else {
        await db.update(
          'usage',
          {'message_count': count + 1},
          where: 'date = ?',
          whereArgs: [today],
        );
      }
    } catch (e) {
      // Ignore DB errors
    }
  }

  static const int freeTierLimit = 40;
}