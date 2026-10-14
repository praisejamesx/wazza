import 'dart:io';
import 'package:drift/drift.dart';
import 'package:encrypted_drift/encrypted_drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'package:wazza/core/database/encryption_key_manager.dart';

part 'app_database.g.dart';

// ===================== TABLE DEFINITIONS =====================

class Chats extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get messageCount => integer().withDefault(const Constant(0))();
  TextColumn get systemPrompt => text().nullable()();
  TextColumn get modelId => text().nullable()();
  IntColumn get isPinned => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get chatId => text().references(Chats, #id)();
  TextColumn get content => text()();
  IntColumn get isUser => integer()();
  IntColumn get createdAt => integer()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get modelId => text().nullable()();
}

class DownloadedModels extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get sizeMb => integer()();
  TextColumn get quant => text()();
  TextColumn get localPath => text().unique()();
  TextColumn get templateType => text()();
  TextColumn get description => text().nullable()();
  TextColumn get bestFor => text().nullable()();
  IntColumn get isCustom => integer().withDefault(const Constant(0))();
  IntColumn get discoveredAt => integer()();
  IntColumn get fileSizeBytes => integer().withDefault(const Constant(0))();
  TextColumn get fileHash => text().nullable()();
  IntColumn get lastVerified => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class UsageLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get timestamp => integer()();
  TextColumn get type => text().withDefault(const Constant('message'))();
}

class ModelCache extends Table {
  TextColumn get filePath => text()();
  TextColumn get fileHash => text().nullable()();
  IntColumn get lastModified => integer()();
  IntColumn get discoveredAt => integer()();

  @override
  Set<Column> get primaryKey => {filePath};
}

class AutomationFlows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get triggerType => text()();
  TextColumn get triggerConfig => text().nullable()();
  TextColumn get steps => text()();
  IntColumn get isEnabled => integer().withDefault(const Constant(1))();
  IntColumn get createdAt => integer()();
  IntColumn get lastExecutedAt => integer().nullable()();
  TextColumn get lastStatus => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class FlowExecutions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get flowId => text()();
  IntColumn get startedAt => integer()();
  IntColumn get completedAt => integer().nullable()();
  TextColumn get status => text()();
  TextColumn get result => text().nullable()();
  TextColumn get error => text().nullable()();
}

class AuditLog extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get timestamp => integer()();
  TextColumn get userQuery => text()();
  TextColumn get llmInterpretation => text().nullable()();
  TextColumn get actionType => text()();
  TextColumn get actionParams => text().nullable()();
  TextColumn get policyResult => text()();
  TextColumn get userDecision => text().nullable()();
  TextColumn get actionResult => text().nullable()();
  TextColumn get error => text().nullable()();
}

class SearchCache extends Table {
  TextColumn get queryHash => text()();
  TextColumn get query => text()();
  TextColumn get results => text()();
  TextColumn get source => text()();
  IntColumn get createdAt => integer()();
  IntColumn get expiresAt => integer()();

  @override
  Set<Column> get primaryKey => {queryHash};
}

