// lib/services/llm_service.dart
import 'dart:async';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/models/message.dart';
import 'package:wazza/services/db_service.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';

class LLMService {
  AIModel? _currentModel;
  LlamaController? _controller;
  bool _isGenerating = false;
  bool _needsFullReset = false;
  DateTime? _lastActionTime;

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
    _needsFullReset = false;
  }

  Stream<String> generateWithContext(String prompt, List<Message> history) async* {
    // Cooldown + generating check
    final now = DateTime.now();
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
    String fullResponse = '';

    try {
      // Build messages with recent history only
      final messages = <ChatMessage>[
        ChatMessage(
          role: 'system',
          content: 'You are a helpful, accurate assistant. Be concise and factual.',
        ),
      ];

      // Last 8 messages for context
      final recent = history.length > 8 ? history.sublist(history.length - 8) : history;
      for (final msg in recent) {
        messages.add(ChatMessage(
          role: msg.isUser ? 'user' : 'assistant',
          content: msg.text,
        ));
      }

      messages.add(ChatMessage(role: 'user', content: prompt));

      // Use correct template for each model
      String template = 'chatml'; // default
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
        fullResponse += token;
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
      // Cancel any active stream
      // _generationSubscription?.cancel();
      // _generationSubscription = null;
    }
  }

  Future<void> dispose() async {
    stop();
    await _controller?.dispose();
    _controller = null;
  }
}