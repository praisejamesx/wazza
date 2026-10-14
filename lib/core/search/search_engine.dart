import 'package:dio/dio.dart';
import 'package:wazza/core/network/dio_client.dart';
import 'package:wazza/core/search/search_cache.dart';
import 'package:wazza/core/search/query_rewriter.dart';
import 'dart:developer' as dev;

class SearchResult {
  final String title;
  final String url;
  final String snippet;
  SearchResult({required this.title, required this.url, required this.snippet});
  
  Map<String, dynamic> toJson() => {'title': title, 'url': url, 'snippet': snippet};
  factory SearchResult.fromJson(Map<String, dynamic> json) => SearchResult(
    title: json['title'] ?? '', url: json['url'] ?? '', snippet: json['snippet'] ?? '',
  );
}

class SearchEngine {
  final SearchCache _cache = SearchCache();
  
  Future<List<SearchResult>> search(String query) async {
    // Check cache first
    final cached = await _cache.get(query);
    if (cached != null) {
      return cached.map((e) => SearchResult.fromJson(e)).toList();
    }

    List<SearchResult> results = [];
    
    // Try DuckDuckGo Lite first
    try {
      results = await _searchDuckDuckGo(query);
    } catch (e) {
      dev.log('[SearchEngine] DDG failed: $e');
    }
    
    // Fallback to DuckDuckGo HTML
    if (results.isEmpty) {
      try {
        results = await _searchDuckDuckGoHtml(query);
      } catch (e) {
        dev.log('[SearchEngine] DDG HTML failed: $e');
      }
    }

    // Cache results
    if (results.isNotEmpty) {
      await _cache.store(query, results.map((r) => r.toJson()).toList());
    }

    return results;
  }

  Future<List<SearchResult>> searchWithRewrite(String query) async {
    final queries = QueryRewriter.rewrite(query);
    final allResults = <SearchResult>[];
    final seenUrls = <String>{};

    for (final q in queries) {
      final results = await search(q);
      for (final r in results) {
        if (!seenUrls.contains(r.url)) {
          seenUrls.add(r.url);
          allResults.add(r);
        }
      }
      if (allResults.length >= 5) break;
    }

    return allResults.take(8).toList();
  }

  String formatForLLM(List<SearchResult> results) {
    if (results.isEmpty) return '';
    final buf = StringBuffer();
    for (var i = 0; i < results.length; i++) {
      buf.writeln('[${i + 1}] ${results[i].title}');
      buf.writeln(results[i].url);
      buf.writeln(results[i].snippet);
      buf.writeln();
    }
    return buf.toString();
  }

  Future<List<SearchResult>> _searchDuckDuckGo(String query) async {
    final client = DioClient();
    const url = 'https://lite.duckduckgo.com/lite/';
    final response = await client.get(url, queryParameters: {'q': query});
    
    if (response.statusCode != 200) return [];
    
    final body = response.data.toString();
    final results = <SearchResult>[];
    
    // Parse result links
    final linkRegex = RegExp(r'class="result-link"[^>]*href="([^"]*)"[^>]*>([^<]*)<');
    for (final match in linkRegex.allMatches(body)) {
      final link = match.group(1)?.trim() ?? '';
      final title = match.group(2)?.trim() ?? '';
      if (title.isNotEmpty && link.isNotEmpty) {
        results.add(SearchResult(title: title, url: link, snippet: ''));
      }
      if (results.length >= 5) break;
    }
    
    // Parse snippets
    final snippetRegex = RegExp(r'class="result-snippet">([^<]*)<');
    final snippets = <String>[];
    for (final match in snippetRegex.allMatches(body)) {
      final snippet = match.group(1)?.trim() ?? '';
      if (snippet.isNotEmpty) snippets.add(snippet);
    }
    
    // Pair snippets with results
    for (var i = 0; i < results.length && i < snippets.length; i++) {
      results[i] = SearchResult(title: results[i].title, url: results[i].url, snippet: snippets[i]);
    }
    
    return results;
  }

  Future<List<SearchResult>> _searchDuckDuckGoHtml(String query) async {
    final client = DioClient();
    const url = 'https://html.duckduckgo.com/html/';
    final response = await client.dio.post(url, data: 'q=${Uri.encodeQueryComponent(query)}', options: Options(
      contentType: 'application/x-www-form-urlencoded',
      headers: {'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36'},
    ));
    
    if (response.statusCode != 200) return [];
    
    final body = response.data.toString();
    final results = <SearchResult>[];
    
    final resultRegex = RegExp(r'class="result__a"[^>]*href="([^"]*)"[^>]*>(.*?)</a>.*?class="result__snippet">(.*?)</(?:a|span|td)', dotAll: true);
    for (final match in resultRegex.allMatches(body)) {
      final u = match.group(1)?.trim() ?? '';
      final title = match.group(2)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? '';
      final snippet = match.group(3)?.replaceAll(RegExp(r'<[^>]*>'), '').trim() ?? '';
      if (title.isNotEmpty) {
        results.add(SearchResult(title: title, url: u, snippet: snippet));
      }
      if (results.length >= 8) break;
    }
    
    return results;
  }
}