class Quizzes extends Table {
  TextColumn get id => text()();
  TextColumn get sourcePdfPath => text().nullable()();
  TextColumn get title => text()();
  TextColumn get questions => text()();
  IntColumn get score => integer().nullable()();
  IntColumn get totalQuestions => integer()();
  IntColumn get completedAt => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ===================== DATABASE CLASS =====================

@DriftDatabase(
  tables: [
    Chats,
    Messages,
    DownloadedModels,
    UsageLogs,
    ModelCache,
    AutomationFlows,
    FlowExecutions,
    AuditLog,
    SearchCache,
    Quizzes,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  AppDatabase.forTesting(super.e);

  static const _uuid = Uuid();

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Fresh rewrite — no upgrade paths yet.
          // Future versions should add columns/tables here.
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // ==================== CHATS ====================

  Stream<List<Chat>> watchChats() {
    return (select(chats)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<Chat>> getChats() {
    return (select(chats)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Chat?> getChat(String id) {
    return (select(chats)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<Chat?> watchChat(String id) {
    return (select(chats)..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  Future<String> createChat({
    String? title,
    String? systemPrompt,
    String? modelId,
  }) {
    final id = _uuid.v4();
    return into(chats).insertReturning(ChatsCompanion.insert(
      id: id,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      title: Value(title),
      systemPrompt: Value(systemPrompt),
      modelId: Value(modelId),
    )).then((row) => row.id);
  }

  Future<void> updateChat(ChatsCompanion chat) {
    return (update(chats)..where((t) => t.id.equals(chat.id.value)))
        .write(chat);
  }

  Future<void> updateChatTitle(String chatId, String title) {
    return (update(chats)..where((t) => t.id.equals(chatId)))
        .write(ChatsCompanion(title: Value(title)));
  }

  Future<void> toggleChatPinned(String chatId) async {
    final chat = await getChat(chatId);
    if (chat != null) {
      await (update(chats)..where((t) => t.id.equals(chatId)))
          .write(ChatsCompanion(isPinned: Value(chat.isPinned == 0 ? 1 : 0)));
    }
  }

  Future<void> incrementMessageCount(String chatId) {
    return customStatement(
      'UPDATE chats SET message_count = message_count + 1 WHERE id = ?',
      [chatId],
    );
  }

  Future<void> deleteChat(String chatId) {
    return transaction(() async {
      await (delete(messages)..where((t) => t.chatId.equals(chatId))).go();
      await (delete(chats)..where((t) => t.id.equals(chatId))).go();
    });
  }

  // ==================== MESSAGES ====================

  Stream<List<Message>> watchMessages(String chatId) {
    return (select(messages)
          ..where((t) => t.chatId.equals(chatId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .watch();
  }

  Future<List<Message>> getMessages(String chatId) {
    return (select(messages)
          ..where((t) => t.chatId.equals(chatId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();
  }

  Future<int> insertMessage({
    required String chatId,
    required String content,
    required bool isUser,
    String? imagePath,
    String? modelId,
  }) async {
    final id = await into(messages).insert(MessagesCompanion.insert(
      chatId: chatId,
      content: content,
      isUser: isUser ? 1 : 0,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      imagePath: Value(imagePath),
      modelId: Value(modelId),
    ));
    await incrementMessageCount(chatId);
    return id;
  }

  Future<void> updateMessage(MessagesCompanion message) {
    return (update(messages)..where((t) => t.id.equals(message.id.value)))
        .write(message);
  }

  Future<void> deleteMessage(int messageId) {
    return (delete(messages)..where((t) => t.id.equals(messageId))).go();
  }

  // ==================== DOWNLOADED MODELS ====================

  Stream<List<DownloadedModel>> watchDownloadedModels() {
    return (select(downloadedModels)
          ..orderBy([(t) => OrderingTerm.desc(t.discoveredAt)]))
        .watch();
  }

  Future<List<DownloadedModel>> getDownloadedModels() {
    return (select(downloadedModels)
          ..orderBy([(t) => OrderingTerm.desc(t.discoveredAt)]))
        .get();
  }

  Future<DownloadedModel?> getDownloadedModel(String id) {
    return (select(downloadedModels)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<DownloadedModel?> getDownloadedModelByPath(String path) {
    return (select(downloadedModels)..where((t) => t.localPath.equals(path)))
        .getSingleOrNull();
  }

  Future<void> saveDownloadedModel({
    required String id,
    required String name,
    required int sizeMb,
    required String quant,
    required String localPath,
    required String templateType,
    String? description,
    String? bestFor,
    bool isCustom = false,
    int fileSizeBytes = 0,
    String? fileHash,
  }) {
    return into(downloadedModels).insertOnConflictUpdate(
      DownloadedModelsCompanion(
        id: Value(id),
        name: Value(name),
        sizeMb: Value(sizeMb),
        quant: Value(quant),
        localPath: Value(localPath),
        templateType: Value(templateType),
        description: Value(description),
        bestFor: Value(bestFor),
        isCustom: Value(isCustom ? 1 : 0),
        discoveredAt: Value(DateTime.now().millisecondsSinceEpoch),
        fileSizeBytes: Value(fileSizeBytes),
        fileHash: Value(fileHash),
      ),
    );
  }

  Future<void> updateDownloadedModel(DownloadedModelsCompanion model) {
    return (update(downloadedModels)..where((t) => t.id.equals(model.id.value)))
        .write(model);
  }

  Future<void> deleteDownloadedModel(String id) {
    return (delete(downloadedModels)..where((t) => t.id.equals(id))).go();
  }

  Future<void> updateModelVerification(String id, int? lastVerified) {
    return (update(downloadedModels)..where((t) => t.id.equals(id))).write(
      DownloadedModelsCompanion(lastVerified: Value(lastVerified)),
    );
  }

  // ==================== USAGE LOGS ====================

  Stream<List<UsageLog>> watchUsageLogs() {
    return (select(usageLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  Future<void> recordUsage({String type = 'message'}) {
    return into(usageLogs).insert(UsageLogsCompanion.insert(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: Value(type),
    ));
  }

  Future<int> getUsageCountInPeriod(Duration period) async {
    final cutoff = DateTime.now().subtract(period).millisecondsSinceEpoch;
    final count = await customSelect(
      'SELECT COUNT(*) AS cnt FROM usage_logs WHERE timestamp > ?',
      variables: [Variable.withInt(cutoff)],
    ).getSingle();
    return count.data['cnt'] as int;
  }

  // ==================== MODEL CACHE ====================

  Stream<List<ModelCacheData>> watchModelCache() {
    return select(modelCache).watch();
  }

  Future<void> upsertModelCache({
    required String filePath,
    String? fileHash,
    required int lastModified,
  }) {
    return into(modelCache).insertOnConflictUpdate(ModelCacheCompanion(
      filePath: Value(filePath),
      fileHash: Value(fileHash),
      lastModified: Value(lastModified),
      discoveredAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));
  }

  Future<void> deleteModelCache(String filePath) {
    return (delete(modelCache)..where((t) => t.filePath.equals(filePath))).go();
  }

  Future<List<ModelCacheData>> getModelCacheEntries() {
    return select(modelCache).get();
  }

  // ==================== AUTOMATION FLOWS ====================

  Stream<List<AutomationFlow>> watchAutomationFlows() {
    return (select(automationFlows)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<AutomationFlow>> getAutomationFlows() {
    return (select(automationFlows)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<AutomationFlow?> getAutomationFlow(String id) {
    return (select(automationFlows)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<String> createAutomationFlow({
    required String name,
    String? description,
    required String triggerType,
    String? triggerConfig,
    required String steps,
  }) {
    final id = _uuid.v4();
    return into(automationFlows)
        .insertReturning(AutomationFlowsCompanion.insert(
      id: id,
      name: name,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      triggerType: triggerType,
      steps: steps,
      description: Value(description),
      triggerConfig: Value(triggerConfig),
    )).then((row) => row.id);
  }

  Future<void> updateAutomationFlow(AutomationFlowsCompanion flow) {
    return (update(automationFlows)..where((t) => t.id.equals(flow.id.value)))
        .write(flow);
  }

  Future<void> toggleFlowEnabled(String flowId) async {
    final flow = await getAutomationFlow(flowId);
    if (flow != null) {
      await (update(automationFlows)..where((t) => t.id.equals(flowId))).write(
        AutomationFlowsCompanion(
            isEnabled: Value(flow.isEnabled == 0 ? 1 : 0)),
      );
    }
  }

  Future<void> deleteAutomationFlow(String flowId) {
    return transaction(() async {
      await (delete(flowExecutions)..where((t) => t.flowId.equals(flowId)))
          .go();
      await (delete(automationFlows)..where((t) => t.id.equals(flowId))).go();
    });
  }

  // ==================== FLOW EXECUTIONS ====================

  Stream<List<FlowExecution>> watchFlowExecutions(String flowId) {
    return (select(flowExecutions)
          ..where((t) => t.flowId.equals(flowId))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .watch();
  }

  Future<int> createFlowExecution({
    required String flowId,
  }) {
    return into(flowExecutions).insert(FlowExecutionsCompanion.insert(
      flowId: flowId,
      startedAt: DateTime.now().millisecondsSinceEpoch,
      status: 'running',
    ));
  }

  Future<void> completeFlowExecution({
    required int executionId,
    required String status,
    String? result,
    String? error,
  }) {
    return (update(flowExecutions)..where((t) => t.id.equals(executionId)))
        .write(FlowExecutionsCompanion(
      completedAt: Value(DateTime.now().millisecondsSinceEpoch),
      status: Value(status),
      result: Value(result),
      error: Value(error),
    ));
  }

  Future<void> updateFlowLastExecution({
    required String flowId,
    required String status,
  }) {
    return (update(automationFlows)..where((t) => t.id.equals(flowId)))
        .write(AutomationFlowsCompanion(
      lastExecutedAt: Value(DateTime.now().millisecondsSinceEpoch),
      lastStatus: Value(status),
    ));
  }

  // ==================== AUDIT LOG ====================

  Stream<List<AuditLogData>> watchAuditLog() {
    return (select(auditLog)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .watch();
  }

  Future<int> addAuditEntry({
    required String userQuery,
    String? llmInterpretation,
    required String actionType,
    String? actionParams,
    required String policyResult,
    String? userDecision,
    String? actionResult,
    String? error,
  }) {
    return into(auditLog).insert(AuditLogCompanion.insert(
      timestamp: DateTime.now().millisecondsSinceEpoch,
      userQuery: userQuery,
      actionType: actionType,
      policyResult: policyResult,
      llmInterpretation: Value(llmInterpretation),
      actionParams: Value(actionParams),
      userDecision: Value(userDecision),
      actionResult: Value(actionResult),
      error: Value(error),
    ));
  }

  Future<void> updateAuditDecision({
    required int auditId,
    String? userDecision,
    String? actionResult,
    String? error,
  }) {
    return (update(auditLog)..where((t) => t.id.equals(auditId))).write(
      AuditLogCompanion(
        userDecision: Value(userDecision),
        actionResult: Value(actionResult),
        error: Value(error),
      ),
    );
  }

  // ==================== SEARCH CACHE ====================

  Stream<List<SearchCacheData>> watchSearchCache() {
    return select(searchCache).watch();
  }

  Future<SearchCacheData?> getCachedSearch(String queryHash) {
    return (select(searchCache)
          ..where((t) => t.queryHash.equals(queryHash))
          ..where((t) => t.expiresAt.isBiggerThanValue(
              DateTime.now().millisecondsSinceEpoch)))
        .getSingleOrNull();
  }

  Future<void> cacheSearchResults({
    required String query,
    required String results,
    required String source,
    Duration ttl = const Duration(hours: 1),
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(searchCache).insertOnConflictUpdate(SearchCacheCompanion(
      queryHash: Value(query.hashCode.toString()),
      query: Value(query),
      results: Value(results),
      source: Value(source),
      createdAt: Value(now),
      expiresAt: Value(now + ttl.inMilliseconds),
    ));
  }

  Future<void> invalidateSearchCache(String queryHash) {
    return (delete(searchCache)..where((t) => t.queryHash.equals(queryHash)))
        .go();
  }

  Future<void> clearExpiredSearchCache() {
    return (delete(searchCache)
          ..where((t) => t.expiresAt
              .isSmallerThanValue(DateTime.now().millisecondsSinceEpoch)))
        .go();
  }

  // ==================== QUIZZES ====================

  Stream<List<Quizze>> watchQuizzes() {
    return (select(quizzes)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<List<Quizze>> getQuizzes() {
    return (select(quizzes)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<Quizze?> getQuiz(String id) {
    return (select(quizzes)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<String> createQuiz({
    String? sourcePdfPath,
    required String title,
    required String questions,
    required int totalQuestions,
  }) {
    final id = _uuid.v4();
    return into(quizzes).insertReturning(QuizzesCompanion.insert(
      id: id,
      title: title,
      questions: questions,
      totalQuestions: totalQuestions,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      sourcePdfPath: Value(sourcePdfPath),
    )).then((row) => row.id);
  }

  Future<void> submitQuizScore({
    required String quizId,
    required int score,
  }) {
    return (update(quizzes)..where((t) => t.id.equals(quizId))).write(
      QuizzesCompanion(
        score: Value(score),
        completedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  Future<void> deleteQuiz(String id) {
    return (delete(quizzes)..where((t) => t.id.equals(id))).go();
  }

  // ==================== SEARCH METHODS ====================

  Future<List<Chat>> searchChats(String query) {
    return (select(chats)
          ..where((t) => t.title.like('%$query%'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<List<Message>> searchMessages(String query, {String? chatId}) {
    final q = select(messages)
      ..where((t) => t.content.like('%$query%'));
    if (chatId != null) {
      q.where((t) => t.chatId.equals(chatId));
    }
    q.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    return q.get();
  }

  // ==================== UTILITY ====================

  Future<void> clearAllData() {
    return transaction(() async {
      await delete(quizzes).go();
      await delete(searchCache).go();
      await delete(auditLog).go();
      await delete(flowExecutions).go();
      await delete(automationFlows).go();
      await delete(modelCache).go();
      await delete(usageLogs).go();
      await delete(downloadedModels).go();
      await delete(messages).go();
      await delete(chats).go();
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final keyManager = EncryptionKeyManager();
    final encryptionKey = await keyManager.getOrCreateKey();

    final dbFolder = await getApplicationDocumentsDirectory();
    final wazzaDir = Directory(p.join(dbFolder.path, 'wazza'));
    if (!await wazzaDir.exists()) {
      await wazzaDir.create(recursive: true);
    }
    final filePath = p.join(wazzaDir.path, 'wazza.sqlite');
    final marker = File(p.join(wazzaDir.path, '.encryption_v2'));

    final dbFile = File(filePath);
    final migrationDone = await marker.exists();

    // One-time migration from an *unencrypted* v1 database to the encrypted
    // v2 database. This must never run twice: previously the live encrypted
    // database was renamed to a backup on every launch, which silently wiped
    // all chats and history. We now only rename a genuine plain SQLite file
    // (identified by its header) and never touch an already-encrypted DB.
    if (!migrationDone && await dbFile.exists()) {
      final header = await _readHeader(dbFile);
      final isPlainSqlite = header.length >= 15 &&
          String.fromCharCodes(header.take(15)) == 'SQLite format 3';
      if (isPlainSqlite) {
        final backupPath = '$filePath.v1_backup';
        if (await File(backupPath).exists()) {
          await File(backupPath).delete();
        }
        await dbFile.rename(backupPath);
        // Clean up stale WAL/SHM journals from the old unencrypted DB.
        for (final suffix in ['-wal', '-shm']) {
          final journal = File('$filePath$suffix');
          if (await journal.exists()) {
            await journal.rename('$backupPath$suffix');
          }
        }
      }
    }

    // Record completion so the check is skipped on every future launch.
    if (!migrationDone) {
      await marker.writeAsString(DateTime.now().toIso8601String());
    }

    return EncryptedExecutor(
      path: filePath,
      password: encryptionKey,
    );
  });
}

Future<List<int>> _readHeader(File file) async {
  final raf = await file.open();
  try {
    return await raf.read(15);
  } finally {
    await raf.close();
  }
}
