import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazza/core/providers.dart';
import 'package:wazza/features/chat/domain/message.dart';
import 'package:wazza/core/llm/context_manager.dart';
import 'package:wazza/core/llm/inference_config.dart';
import 'package:wazza/features/models/domain/ai_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:llama_flutter_android/llama_flutter_android.dart';

class ChatState {
  final List<Message> messages;
  final bool isGenerating;
  final bool isSearchingWeb;
  final String? error;
  final String? systemPrompt;

  ChatState({
    this.messages = const [],
    this.isGenerating = false,
    this.isSearchingWeb = false,
    this.error,
    this.systemPrompt,
  });

  ChatState copyWith({
    List<Message>? messages,
    bool? isGenerating,
    bool? isSearchingWeb,
    String? error,
    String? systemPrompt,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isGenerating: isGenerating ?? this.isGenerating,
      isSearchingWeb: isSearchingWeb ?? this.isSearchingWeb,
      error: error,
      systemPrompt: systemPrompt ?? this.systemPrompt,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;
  final String chatId;
  StreamSubscription<String>? _subscription;

  ChatController(this.ref, this.chatId) : super(ChatState()) {
    _loadMessages();
    _loadSystemPrompt();
  }

  Future<void> _loadMessages() async {
    final messages = await ref.read(messageRepositoryProvider).getMessages(chatId);
    state = state.copyWith(messages: messages);
  }

  Future<void> _loadSystemPrompt() async {
    final chat = await ref.read(chatRepositoryProvider).getChats();
    final current = chat.where((c) => c.id == chatId).firstOrNull;
    if (current?.systemPrompt != null) {
      state = state.copyWith(systemPrompt: current!.systemPrompt);
    } else {
      final prefs = await SharedPreferences.getInstance();
      final defaultPrompt = prefs.getString('default_system_prompt') ?? 'You are a helpful, accurate assistant. Be concise and factual.';
      state = state.copyWith(systemPrompt: defaultPrompt);
    }
  }

  Future<void> updateSystemPrompt(String prompt) async {
    state = state.copyWith(systemPrompt: prompt);
    await ref.read(chatRepositoryProvider).updateSystemPrompt(chatId, prompt);
  }

  Future<void> sendMessage(String text, {required AIModel model, bool useSearch = false}) async {
    if (state.isGenerating || text.trim().isEmpty) return;

    final userMessage = Message(
      chatId: chatId,
      text: text.trim(),
      isUser: true,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    // Save and add user message
    await ref.read(messageRepositoryProvider).saveMessage(chatId, userMessage);
    state = state.copyWith(messages: [...state.messages, userMessage], isGenerating: true, error: null);

    // Auto-title on first message
    if (state.messages.length <= 1) {
      final title = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      await ref.read(chatRepositoryProvider).updateTitle(chatId, title);
    }

    try {
      // Web search if enabled
      String? webContext;
      if (useSearch) {
        state = state.copyWith(isSearchingWeb: true);
        try {
          final results = await ref.read(searchEngineProvider).searchWithRewrite(text);
          webContext = ref.read(searchEngineProvider).formatForLLM(results);
        } catch (_) {}
        state = state.copyWith(isSearchingWeb: false);
      }

      // Build context
      final messages = state.messages.map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text}).toList();
      final config = InferenceConfig.forModel(model.id);
      final contextMessages = ContextManager.buildContext(
        systemPrompt: state.systemPrompt ?? 'You are a helpful assistant.',
        messages: messages,
        config: config,
        webContext: webContext,
      );

      // Generate
      final chatMessages = contextMessages.map((m) => ChatMessage(
        role: m['role'] ?? 'user',
        content: m['content'] ?? '',
      )).toList();
      final engine = ref.read(llamaEngineProvider);

      final template = _getTemplateName(model);

      final buffer = StringBuffer();
      final currentMessages = List<Message>.from(state.messages);
      int tokenCount = 0;
      await for (final token in engine.generate(
        messages: chatMessages,
        template: template,
        temperature: config.temperature,
        topP: config.topP,
        topK: config.topK,
        minP: config.minP,
        repeatPenalty: config.repeatPenalty,
        maxTokens: config.maxTokens,
      )) {
        if (!mounted) return;
        buffer.write(token);
        tokenCount++;

        final fullResponse = buffer.toString();

        if (currentMessages.isNotEmpty && !currentMessages.last.isUser) {
          currentMessages[currentMessages.length - 1] = currentMessages.last.copyWith(text: fullResponse);
        } else {
          currentMessages.add(Message(
            chatId: chatId,
            text: fullResponse,
            isUser: false,
            createdAt: DateTime.now().millisecondsSinceEpoch,
          ));
        }

        // Batch state updates: every 3 tokens or on stream end
        if (tokenCount % 3 == 0) {
          state = state.copyWith(messages: List<Message>.from(currentMessages));
        }
      }

      // Final state update with complete response
      final finalResponse = buffer.toString();
      state = state.copyWith(messages: List<Message>.from(currentMessages));

      // Save assistant message
      if (finalResponse.isNotEmpty) {
        await ref.read(messageRepositoryProvider).saveMessage(chatId, Message(
          chatId: chatId,
          text: finalResponse,
          isUser: false,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ));
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isGenerating: false);
    }
  }

  void stopGeneration() {
    ref.read(llamaEngineProvider).stop();
    state = state.copyWith(isGenerating: false);
  }

  Future<void> clearMessages() async {
    stopGeneration();
    await ref.read(messageRepositoryProvider).clearMessages(chatId);
    state = state.copyWith(messages: const [], error: null);
  }

  String _getTemplateName(AIModel model) {
    switch (model.templateType) {
      case TemplateType.phi: return 'phi';
      case TemplateType.gemma: return 'gemma';
      case TemplateType.llama2: return 'llama2';
      case TemplateType.llama3: return 'llama3';
      case TemplateType.qwen: return 'chatml';
      case TemplateType.smol: return 'chatml';
      case TemplateType.chatml: return 'chatml';
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    ref.read(llamaEngineProvider).stop();
    super.dispose();
  }
}

final chatControllerProvider = StateNotifierProvider.family<ChatController, ChatState, String>((ref, chatId) {
  return ChatController(ref, chatId);
});
