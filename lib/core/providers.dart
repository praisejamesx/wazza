import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazza/core/database/app_database.dart' hide Chat, Message, AuditLog, AutomationFlow, FlowExecution;
import 'package:wazza/features/chat/data/chat_repository.dart';
import 'package:wazza/features/chat/data/message_repository.dart';
import 'package:wazza/core/llm/llama_engine.dart';
import 'package:wazza/core/search/search_engine.dart';
import 'package:wazza/core/safety/capability_firewall.dart';
import 'package:wazza/core/safety/audit_log.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(databaseProvider));
});

final messageRepositoryProvider = Provider<MessageRepository>((ref) {
  return MessageRepository(ref.watch(databaseProvider));
});

final llamaEngineProvider = Provider<LlamaEngine>((ref) {
  return LlamaEngine();
});

final searchEngineProvider = Provider<SearchEngine>((ref) {
  return SearchEngine();
});

final capabilityFirewallProvider = Provider<CapabilityFirewall>((ref) {
  return CapabilityFirewall();
});

final auditLogProvider = Provider<AuditLog>((ref) {
  return AuditLog();
});

final darkModeProvider = StateNotifierProvider<DarkModeController, bool>((ref) {
  return DarkModeController();
});

class DarkModeController extends StateNotifier<bool> {
  DarkModeController() : super(false);

  void initialize(bool initialValue) {
    if (state != initialValue) state = initialValue;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', state);
  }
}
