// lib/services/llm_service.dart - WITH CONTEXT MEMORY
import 'dart:async';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/models/message.dart';
import 'package:wazza/services/db_service.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';

class LLMService {
  AIModel? _currentModel;
  LlamaController? _controller;
  bool _isGenerating = false;
  Completer<void>? _stopCompleter;
  StreamSubscription<String>? _generationSubscription;

  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  static const Map<String, ModelConfig> _modelConfigs = {
    'qwen1_5_1_8b': ModelConfig(
      isChatModel: true,
      maxTokens: 512,
      temperature: 0.7,
      topP: 0.95,
      topK: 40,
      stopSequences: ['<|im_end|>', '<|endoftext|>', '\n\n'],
      template: 'qwen',
    ),
    'phi2': ModelConfig(
      isChatModel: true,
      maxTokens: 512,
      temperature: 0.7,
      topP: 0.95,
      topK: 40,
      stopSequences: ['<|endoftext|>', '\n\n'],
      template: 'phi',
    ),
    'gemma2b': ModelConfig(
      isChatModel: true,
      maxTokens: 512,
      temperature: 0.7,
      topP: 0.95,
      topK: 40,
      stopSequences: ['<end_of_turn>', '<eos>', '\n\n'],
      template: 'gemma',
    ),
    'tinyllama': ModelConfig(
      isChatModel: true,
      maxTokens: 256,
      temperature: 0.7,
      topP: 0.95,
      topK: 40,
      stopSequences: ['</s>', '\n\n'],
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
        contextSize: 4096,
        threads: 4,
      );

      _currentModel = model;
    } catch (e) {
      rethrow;
    }
  }

  // MAIN METHOD WITH CONTEXT
  Stream<String> generateWithContext(String prompt, List<Message> conversationHistory) async* {
    if (_isGenerating) {
      yield "Already generating. Please wait.";
      return;
    }
    
    if (_controller == null) {
      yield "Model not loaded. Please load a model first.";
      return;
    }

    final db = DBService();
    
    // Rate limiting
    if (!await db.canSendMessage()) {
      yield "Daily free tier limit reached. Please try again tomorrow.";
      return;
    }
    
    await db.recordMessageSent();
    _isGenerating = true;
    _stopCompleter = Completer<void>();

    try {
      final config = _modelConfigs[_currentModel!.id] ?? ModelConfig.defaultConfig;
      
      // Build conversation with context
      final messages = await _buildConversationWithContext(prompt, conversationHistory, config);
      
      yield* _generateFromMessages(messages, config);
    } catch (e) {
      yield "Generation error: $e";
    } finally {
      _isGenerating = false;
      _stopCompleter = null;
      _generationSubscription?.cancel();
      _generationSubscription = null;
    }
  }

  Future<List<ChatMessage>> _buildConversationWithContext(
    String prompt, 
    List<Message> history,
    ModelConfig config,
  ) async {
    final messages = <ChatMessage>[];
    
    // Add system message
    messages.add(ChatMessage(
      role: 'system', 
      content: 'You are a helpful, friendly AI assistant. Keep responses concise and helpful.'
    ));
    
    // Add conversation history (truncated if needed)
    final maxContextTokens = 3500; // Reserve some tokens for response
    int currentTokens = _estimateTokens(messages.first.content);
    
    // Add history in reverse (newest first) until we hit token limit
    for (int i = history.length - 1; i >= 0; i--) {
      final message = history[i];
      final role = message.isUser ? 'user' : 'assistant';
      final content = message.text;
      final tokens = _estimateTokens(content) + 10; // +10 for role prefix
      
      if (currentTokens + tokens > maxContextTokens) {
        break; // Stop adding more history
      }
      
      messages.insert(1, ChatMessage(role: role, content: content));
      currentTokens += tokens;
    }
    
    // Add current prompt
    messages.add(ChatMessage(role: 'user', content: prompt));
    
    return messages;
  }

  Stream<String> _generateFromMessages(List<ChatMessage> messages, ModelConfig config) async* {
    int tokenCount = 0;
    String fullResponse = '';

    final stream = _controller!.generateChat(
      messages: messages,
      template: config.template ?? _getTemplateString(_currentModel!.templateType),
      temperature: config.temperature,
      topP: config.topP,
      topK: config.topK,
      maxTokens: config.maxTokens,
    );

    _generationSubscription = stream.listen((token) {
      // We'll handle this in the async* generator
    }, cancelOnError: true);

    await for (final token in stream) {
      // Check if stop was requested
      if (_stopCompleter?.isCompleted ?? false) {
        break;
      }

      tokenCount++;
      fullResponse += token;
      yield token;

      // Check if we should stop based on stop sequences
      for (final stopSeq in config.stopSequences) {
        if (fullResponse.endsWith(stopSeq)) {
          break;
        }
      }

      // Check max tokens
      if (tokenCount >= config.maxTokens) {
        break;
      }

      // Check for natural stopping points
      if (tokenCount > 20 && 
          (token.contains('.') || token.contains('?') || token.contains('!')) &&
          tokenCount >= config.maxTokens - 50) {
        break;
      }
    }
  }

  int _estimateTokens(String text) {
    // Rough estimation: 1 token ≈ 4 characters for English
    // This is approximate but works for limiting context
    return (text.length / 4).ceil();
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
    if (_isGenerating) {
      _stopCompleter?.complete();
      _generationSubscription?.cancel();
      _isGenerating = false;
    }
  }

  Future<void> dispose() async {
    stop();
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
  final double topP;
  final int topK;
  final List<String> stopSequences;
  final String? template;

  const ModelConfig({
    required this.isChatModel,
    required this.maxTokens,
    required this.temperature,
    this.topP = 0.95,
    this.topK = 40,
    required this.stopSequences,
    this.template,
  });

  static const ModelConfig defaultConfig = ModelConfig(
    isChatModel: true,
    maxTokens: 512,
    temperature: 0.7,
    topP: 0.95,
    topK: 40,
    stopSequences: ['\n\n'],
  );
}