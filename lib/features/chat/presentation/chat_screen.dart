import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wazza/core/llm/inference_config.dart';
import 'package:wazza/core/providers.dart';
import 'package:wazza/core/voice/voice_service.dart';
import 'package:wazza/features/chat/domain/message.dart';
import 'package:wazza/features/chat/presentation/controllers/chat_controller.dart';
import 'package:wazza/features/models/domain/ai_model.dart';
import 'package:wazza/features/models/presentation/controllers/models_controller.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String chatId;
  const ChatScreen({super.key, required this.chatId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  AIModel? _selectedModel;
  bool _isModelLoading = false;
  String? _modelError;
  bool _isVoiceListening = false;
  bool _ttsEnabled = false;
  bool _wasGenerating = false;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadModel([AIModel? model]) async {
    final downloaded = ref.read(downloadedModelsProvider).valueOrNull ?? [];
    if (downloaded.isEmpty) {
      setState(() => _modelError = 'No model downloaded yet. Open Models to download one.');
      return;
    }

    final target = model ?? _selectedModel ?? downloaded.first;
    _selectedModel = target;

    final path = target.localPath;
    if (path == null || path.isEmpty) {
      setState(() => _modelError = 'Model file missing. Re-download it from Models.');
      return;
    }

    setState(() {
      _isModelLoading = true;
      _modelError = null;
    });

    try {
      final engine = ref.read(llamaEngineProvider);
      await engine.loadModel(path, config: InferenceConfig.forModel(target.id));
      if (mounted) setState(() => _isModelLoading = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          _modelError = e.toString();
          _isModelLoading = false;
        });
      }
    }
  }

  bool get _isNearBottom {
    if (!_scrollController.hasClients) return true;
    final position = _scrollController.position;
    return position.maxScrollExtent - position.pixels < 160;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatControllerProvider(widget.chatId));

    // Auto-scroll as tokens stream in, but never yank the view while the user
    // has scrolled up to read earlier messages.
    ref.listen(chatControllerProvider(widget.chatId), (previous, next) {
      if (_isNearBottom) _scrollToBottom();
    });

    // Read the final answer aloud when speech output is enabled.
    if (_wasGenerating && !chatState.isGenerating && _ttsEnabled) {
      Message? lastAssistant;
      for (final m in chatState.messages) {
        if (!m.isUser) lastAssistant = m;
      }
      final spoken = lastAssistant?.text;
      if (spoken != null && spoken.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(voiceServiceProvider).speak(spoken);
        });
      }
    }
    _wasGenerating = chatState.isGenerating;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/chats'),
        ),
        titleSpacing: 0,
        title: _ModelTitle(
          model: _selectedModel,
          isLoading: _isModelLoading,
          onTap: () => _showModelPicker(),
        ),
        actions: [
          IconButton(
            icon: Icon(_ttsEnabled ? Icons.volume_up : Icons.volume_off),
            onPressed: () => setState(() => _ttsEnabled = !_ttsEnabled),
            tooltip: _ttsEnabled ? 'Spoken replies on' : 'Spoken replies off',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear') {
                ref.read(chatControllerProvider(widget.chatId).notifier).clearMessages();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'clear', child: Text('Clear messages')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList(chatState)),
          if (_modelError != null) _buildErrorBanner(),
          if (_isModelLoading)
            const _StatusBar(label: 'Loading model…')
          else if (chatState.isGenerating)
            _buildGeneratingBar()
          else
            _buildInputBar(chatState),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: scheme.errorContainer,
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: scheme.onErrorContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _modelError!,
              style: TextStyle(fontSize: 12.5, color: scheme.onErrorContainer),
            ),
          ),
          TextButton(onPressed: () => _loadModel(), child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatState chatState) {
    if (chatState.messages.isEmpty) {
      return _EmptyChat(modelName: _selectedModel?.name);
    }

    final messages = chatState.messages;
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isLast = index == messages.length - 1;
        return _MessageBubble(
          key: ValueKey('${message.id}-$index'),
          message: message,
          isStreaming: isLast && chatState.isGenerating && !message.isUser,
        );
      },
    );
  }

  Widget _buildGeneratingBar() {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Text('Generating…')),
          IconButton(
            icon: const Icon(Icons.stop_circle_outlined),
            onPressed: () =>
                ref.read(chatControllerProvider(widget.chatId).notifier).stopGeneration(),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(ChatState chatState) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 6,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              enabled: _selectedModel != null,
              decoration: const InputDecoration(
                hintText: 'Message',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(
              _isVoiceListening ? Icons.mic : Icons.mic_none,
              color: _isVoiceListening ? scheme.error : scheme.onSurfaceVariant,
            ),
            onPressed: _selectedModel == null ? null : _toggleVoiceInput,
            tooltip: 'Voice input',
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (context, value, _) {
              final canSend = value.text.trim().isNotEmpty && _selectedModel != null;
              return _SendButton(enabled: canSend, onPressed: _sendMessage);
            },
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty || _selectedModel == null) return;
    _controller.clear();
    ref.read(chatControllerProvider(widget.chatId).notifier).sendMessage(
          text,
          model: _selectedModel!,
        );
    _scrollToBottom();
  }

  Future<void> _toggleVoiceInput() async {
    final voiceService = ref.read(voiceServiceProvider);
    if (_isVoiceListening) {
      await voiceService.stopListening();
      setState(() => _isVoiceListening = false);
      if (voiceService.lastWords.isNotEmpty) {
        _controller.text = voiceService.lastWords;
        _controller.selection = TextSelection.collapsed(
          offset: _controller.text.length,
        );
      }
      return;
    }

    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) return;
    setState(() => _isVoiceListening = true);
    await voiceService.startListening(
      onResult: (words) {
        setState(() {
          _controller.text = words;
          _controller.selection = TextSelection.collapsed(offset: words.length);
        });
      },
    );
  }

  void _showModelPicker() {
    final models = ref.read(downloadedModelsProvider).valueOrNull ?? [];
    if (models.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  'Choose a model',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
              for (final model in models)
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    _loadModel(model);
                  },
                  leading: Icon(
                    model.id == _selectedModel?.id
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                    size: 20,
                  ),
                  title: Text(model.name),
                  subtitle: Text('${model.quant} · ${model.sizeMB} MB'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ModelTitle extends StatelessWidget {
  final AIModel? model;
  final bool isLoading;
  final VoidCallback onTap;

  const _ModelTitle({required this.model, required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    model?.name ?? 'Chat',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    isLoading ? 'Loading…' : 'On-device',
                    style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.unfold_more, size: 16, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;
  const _SendButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: IconButton.filled(
        icon: const Icon(Icons.arrow_upward, size: 20),
        onPressed: enabled ? onPressed : null,
        style: IconButton.styleFrom(
          backgroundColor: enabled ? scheme.primary : scheme.surfaceContainerHighest,
          foregroundColor: enabled ? scheme.onPrimary : scheme.onSurfaceVariant,
          disabledBackgroundColor: scheme.surfaceContainerHighest,
          disabledForegroundColor: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String label;
  const _StatusBar({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final String? modelName;
  const _EmptyChat({this.modelName});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 40, color: scheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'Ask anything',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              modelName == null
                  ? 'Download a model to get started'
                  : 'Running $modelName entirely on this device',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isStreaming;
  const _MessageBubble({
    super.key,
    required this.message,
    this.isStreaming = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isUser = message.isUser;

    if (isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SelectableText(
            message.text,
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: 15,
              height: 1.45,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.92,
          ),
          child: message.text.isEmpty && isStreaming
              ? const _TypingDots()
              : MarkdownBody(
                  data: isStreaming ? '${message.text}▍' : message.text,
                  selectable: true,
                  styleSheet: _markdownStyle(context),
                ),
        ),
        if (!isStreaming && message.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 14, left: 4),
            child: _CopyButton(text: message.text),
          )
        else
          const SizedBox(height: 8),
      ],
    );
  }

  MarkdownStyleSheet _markdownStyle(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: TextStyle(fontSize: 15, height: 1.5, color: scheme.onSurface),
      listBullet: TextStyle(fontSize: 15, height: 1.5, color: scheme.onSurface),
      code: TextStyle(
        fontSize: 13.5,
        fontFamily: 'monospace',
        backgroundColor: scheme.surfaceContainerHighest,
        color: scheme.onSurface,
      ),
      codeblockDecoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: scheme.outline, width: 3)),
      ),
      a: TextStyle(
        color: scheme.onSurface,
        decoration: TextDecoration.underline,
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final String text;
  const _CopyButton({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
          );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.content_copy, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text('Copy', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final dots = _controller.value * 3;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final active = dots >= index && dots < index + 1;
            return Container(
              margin: const EdgeInsets.only(right: 4),
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.onSurfaceVariant.withValues(alpha: active ? 1 : 0.3),
              ),
            );
          }),
        );
      },
    );
  }
}
