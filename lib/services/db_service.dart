// lib/services/db_service.dart

import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
        version: 4, // CHANGED FROM 3 to 4 for message_count column
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
      developer.log('[DBService] Added usage_logs table');
    }
    
    if (oldVersion < 3) {
      // Add model discovery support
      await db.execute('''
        CREATE TABLE IF NOT EXISTS model_cache(
          file_path TEXT PRIMARY KEY,
          file_hash TEXT,
          last_modified INTEGER,
          discovered_at INTEGER
        )
      ''');
      developer.log('[DBService] Added model_cache table for discovery');
    }
    
    if (oldVersion < 4) {
      // Add message_count column to chats table
      await db.execute('ALTER TABLE chats ADD COLUMN message_count INTEGER DEFAULT 0');
      developer.log('[DBService] Added message_count column to chats table');
    }
  }

  Future<void> _ensureFirstUseTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_firstUseKey)) {
      await prefs.setInt(_firstUseKey, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> _createTables(Database db, int version) async {
    // UPDATED: Added message_count column
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chats(
        id TEXT PRIMARY KEY,
        title TEXT,
        created_at INTEGER,
        message_count INTEGER DEFAULT 0
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
        local_path TEXT NOT NULL UNIQUE,
        template_type TEXT,
        description TEXT,
        best_for TEXT,
        is_custom INTEGER DEFAULT 0,
        discovered_at INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS usage_logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        type TEXT NOT NULL DEFAULT 'message'
      )
    ''');
    
    await db.execute('''
      CREATE TABLE IF NOT EXISTS model_cache(
        file_path TEXT PRIMARY KEY,
        file_hash TEXT,
        last_modified INTEGER,
        discovered_at INTEGER
      )
    ''');
    
    developer.log('[DBService] All tables created (v$version)');
  }

  // ==================== MODEL RECONCILIATION ====================
  
  Future<void> reconcileModels() async {
    try {
      developer.log('[DBService] Starting model reconciliation...');
      
      final db = await database;
      final modelsDir = await _getModelsDirectory();
      
      // Ensure models directory exists
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
        developer.log('[DBService] Created models directory');
        return;
      }
      
      // Scan for model files
      final modelFiles = await _scanForModelFiles(modelsDir);
      developer.log('[DBService] Found ${modelFiles.length} model files');
      
      // Get existing models from database
      final existingModels = await getDownloadedModels();
      final existingPaths = existingModels.map((m) => m.localPath).whereType<String>().toSet();
      
      // Add new models
      int addedCount = 0;
      for (final file in modelFiles) {
        if (!existingPaths.contains(file.path)) {
          final model = await _createModelFromFile(file);
          if (model != null) {
            await db.insert(
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
                'is_custom': 1,
                'discovered_at': DateTime.now().millisecondsSinceEpoch,
              },
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
            addedCount++;
            developer.log('[DBService] Added custom model: ${model.name}');
          }
        }
      }
      
      // Remove models that no longer exist
      int removedCount = 0;
      for (final model in existingModels) {
        if (model.localPath != null) {
          final file = File(model.localPath!);
          if (!await file.exists()) {
            await db.delete(
              'downloaded_models',
              where: 'local_path = ?',
              whereArgs: [model.localPath],
            );
            removedCount++;
            developer.log('[DBService] Removed missing model: ${model.name}');
          }
        }
      }
      
      developer.log('[DBService] Reconciliation complete: +$addedCount, -$removedCount');
      
      // Update AIModel.downloadedModels
      AIModel.downloadedModels = await getDownloadedModels();
      AIModel.syncWithDownloadedModels(AIModel.downloadedModels);
      
    } catch (e) {
      developer.log('[DBService] Error during reconciliation: $e');
    }
  }
  
  Future<Directory> _getModelsDirectory() async {
    // Use app's documents directory for models
    final appDir = await getApplicationDocumentsDirectory();
    return Directory(join(appDir.path, 'models'));
  }
  
  Future<List<File>> _scanForModelFiles(Directory dir) async {
    final files = <File>[];
    
    try {
      final entities = await dir.list().toList();
      
      for (final entity in entities) {
        if (entity is File) {
          // Look for .gguf, .bin, or other model file extensions
          if (entity.path.endsWith('.gguf') || 
              entity.path.endsWith('.bin') ||
              entity.path.endsWith('.model')) {
            files.add(entity);
          }
        } else if (entity is Directory) {
          // Recursively scan subdirectories
          files.addAll(await _scanForModelFiles(entity));
        }
      }
    } catch (e) {
      developer.log('[DBService] Error scanning directory: $e');
    }
    
    return files;
  }
  
  Future<AIModel?> _createModelFromFile(File file) async {
    try {
      final stats = await file.stat();
      final sizeMB = stats.size ~/ (1024 * 1024);
      final fileName = basename(file.path);
      final fileNameWithoutExt = fileName.replaceAll(RegExp(r'\.(gguf|bin|model)$'), '');
      
      // Try to infer model details from filename
      final (quant, templateType) = _inferModelDetails(fileNameWithoutExt);
      
      return AIModel(
        id: 'custom_${fileNameWithoutExt.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}',
        name: _formatModelName(fileNameWithoutExt),
        sizeMB: sizeMB,
        quant: quant,
        isDownloaded: true,
        localPath: file.path,
        templateType: templateType,
        description: 'Custom model discovered in models folder',
        bestFor: 'General chat and tasks',
      );
    } catch (e) {
      developer.log('[DBService] Error creating model from file: $e');
      return null;
    }
  }
  
  (String, TemplateType) _inferModelDetails(String fileName) {
    String quant = 'Q4_K_M';
    TemplateType templateType = TemplateType.chatml;
    
    final lowerName = fileName.toLowerCase();
    
    // Infer quantization
    if (lowerName.contains('q2')) {
      quant = 'Q2_K';
    } else if (lowerName.contains('q3')) {
      quant = 'Q3_K_M';
    } else if (lowerName.contains('q4')) {
      quant = 'Q4_K_M';
    } else if (lowerName.contains('q5')) {
      quant = 'Q5_K_M';
    } else if (lowerName.contains('q6')) {
      quant = 'Q6_K';
    } else if (lowerName.contains('q8')) {
      quant = 'Q8_0';
    } else if (lowerName.contains('fp16')) {
      quant = 'F16';
    }
    
    // Infer template type
    if (lowerName.contains('llama')) {
      if (lowerName.contains('llama3')) {
        templateType = TemplateType.llama3;
      } else {
        templateType = TemplateType.llama2;
      }
    } else if (lowerName.contains('qwen')) {
      templateType = TemplateType.qwen;
    } else if (lowerName.contains('phi')) {
      templateType = TemplateType.phi;
    } else if (lowerName.contains('gemma')) {
      templateType = TemplateType.gemma;
    }
    
    return (quant, templateType);
  }
  
  String _formatModelName(String fileName) {
    // Convert snake_case or kebab-case to Title Case
    return fileName
        .replaceAll(RegExp(r'[_-]'), ' ')
        .split(' ')
        .map((word) => word.isNotEmpty 
            ? word[0].toUpperCase() + word.substring(1).toLowerCase()
            : '')
        .join(' ');
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
          'is_custom': 0, // 0 = downloaded through app, 1 = discovered
          'discovered_at': DateTime.now().millisecondsSinceEpoch,
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

  // ==================== CRITICAL FIX: Check and Recover Models ====================
  
  Future<void> checkAndRecoverModels() async {
    try {
      developer.log('[DBService] Checking and recovering models...');
      
      final models = await getDownloadedModels();
      if (models.isNotEmpty) {
        developer.log('[DBService] Database has ${models.length} models');
        return; // We already have models
      }
      
      // No models in DB, let's scan for files
      await reconcileModels();
      
      final newModels = await getDownloadedModels();
      if (newModels.isEmpty) {
        developer.log('[DBService] No models found after reconciliation');
      } else {
        developer.log('[DBService] Recovered ${newModels.length} models');
      }
    } catch (e) {
      developer.log('[DBService] Error in checkAndRecoverModels: $e');
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
      developer.log('[DBService] Chat saved: ${chat.id} - ${chat.title} (messageCount: ${chat.messageCount})');
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
      developer.log('[DBService] Chat title updated: $chatId to "$newTitle"');
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
      
      // Update message count in chats table
      await db.rawUpdate('''
        UPDATE chats 
        SET message_count = message_count + 1 
        WHERE id = ?
      ''', [chatId]);
      
      developer.log('[DBService] Message saved for chat $chatId');
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

  // ==================== RATE LIMITING (ALWAYS TRUE FOR FREE) ====================
  
  Future<bool> canSendMessage() async {
    // ALWAYS return true - app is now completely free
    return true;
  }

  Future<int> getMessagesUsedInCurrentPeriod() async {
    // Return 0 to show no limits in UI
    return 0;
  }

  Future<void> recordMessageSent() async {
    // Still record for statistics, but no limits
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
      await db.delete('downloaded_models');
      await db.delete('model_cache');
      developer.log('[DBService] Database cleared');
    } catch (e) {
      developer.log('[DBService] Error clearing database: $e');
    }
  }
  
  // ==================== DEBUG METHODS ====================
  
  Future<void> printDatabaseInfo() async {
    try {
      final db = await database;
      
      final chats = await db.rawQuery('SELECT COUNT(*) as count FROM chats');
      final messages = await db.rawQuery('SELECT COUNT(*) as count FROM messages');
      final models = await db.rawQuery('SELECT COUNT(*) as count FROM downloaded_models');
      
      developer.log('[DBService] Database Info:');
      developer.log('[DBService]   Chats: ${chats.first['count']}');
      developer.log('[DBService]   Messages: ${messages.first['count']}');
      developer.log('[DBService]   Models: ${models.first['count']}');
    } catch (e) {
      developer.log('[DBService] Error printing database info: $e');
    }
  }
}