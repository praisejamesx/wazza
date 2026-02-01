// lib/services/llm_service.dart
import 'dart:async';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/db_service.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';

class LLMService {
  AIModel? _currentModel;
  LlamaController? _controller;
  bool _isGenerating = false;

  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  Future<void> loadModel(AIModel model) async {
    if (_currentModel?.id == model.id && _controller != null) return;

    // Clean up previous controller
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }

    if (model.localPath == null || model.localPath!.isEmpty) {
      throw Exception('Model has no valid local path');
    }

    _controller = LlamaController();

    await _controller!.loadModel(
      modelPath: model.localPath!,
      contextSize: 2048,
      threads: 4,
    );

    _currentModel = model;
  }

  Stream<String> generate(String prompt) async* {
    if (_isGenerating || _controller == null) {
      yield "Model not loaded or currently busy.";
      return;
    }

    final db = DBService();
    final count = await db.getMessageCountToday();
    if (count >= DBService.freeTierLimit) {
      yield "Daily free tier limit reached. Please try again tomorrow.";
      return;
    }
    await db.incrementMessageCount();

    _isGenerating = true;

    final messages = [
      ChatMessage(role: 'system', content: 'You are a helpful, accurate AI assistant. Stick to facts and be concise.'),
      ChatMessage(role: 'user', content: prompt),
    ];

    try {
      await for (final token in _controller!.generateChat(
        messages: messages,
        template: _getTemplateString(_currentModel!.templateType),
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxTokens: 512,
      )) {
        if (!_isGenerating) break;
        yield token;
      }
    } catch (e) {
      yield "Generation error: $e";
    } finally {
      _isGenerating = false;
    }
  }

  String _getTemplateString(TemplateType type) {
    switch (type) {
      case TemplateType.chatml:
        return 'chatml';
      case TemplateType.llama2:
        return 'llama2';
      case TemplateType.phi:
        return 'phi';
      case TemplateType.gemma:
        return 'gemma';
      case TemplateType.llama3:
        return 'llama3';
    }
  }

  void stop() {
    _isGenerating = false;
  }

  Future<void> dispose() async {
    _isGenerating = false;
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
  }
}