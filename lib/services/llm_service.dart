import 'dart:async';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/models/message.dart';
import 'package:wazza/services/db_service.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:http/http.dart' as http;

class LLMService {
  AIModel? _currentModel;
  LlamaController? _controller;
  bool _isGenerating = false;

  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  Future<void> loadModel(AIModel model) async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    if (model.localPath == null || model.localPath!.isEmpty) {
      throw Exception('No valid model path');
    }

    _controller = LlamaController();
    await _controller!.loadModel(
      modelPath: model.localPath!,
      contextSize: 4096,
      threads: 4,
    );

    _currentModel = model;
  }

  Future<String> _searchWeb(String query) async {
    try {
      final url = Uri.parse('https://lite.duckduckgo.com/lite/').replace(queryParameters: {'q': query});
      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36',
      });
      if (response.statusCode == 200) {
        final body = response.body;
        final results = <String>[];
        final linkRegex = RegExp(r'class="result-link">\s*<a[^>]*href="([^"]*)"[^>]*>([^<]*)<');

        for (final match in linkRegex.allMatches(body)) {
          final title = match.group(2)?.trim();
          final link = match.group(1)?.trim();
          if (title != null && link != null && title.isNotEmpty) {
            results.add('• [$title]($link)');
            if (results.length >= 5) break;
          }
        }

        if (results.isEmpty) {
          final snippetRegex = RegExp(r'class="result-snippet">([^<]*)<');
          for (final match in snippetRegex.allMatches(body)) {
            final snippet = match.group(1)?.trim();
            if (snippet != null && snippet.isNotEmpty) {
              results.add('• $snippet');
              if (results.length >= 5) break;
            }
          }
        }

        if (results.isNotEmpty) {
          return results.join('\n');
        }
      }
      return '';
    } catch (e) {
      return '';
    }
  }

  Stream<String> generateWithContext(
    String prompt,
    List<Message> history, {
    bool useSearch = false,
    String? systemPromptOverride,
    String? imagePath,
  }) async* {
    if (_isGenerating) {
      yield "Please wait for the current response to complete.";
      return;
    }

    if (_controller == null || _currentModel == null) {
      yield "Model not loaded.";
      return;
    }

    final db = DBService();
    if (!await db.canSendMessage()) {
      yield "Daily limit reached.";
      return;
    }

    await db.recordMessageSent();

    _isGenerating = true;

    try {
      final systemPrompt = systemPromptOverride ?? await db.getDefaultSystemPrompt();
      final messages = <ChatMessage>[
        ChatMessage(
          role: 'system',
          content: systemPrompt,
        ),
      ];

      String? webContext;
      if (useSearch) {
        yield '_SEARCHING_';
        webContext = await _searchWeb(prompt);
        if (webContext.isNotEmpty) {
          messages.add(ChatMessage(
            role: 'system',
            content: 'Here are relevant web search results for the user\'s query:\n$webContext\n\nUse these results if relevant to answer the user\'s question.',
          ));
          yield '_SEARCH_DONE_';
        } else {
          yield '_SEARCH_FAILED_';
        }
      }

      final recent = history.length > 8 ? history.sublist(history.length - 8) : history;
      for (final msg in recent) {
        messages.add(ChatMessage(
          role: msg.isUser ? 'user' : 'assistant',
          content: msg.text,
        ));
      }

      messages.add(ChatMessage(role: 'user', content: prompt));

      String template = 'chatml';
      if (_currentModel!.id.contains('phi')) template = 'phi';
      if (_currentModel!.id.contains('gemma')) template = 'gemma';
      if (_currentModel!.id.contains('qwen')) template = 'qwen';
      if (_currentModel!.id.contains('tinyllama') || _currentModel!.id.contains('llama')) template = 'llama2';

      final stream = _controller!.generateChat(
        messages: messages,
        template: template,
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxTokens: 512,
      );

      await for (final token in stream) {
        if (!_isGenerating) break;
        yield token;
      }
    } catch (e) {
      yield "Error: $e";
    } finally {
      _isGenerating = false;
    }
  }



  void stop() {
    if (_isGenerating) {
      _isGenerating = false;
      _controller?.stop();
    }
  }

  Future<void> dispose() async {
    stop();
    await _controller?.dispose();
    _controller = null;
  }
}
