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

  static const Map<String, ModelConfig> _modelConfigs = {
    'qwen1_5_1_8b': ModelConfig(
      isChatModel: true,
      maxTokens: 512,
      temperature: 0.7,
      stopSequences: ['<|im_end|>', '\n\n'],
      template: 'qwen',
    ),
    'phi2': ModelConfig(
      isChatModel: true,
      maxTokens: 256,
      temperature: 0.7,
      stopSequences: ['\n\n', '<|endoftext|>'],
      template: 'phi',
    ),
    'gemma2b': ModelConfig(
      isChatModel: true,
      maxTokens: 512,
      temperature: 0.7,
      stopSequences: ['<end_of_turn>', '\n\n'],
      template: 'gemma',
    ),
    'tinyllama': ModelConfig(
      isChatModel: false,
      maxTokens: 100,
      temperature: 0.3,
      stopSequences: ['\n\n', '\nUser:', '\nuser:', 'User:', 'user:', '.', '?', '!'],
    ),
  };

  Future<void> loadModel(AIModel model) async {
    try {
      if (_currentModel?.id == model.id && _controller != null) return;

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
    } catch (e) {
      rethrow;
    }
  }

  Stream<String> generate(String prompt) async* {
    if (_isGenerating || _controller == null) {
      yield "Model not loaded or currently busy.";
      return;
    }

    final db = DBService();
    
    // Use the secure rate limiting method
    if (!await db.canSendMessage()) {
      yield "Daily free tier limit reached. Please try again tomorrow.";
      return;
    }
    
    await db.recordMessageSent();
    _isGenerating = true;

    try {
      final config = _modelConfigs[_currentModel!.id] ?? ModelConfig.defaultConfig;
      
      if (config.isChatModel) {
        yield* _generateChat(prompt, config);
      } else {
        yield* _generateCompletion(prompt, config);
      }
    } catch (e) {
      yield "Generation error: $e";
    } finally {
      _isGenerating = false;
    }
  }

  Stream<String> _generateChat(String prompt, ModelConfig config) async* {
    final messages = [
      ChatMessage(role: 'system', content: 'You are a helpful AI assistant.'),
      ChatMessage(role: 'user', content: prompt),
    ];

    int tokenCount = 0;
    String lastFewTokens = '';

    await for (final token in _controller!.generateChat(
      messages: messages,
      template: config.template ?? _getTemplateString(_currentModel!.templateType),
      temperature: config.temperature,
      topP: 0.95,
      topK: 40,
      maxTokens: config.maxTokens,
    )) {
      if (!_isGenerating) break;

      tokenCount++;
      lastFewTokens = _updateLastTokens(lastFewTokens, token);
      yield token;

      if (_shouldStopGeneration(lastFewTokens, tokenCount, config)) {
        break;
      }
    }
  }

  Stream<String> _generateCompletion(String prompt, ModelConfig config) async* {
    final simplePrompt = 'Question: $prompt\nAnswer:';
    
    int tokenCount = 0;
    String lastFewTokens = '';

    await for (final token in _controller!.generate(
      prompt: simplePrompt,
      temperature: config.temperature,
      topP: 0.95,
      topK: 40,
      maxTokens: config.maxTokens,
    )) {
      if (!_isGenerating) break;

      tokenCount++;
      lastFewTokens = _updateLastTokens(lastFewTokens, token);
      yield token;

      if (_shouldStopGeneration(lastFewTokens, tokenCount, config)) {
        break;
      }
    }
  }

  String _updateLastTokens(String lastTokens, String newToken) {
    final updated = (lastTokens + newToken);
    return updated.length > 30 ? updated.substring(updated.length - 30) : updated;
  }

  bool _shouldStopGeneration(String lastTokens, int tokenCount, ModelConfig config) {
    for (final stopSeq in config.stopSequences) {
      if (lastTokens.contains(stopSeq)) return true;
    }
    if (tokenCount >= config.maxTokens - 10) return true;
    return false;
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
      case TemplateType.qwen:
        return 'qwen';
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

class ModelConfig {
  final bool isChatModel;
  final int maxTokens;
  final double temperature;
  final List<String> stopSequences;
  final String? template;

  const ModelConfig({
    required this.isChatModel,
    required this.maxTokens,
    required this.temperature,
    required this.stopSequences,
    this.template,
  });

  static const ModelConfig defaultConfig = ModelConfig(
    isChatModel: true,
    maxTokens: 256,
    temperature: 0.7,
    stopSequences: ['\n\n'],
  );
}