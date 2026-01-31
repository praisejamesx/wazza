// lib/services/llm_service.dart
import 'dart:async';
import 'package:flutter_llama/flutter_llama.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/db_service.dart';
import 'dart:io';

class LLMService {
  FlutterLlama? _llama;
  AIModel? _currentModel;
  bool _isGenerating = false;

  static final LLMService _instance = LLMService._internal();
  factory LLMService() => _instance;
  LLMService._internal();

  Future<void> loadModel(AIModel model) async {
    if (_currentModel?.id == model.id && _llama != null) return;

    // Unload previous model if any
    if (_llama != null) {
      await _llama!.unloadModel();
      // No need to null _llama since it's a singleton, but we can recreate for clarity
      _llama = null;
    }

    if (model.localPath == null || !await File(model.localPath!).exists()) {
      throw Exception('Model file not found at ${model.localPath}');
    }

    _llama = FlutterLlama.instance;  // Use the singleton

    final config = LlamaConfig(
      modelPath: model.localPath!,
      nThreads: 4,              // Reasonable for low-end phones (adjust based on device)
      nGpuLayers: -1,           // Full offload if GPU available (Metal/Vulkan)
      contextSize: 2048,        // Safe starting point; 1024–4096 for low RAM
      batchSize: 512,
      useGpu: true,             // Auto-falls back to CPU if no GPU accel
      verbose: false,           // Quieter on mobile
    );

    final success = await _llama!.loadModel(config);
    if (!success) {
      throw Exception('Failed to load model');
    }

    _currentModel = model;
  }

  Stream<String> generate(String prompt) async* {
    if (_isGenerating || _llama == null) {
      yield "Model not loaded or busy.";
      return;
    }

    final db = DBService();
    final count = await db.getMessageCountToday();
    if (count >= DBService.freeTierLimit) {
      yield "Daily limit reached.";
      return;
    }
    await db.incrementMessageCount();

    _isGenerating = true;

    // Manual formatting based on model templateType
    final formattedPrompt = _formatPrompt(prompt, _currentModel!.templateType);

    try {
      final params = GenerationParams(
        prompt: formattedPrompt,
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxTokens: 512,
        repeatPenalty: 1.1,
      );

      await for (final token in _llama!.generateStream(params)) {
        if (!_isGenerating) break;
        yield token;
      }
    } catch (e) {
      yield "Error: $e";
    } finally {
      _isGenerating = false;
    }
  }

  String _formatPrompt(String userPrompt, TemplateType type) {
    const systemPrompt = 'You are a helpful, accurate assistant. Stick to facts.';  // Helps reduce hallucinations

    switch (type) {
      case TemplateType.chatml:  // Qwen, many others
        return '<|im_start|>system\n$systemPrompt<|im_end|>\n<|im_start|>user\n$userPrompt<|im_end|>\n<|im_start|>assistant\n';
      case TemplateType.llama2:  // TinyLlama, older Llama variants
        return '[INST] <<SYS>> $systemPrompt <</SYS>> $userPrompt [/INST]';
      case TemplateType.phi:     // Phi-3 / Phi series
        return '<|system|> $systemPrompt <|end|>\n<|user|> $userPrompt <|end|>\n<|assistant|>';
      case TemplateType.gemma:   // Gemma
        return '<start_of_turn>system $systemPrompt <end_of_turn>\n<start_of_turn>user $userPrompt <end_of_turn>\n<start_of_turn>model';
      case TemplateType.llama3:  // Llama-3 style, MobileLLaMA etc.
        return '<|begin_of_text|><|start_header_id|>system<|end_header_id|> $systemPrompt <|eot_id|><|start_header_id|>user<|end_header_id|> $userPrompt <|eot_id|><|start_header_id|>assistant<|end_header_id|>';
    }
  }

  void stop() {
    _isGenerating = false;
    // No explicit stop/cancel in the basic API; generation stops when stream is no longer awaited
    // If the package adds a stop() method in future, call it here
  }

  Future<void> unload() async {  // Renamed for clarity; call this instead of dispose
    if (_llama != null) {
      await _llama!.unloadModel();
      _llama = null;  // Optional, since singleton, but helps GC
    }
  }
}