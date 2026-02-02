// lib/services/llm_service.dart - FIXED VERSION
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

  // Configuration per model type
  static const Map<String, ModelConfig> _modelConfigs = {
    'tinyllama': ModelConfig(
      isChatModel: false,
      maxTokens: 100,
      temperature: 0.2,
      stopSequences: ['\n\n', '\nUser:', '\nuser:', 'User:', 'user:'],
    ),
    'phi2': ModelConfig(
      isChatModel: true,
      maxTokens: 150,
      temperature: 0.7,
      stopSequences: ['\n\n'],
      template: 'phi',
    ),
    // Add new models here
  };

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

    try {
      // ✅ FIX: Remove parentheses - it's a const, not a method
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

  // Generate using chat template (for chat-tuned models)
  Stream<String> _generateChat(String prompt, ModelConfig config) async* {
    final messages = [
      ChatMessage(role: 'system', content: 'Answer concisely.'),
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

      // Stop if we detect stop sequences or hit token limit
      if (_shouldStopGeneration(lastFewTokens, tokenCount, config)) {
        break;
      }
    }
  }

  // Generate using completion (for base models like TinyLlama)
  Stream<String> _generateCompletion(String prompt, ModelConfig config) async* {
    // Simple prompt format for base models
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

      // Stop if we detect stop sequences or hit token limit
      if (_shouldStopGeneration(lastFewTokens, tokenCount, config)) {
        break;
      }
    }
  }

  // Helper methods
  String _updateLastTokens(String lastTokens, String newToken) {
    final updated = (lastTokens + newToken);
    // Keep last 30 characters for stop sequence detection
    return updated.length > 30 ? updated.substring(updated.length - 30) : updated;
  }

  bool _shouldStopGeneration(String lastTokens, int tokenCount, ModelConfig config) {
    // Check stop sequences
    for (final stopSeq in config.stopSequences) {
      if (lastTokens.contains(stopSeq)) {
        return true;
      }
    }

    // Check token limit
    if (tokenCount >= config.maxTokens - 10) { // Stop 10 tokens before max
      return true;
    }

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

// Configuration for each model type
class ModelConfig {
  final bool isChatModel;
  final int maxTokens;
  final double temperature;
  final List<String> stopSequences;
  final String? template; // Only for chat models

  const ModelConfig({
    required this.isChatModel,
    required this.maxTokens,
    required this.temperature,
    required this.stopSequences,
    this.template,
  });

  // ✅ Default config for unknown models - ACCESS WITHOUT PARENTHESES
  static const ModelConfig defaultConfig = ModelConfig(
    isChatModel: true, // Assume chat model by default
    maxTokens: 150,
    temperature: 0.7,
    stopSequences: ['\n\n', '\nUser:', '\nuser:'],
  );
}