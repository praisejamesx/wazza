import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

class SearchCacheEntry {
  final String query;
  final List<Map<String, dynamic>> results;
  final String source;
  final DateTime createdAt;
  final DateTime expiresAt;

  SearchCacheEntry({
    required this.query,
    required this.results,
    required this.source,
    required this.createdAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
    'query': query,
    'results': results,
    'source': source,
    'createdAt': createdAt.toIso8601String(),
    'expiresAt': expiresAt.toIso8601String(),
  };

  factory SearchCacheEntry.fromJson(Map<String, dynamic> json) => SearchCacheEntry(
    query: json['query'],
    results: List<Map<String, dynamic>>.from(json['results']),
    source: json['source'],
    createdAt: DateTime.parse(json['createdAt']),
    expiresAt: DateTime.parse(json['expiresAt']),
  );
}

class SearchCache {
  static const String _cacheKey = 'wazza_search_cache';
  static const Duration _defaultTtl = Duration(hours: 24);

  Future<void> store(String query, List<Map<String, dynamic>> results, {String source = 'web', Duration? ttl}) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = await getAll();
    final entry = SearchCacheEntry(
      query: query.toLowerCase().trim(),
      results: results,
      source: source,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(ttl ?? _defaultTtl),
    );

    existing.removeWhere((e) => e.query == entry.query);
    existing.add(entry);
    
    // Keep max 200 entries
    if (existing.length > 200) {
      existing.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      existing.removeRange(0, existing.length - 200);
    }

    final jsonList = existing.map((e) => e.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(jsonList));
    dev.log('[SearchCache] Stored: "$query" (${results.length} results)');
  }

  Future<List<Map<String, dynamic>>?> get(String query) async {
    final all = await getAll();
    final normalizedQuery = query.toLowerCase().trim();
    
    for (final entry in all) {
      if (entry.query == normalizedQuery && !entry.isExpired) {
        dev.log('[SearchCache] Hit: "$query"');
        return entry.results;
      }
    }
    
    dev.log('[SearchCache] Miss: "$query"');
    return null;
  }

  Future<List<SearchCacheEntry>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return [];
    
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((e) => SearchCacheEntry.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cacheKey);
  }

  Future<void> cleanup() async {
    final all = await getAll();
    final valid = all.where((e) => !e.isExpired).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(valid.map((e) => e.toJson()).toList()));
  }
}
