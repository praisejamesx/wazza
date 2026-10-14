import 'package:wazza/core/llm/inference_config.dart';

class ContextManager {
  static int estimateTokens(String text) {
    return (text.length / 4).ceil();
  }

  static List<Map<String, String>> buildContext({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    required InferenceConfig config,
    String? webContext,
  }) {
    final result = <Map<String, String>>[];
    int tokenCount = 0;

    // Reserve tokens for system prompt + response
    final systemTokens = estimateTokens(systemPrompt);
    tokenCount += systemTokens;
    result.add({'role': 'system', 'content': systemPrompt});

    // Add web context if available
    if (webContext != null && webContext.isNotEmpty) {
      final webTokens = estimateTokens(webContext);
      if (tokenCount + webTokens < config.contextSize * 0.7) {
        tokenCount += webTokens;
        result.add({'role': 'system', 'content': 'Relevant web search results:\n$webContext\n\nUse these if relevant to answer the user question.'});
      }
    }

    // Reserve 30% for response generation
    final availableForHistory = (config.contextSize * 0.7 - tokenCount).toInt();
    
    // Add messages from most recent, fitting in budget
    final recentMessages = messages.length > config.historyWindow
        ? messages.sublist(messages.length - config.historyWindow)
        : messages;

    final selectedMessages = <Map<String, String>>[];
    int historyTokens = 0;

    for (var i = recentMessages.length - 1; i >= 0; i--) {
      final msg = recentMessages[i];
      final msgTokens = estimateTokens(msg['content'] ?? '');
      if (historyTokens + msgTokens > availableForHistory) break;
      historyTokens += msgTokens;
      selectedMessages.insert(0, msg);
    }

    result.addAll(selectedMessages);
    return result;
  }
}
