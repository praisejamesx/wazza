import 'dart:io';

class InferenceConfig {
  final int contextSize;
  final int threads;
  final double temperature;
  final double topP;
  final int topK;
  final double minP;
  final double repeatPenalty;
  final int maxTokens;
  final int historyWindow;

  const InferenceConfig({
    this.contextSize = 2048,
    this.threads = 4,
    this.temperature = 0.7,
    this.topP = 0.95,
    this.topK = 40,
    this.minP = 0.05,
    this.repeatPenalty = 1.1,
    this.maxTokens = 512,
    this.historyWindow = 8,
  });

  static int get _availableCores => Platform.numberOfProcessors;

  /// Phones are almost always big.LITTLE. Feeding every core to llama.cpp
  /// starves the performance cores and makes decoding *slower*, so we stay
  /// conservative and target roughly the count of performance cores.
  static int _safeThreads(int cores) {
    if (cores <= 2) return 2;
    if (cores <= 4) return cores;
    return 4;
  }

  static InferenceConfig get defaultConfig =>
      InferenceConfig(threads: _safeThreads(_availableCores));

  static InferenceConfig forModel(String modelId) {
    final threads = _safeThreads(_availableCores);
    final id = modelId.toLowerCase();

    // Tiny / ultra-light models: small context, fast responses.
    if (id.contains('135') || id.contains('360') || id.contains('0.5b') || id.contains('smollm2_13')) {
      return InferenceConfig(
        contextSize: 2048,
        threads: threads,
        maxTokens: 512,
        historyWindow: 6,
      );
    }

    // 1.5B - 2B models: the sweet spot for most phones.
    if (id.contains('1.5b') || id.contains('1.7b') || id.contains('2b')) {
      return InferenceConfig(
        contextSize: 3072,
        threads: threads,
        maxTokens: 512,
        historyWindow: 8,
      );
    }

    // 3B-4B models: still comfortable, keep context modest.
    if (id.contains('3b') || id.contains('4b')) {
      return InferenceConfig(
        contextSize: 3072,
        threads: threads,
        maxTokens: 512,
        historyWindow: 8,
      );
    }

    // 7B+ models: memory hungry, keep context and output small to stay usable.
    if (id.contains('7b') || id.contains('8b')) {
      return InferenceConfig(
        contextSize: 2048,
        threads: threads,
        maxTokens: 384,
        historyWindow: 6,
      );
    }

    return InferenceConfig(threads: threads);
  }

  InferenceConfig copyWith({
    int? contextSize,
    int? threads,
    double? temperature,
    double? topP,
    int? topK,
    double? minP,
    double? repeatPenalty,
    int? maxTokens,
    int? historyWindow,
  }) {
    return InferenceConfig(
      contextSize: contextSize ?? this.contextSize,
      threads: threads ?? this.threads,
      temperature: temperature ?? this.temperature,
      topP: topP ?? this.topP,
      topK: topK ?? this.topK,
      minP: minP ?? this.minP,
      repeatPenalty: repeatPenalty ?? this.repeatPenalty,
      maxTokens: maxTokens ?? this.maxTokens,
      historyWindow: historyWindow ?? this.historyWindow,
    );
  }
}
