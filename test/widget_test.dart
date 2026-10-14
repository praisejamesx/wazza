import 'package:flutter_test/flutter_test.dart';
import 'package:wazza/core/llm/context_manager.dart';
import 'package:wazza/core/llm/inference_config.dart';

void main() {
  group('InferenceConfig', () {
    test('threads stay within a safe range', () {
      final config = InferenceConfig.defaultConfig;
      expect(config.threads, greaterThanOrEqualTo(2));
      expect(config.threads, lessThanOrEqualTo(4));
    });

    test('large models get a smaller context and output budget', () {
      final small = InferenceConfig.forModel('qwen2.5-1.5b-instruct');
      final large = InferenceConfig.forModel('llama-3.1-8b-instruct');

      expect(large.contextSize, lessThanOrEqualTo(small.contextSize));
      expect(large.maxTokens, lessThanOrEqualTo(small.maxTokens));
      expect(large.historyWindow, lessThanOrEqualTo(small.historyWindow));
    });

    test('tiny models use a compact context window', () {
      final tiny = InferenceConfig.forModel('smollm2-360m-instruct');
      expect(tiny.contextSize, 2048);
      expect(tiny.historyWindow, 6);
    });

    test('copyWith only overrides provided values', () {
      const base = InferenceConfig(contextSize: 2048, maxTokens: 512);
      final updated = base.copyWith(maxTokens: 128);
      expect(updated.contextSize, 2048);
      expect(updated.maxTokens, 128);
    });
  });

  group('ContextManager', () {
    List<Map<String, String>> messages(int count) => List.generate(
          count,
          (index) => {
            'role': index.isEven ? 'user' : 'assistant',
            'content': 'message number $index',
          },
        );

    test('always puts the system prompt first', () {
      final context = ContextManager.buildContext(
        systemPrompt: 'You are helpful.',
        messages: messages(3),
        config: InferenceConfig.defaultConfig,
      );

      expect(context.first['role'], 'system');
      expect(context.first['content'], 'You are helpful.');
    });

    test('trims history to the configured window', () {
      const config = InferenceConfig(historyWindow: 4);
      final context = ContextManager.buildContext(
        systemPrompt: 'sys',
        messages: messages(20),
        config: config,
      );

      // 1 system prompt + at most 4 history messages
      expect(context.length, lessThanOrEqualTo(5));
      expect(context.last['content'], 'message number 19');
    });

    test('drops older messages when the token budget is exceeded', () {
      const config = InferenceConfig(contextSize: 256, historyWindow: 50);
      final longMessages = List.generate(
        10,
        (index) => {'role': 'user', 'content': 'x' * 400},
      );

      final context = ContextManager.buildContext(
        systemPrompt: 'sys',
        messages: longMessages,
        config: config,
      );

      // Should not include every message once the budget is exhausted.
      expect(context.length, lessThan(11));
    });

    test('estimateTokens grows with text length', () {
      expect(
        ContextManager.estimateTokens('a' * 40),
        greaterThan(ContextManager.estimateTokens('a' * 4)),
      );
    });
  });
}
