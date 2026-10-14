import 'dart:async';
import 'package:llama_flutter_android/llama_flutter_android.dart';
import 'package:wazza/core/llm/inference_config.dart';
import 'dart:developer' as dev;

class LlamaEngine {
  static final LlamaEngine _instance = LlamaEngine._();
  factory LlamaEngine() => _instance;
  LlamaEngine._();

  LlamaController? _controller;
  String? _loadedModelPath;
  bool _isGenerating = false;
  
  bool get isLoaded => _controller != null;
  bool get isGenerating => _isGenerating;
  String? get loadedModelPath => _loadedModelPath;

  Future<void> loadModel(String modelPath, {InferenceConfig? config}) async {
    if (_loadedModelPath == modelPath && _controller != null) {
      dev.log('[LlamaEngine] Model already loaded: $modelPath');
      return;
    }

    await dispose();

    final effectiveConfig = config ?? InferenceConfig.defaultConfig;
    dev.log('[LlamaEngine] Loading model: $modelPath (threads: ${effectiveConfig.threads}, ctx: ${effectiveConfig.contextSize})');
    _controller = LlamaController();
    await _controller!.loadModel(
      modelPath: modelPath,
      contextSize: effectiveConfig.contextSize,
      threads: effectiveConfig.threads,
    );
    _loadedModelPath = modelPath;
    dev.log('[LlamaEngine] Model loaded successfully');
  }

  Stream<String> generate({
    required List<ChatMessage> messages,
    required String template,
    double temperature = 0.7,
    double topP = 0.95,
    int topK = 40,
    double minP = 0.05,
    double repeatPenalty = 1.1,
    int maxTokens = 512,
  }) async* {
    if (_controller == null) {
      yield 'Error: No model loaded';
      return;
    }

    _isGenerating = true;

    try {
      // The native layer keeps a single KV cache that persists across calls,
      // and every chat template re-emits its BOS marker. Because we always
      // send the *entire* conversation, we must clear the native context first,
      // otherwise each turn duplicates the whole history into the cache (which
      // makes generation slower and slower and leaks context between chats).
      await _controller!.clearContext();

      final stream = _controller!.generateChat(
        messages: messages,
        template: template,
        temperature: temperature,
        topP: topP,
        topK: topK,
        minP: minP,
        repeatPenalty: repeatPenalty,
        maxTokens: maxTokens,
      );

      await for (final token in stream) {
        if (!_isGenerating) break;
        yield token;
      }
    } catch (e) {
      yield 'Error: $e';
    } finally {
      _isGenerating = false;
    }
  }

  void stop() {
    _isGenerating = false;
    _controller?.stop();
  }

  Future<void> dispose() async {
    stop();
    await _controller?.dispose();
    _controller = null;
    _loadedModelPath = null;
  }
}
