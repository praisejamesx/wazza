import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wazza/core/safety/policy_engine.dart';
import 'dart:developer' as dev;

class AuditEntry {
  final String id;
  final DateTime timestamp;
  final String userQuery;
  final String? llmInterpretation;
  final String actionType;
  final Map<String, dynamic>? actionParams;
  final PolicyResult policyResult;
  final String? userDecision;
  final String? actionResult;
  final String? error;

  AuditEntry({
    required this.id,
    required this.timestamp,
    required this.userQuery,
    this.llmInterpretation,
    required this.actionType,
    this.actionParams,
    required this.policyResult,
    this.userDecision,
    this.actionResult,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'userQuery': userQuery,
    'llmInterpretation': llmInterpretation,
    'actionType': actionType,
    'actionParams': actionParams,
    'policyResult': policyResult.name,
    'userDecision': userDecision,
    'actionResult': actionResult,
    'error': error,
  };

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    userQuery: json['userQuery'],
    llmInterpretation: json['llmInterpretation'],
    actionType: json['actionType'],
    actionParams: json['actionParams'],
    policyResult: PolicyResult.values.firstWhere((e) => e.name == json['policyResult'], orElse: () => PolicyResult.denied),
    userDecision: json['userDecision'],
    actionResult: json['actionResult'],
    error: json['error'],
  );
}

class AuditLog {
  static const String _storageKey = 'wazza_audit_log';
  static const int _maxEntries = 500;

  Future<void> record(AuditEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final entries = await getEntries();
    entries.add(entry);
    
    // Keep only the most recent entries
    if (entries.length > _maxEntries) {
      entries.removeRange(0, entries.length - _maxEntries);
    }
    
    final jsonList = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
    dev.log('[AuditLog] Recorded: ${entry.actionType} - ${entry.policyResult.name}');
  }

  Future<List<AuditEntry>> getEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];
    
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => AuditEntry.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
