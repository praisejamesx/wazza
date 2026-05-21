import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/widgets/input_bar.dart';
import 'package:wazza/widgets/message_widget.dart';
import 'package:wazza/models/message.dart';
import 'package:wazza/models/chat.dart';
import 'package:wazza/services/llm_service.dart';
import 'package:wazza/services/db_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';

class ChatScreen extends StatefulWidget {
  final AIModel? initialModel;
  final Chat? existingChat;
  const ChatScreen({super.key, this.initialModel, this.existingChat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final DBService _dbService = DBService();
  final Random _random = Random();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final ImagePicker _imagePicker = ImagePicker();

  AIModel? _selectedModel;
  bool _isGenerating = false;
  bool _modelReady = false;
  String? _modelError;
  bool _modelLoading = false;
  late String _chatId;
  Chat? _currentChat;
  StreamSubscription<String>? _generationSubscription;
  bool _useSearch = false;
  bool _isListening = false;
  bool _showScrollButton = false;
  bool _isSearchingWeb = false;
  String? _systemPrompt;

  String _generateChatId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _initializeModel();
    _scrollController.addListener(_onScroll);
    _loadSystemPrompt();
  }

  @override
  void dispose() {
    _generationSubscription?.cancel();
    LLMService().stop();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final nearBottom = (maxScroll - currentScroll) < 150;
    if (nearBottom != !_showScrollButton) {
      setState(() => _showScrollButton = !nearBottom);
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _maybeAutoScroll() {
    if (_scrollController.hasClients && !_showScrollButton) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _loadSystemPrompt() async {
    final prompt = await _dbService.getSystemPrompt(_chatId);
    if (mounted && prompt != null) {
      setState(() => _systemPrompt = prompt);
    }
  }

  Future<void> _editSystemPrompt() async {
    final controller = TextEditingController(text: _systemPrompt ?? await _dbService.getDefaultSystemPrompt());
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('System Prompt'),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: controller,
            maxLines: 8,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter system prompt...',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await _dbService.saveDefaultSystemPrompt(controller.text.trim());
              await _dbService.saveSystemPrompt(_chatId, controller.text.trim());
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Save as Default'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && mounted) {
      setState(() => _systemPrompt = result);
      await _dbService.saveSystemPrompt(_chatId, result);
    }
  }

  Future<void> _initializeChat() async {
    if (widget.existingChat != null) {
      _chatId = widget.existingChat!.id;
      _currentChat = widget.existingChat;
      final messages = await _dbService.getMessages(_chatId);
      if (mounted) {
        setState(() => _messages.addAll(messages));
      }
    } else {
      _chatId = _generateChatId();
      _currentChat = Chat(
        id: _chatId,
        title: 'New Chat',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _dbService.saveChat(_currentChat!);
    }
  }

  Future<void> _initializeModel() async {
    setState(() {
      _modelLoading = true;
      _modelError = null;
      _modelReady = false;
    });

    try {
      _selectedModel = widget.initialModel ??
          (AIModel.downloadedModels.isNotEmpty ? AIModel.downloadedModels[0] : null);

      if (_selectedModel == null) {
        throw Exception('No model available');
      }

      final file = File(_selectedModel!.localPath!);
      if (!await file.exists()) {
        throw Exception('Model file missing');
      }

      await LLMService().loadModel(_selectedModel!);

      if (mounted) {
        setState(() {
          _modelReady = true;
          _modelLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _modelError = e.toString().split('\n').first;
          _modelLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final xFile = await _imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
      if (xFile == null) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image attached (vision support coming soon)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  Future<void> _startVoiceInput() async {
    final available = await _speech.initialize();
    if (!available) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Speech recognition not available')),
        );
      }
      return;
    }

    setState(() => _isListening = true);

    try {
      await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            final text = _textController.text.trim();
            final newText = text.isEmpty
                ? result.recognizedWords
                : '$text ${result.recognizedWords}';
            _textController.text = newText;
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
          } else {
            final text = _textController.text.trim();
            final baseText = text.isEmpty ? '' : text;
            final words = result.recognizedWords;
            _textController.text = baseText.isEmpty ? words : '$baseText $words';
            _textController.selection = TextSelection.fromPosition(
              TextPosition(offset: _textController.text.length),
            );
          }
        },
        listenFor: const Duration(seconds: 30),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Voice error: $e')),
        );
      }
    }
  }

  void _stopVoiceInput() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  void _toggleListening() {
    if (_isListening) {
      _stopVoiceInput();
    } else {
      _startVoiceInput();
    }
  }

  void _sendMessage() async {
    if (_isGenerating) {
      _stopGeneration();
      return;
    }

    if (!_modelReady || _selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model is not ready yet. Please wait.')),
      );
      return;
    }

    final text = _textController.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();
    _textController.clear();

    final useSearch = _useSearch;
    setState(() => _useSearch = false);

    setState(() {
      _messages.add(Message(text: text, isUser: true, timestamp: DateTime.now().millisecondsSinceEpoch));
      _isGenerating = true;
      _isSearchingWeb = false;
    });

    await _dbService.saveMessage(_chatId, Message(text: text, isUser: true));

    if (_messages.length == 1 && _currentChat?.title == 'New Chat') {
      final newTitle = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      await _dbService.updateChatTitle(_chatId, newTitle);
      if (mounted) {
        setState(() => _currentChat = _currentChat?.copyWith(title: newTitle));
      }
    }

    try {
      final stream = LLMService().generateWithContext(
        text,
        _messages.where((m) => m.isUser || m.text.isNotEmpty).toList(),
        useSearch: useSearch,
        systemPromptOverride: _systemPrompt,
      );

      String fullResponse = '';
      bool streamStarted = false;

      _generationSubscription = stream.listen((token) {
        if (token == '_SEARCHING_') {
          if (mounted) setState(() => _isSearchingWeb = true);
          return;
        }
        if (token == '_SEARCH_DONE_' || token == '_SEARCH_FAILED_') {
          if (mounted) setState(() => _isSearchingWeb = false);
          return;
        }

        fullResponse += token;

        if (!mounted) return;

        setState(() {
          if (_messages.isNotEmpty && !_messages.last.isUser && streamStarted) {
            _messages[_messages.length - 1] = Message(
              text: fullResponse,
              isUser: false,
              timestamp: DateTime.now().millisecondsSinceEpoch,
            );
          } else {
            streamStarted = true;
            _messages.add(Message(
              text: fullResponse,
              isUser: false,
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ));
          }
        });
        _maybeAutoScroll();
      }, onDone: () async {
        if (fullResponse.isNotEmpty) {
          await _dbService.saveMessage(_chatId, Message(text: fullResponse, isUser: false));
        }
        if (mounted) {
          setState(() => _isGenerating = false);
        }
      }, onError: (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString().split('\n').first}')),
          );
          setState(() {
            _isGenerating = false;
            _isSearchingWeb = false;
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().split('\n').first}')),
      );
      setState(() {
        _isGenerating = false;
        _isSearchingWeb = false;
      });
    }
  }

  void _stopGeneration() {
    _generationSubscription?.cancel();
    LLMService().stop();
    if (mounted) {
      setState(() {
        _isGenerating = false;
        _isSearchingWeb = false;
      });
    }
  }

  Future<void> _copyMessage(Message msg) async {
    await Clipboard.setData(ClipboardData(text: msg.text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Copied'), duration: Duration(seconds: 1)),
      );
    }
  }

  Future<void> _deleteMessage(int index) async {
    final msg = _messages[index];
    if (msg.id > 0) {
      await _dbService.deleteMessage(msg.id);
    }
    if (mounted) {
      setState(() => _messages.removeAt(index));
    }
  }

  Future<void> _regenerateResponse(int index) async {
    if (index < 1 || _messages[index].isUser) return;

    final userMsgIndex = index - 1;
    if (userMsgIndex < 0 || !_messages[userMsgIndex].isUser) return;

    final prompt = _messages[userMsgIndex].text;

    setState(() {
      _messages.removeAt(index);
      _isGenerating = true;
    });

    try {
      final stream = LLMService().generateWithContext(
        prompt,
        _messages.where((m) => m.isUser || m.text.isNotEmpty).toList(),
        systemPromptOverride: _systemPrompt,
      );

      String fullResponse = '';
      bool streamStarted = false;

      _generationSubscription = stream.listen((token) {
        if (token.startsWith('_SEARCH')) return;
        fullResponse += token;
        if (!mounted) return;

        setState(() {
          if (_messages.isNotEmpty && !_messages.last.isUser && streamStarted) {
            _messages[_messages.length - 1] = Message(
              text: fullResponse,
              isUser: false,
              timestamp: DateTime.now().millisecondsSinceEpoch,
            );
          } else {
            streamStarted = true;
            _messages.add(Message(
              text: fullResponse,
              isUser: false,
              timestamp: DateTime.now().millisecondsSinceEpoch,
            ));
          }
        });
        _maybeAutoScroll();
      }, onDone: () async {
        if (fullResponse.isNotEmpty) {
          await _dbService.saveMessage(_chatId, Message(text: fullResponse, isUser: false));
        }
        if (mounted) setState(() => _isGenerating = false);
      }, onError: (e) {
        if (mounted) {
          setState(() => _isGenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      });
    } catch (e) {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _showMessageActions(int index) {
    if (index < 0 || index >= _messages.length) return;
    final msg = _messages[index];

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                _copyMessage(msg);
              },
            ),
            if (!msg.isUser)
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Regenerate'),
                onTap: () {
                  Navigator.pop(context);
                  _regenerateResponse(index);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteMessage(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onLongPress: _editSystemPrompt,
          child: Text(_currentChat?.title ?? 'Chat'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _useSearch ? Icons.language : Icons.language_outlined,
              color: _useSearch ? Colors.blue : null,
            ),
            tooltip: _useSearch ? 'Search enabled' : 'Search disabled',
            onPressed: () => setState(() => _useSearch = !_useSearch),
          ),
          FutureBuilder<int>(
            future: _dbService.getMessagesUsedInCurrentPeriod(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    '$count',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _messages.isEmpty && _modelError == null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat, size: 48, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                              const SizedBox(height: 16),
                              Text(
                                'Start typing...',
                                style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (_modelError != null ? 1 : 0) + (_isSearchingWeb ? 1 : 0),
                          itemBuilder: (context, index) {
                            int offset = 0;

                            if (_modelError != null) {
                              if (index == 0) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(_modelError!)),
                                    ],
                                  ),
                                );
                              }
                              offset = 1;
                            }

                            final msgIndex = index - offset;

                            if (_isSearchingWeb && msgIndex == _messages.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                    SizedBox(width: 12),
                                    Text('Searching web...'),
                                  ],
                                ),
                              );
                            }

                            if (msgIndex >= _messages.length) return const SizedBox.shrink();

                            return _MessageActionWrapper(
                              message: _messages[msgIndex],
                              index: msgIndex,
                              onLongPress: () => _showMessageActions(msgIndex),
                              child: MessageWidget(
                                message: _messages[msgIndex],
                                onTap: msgIndex > 0 && !_messages[msgIndex].isUser
                                    ? () => _showMessageActions(msgIndex)
                                    : null,
                              ),
                            );
                          },
                        ),
                ),
                if (_modelLoading)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 12),
                        Text('Loading model...', style: TextStyle(color: isDark ? Colors.grey[400] : null)),
                      ],
                    ),
                  )
                else if (_modelReady && _selectedModel != null)
                  InputBar(
                    controller: _textController,
                    onSend: _sendMessage,
                    selectedModel: _selectedModel!,
                    onModelSelected: (model) {
                      setState(() {
                        _selectedModel = model;
                        _modelReady = false;
                        _modelError = null;
                      });
                      _initializeModel();
                    },
                    isGenerating: _isGenerating,
                    isListening: _isListening,
                    onToggleListening: _toggleListening,
                    useSearch: _useSearch,
                    onToggleSearch: () => setState(() => _useSearch = !_useSearch),
                    onPickImage: _pickImage,
                  )
                else if (_modelError != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_modelError!)),
                        TextButton(
                          onPressed: _initializeModel,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No model selected. Download one first.',
                      style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey),
                    ),
                  ),
              ],
            ),
            if (_showScrollButton)
              Positioned(
                right: 16,
                bottom: 100,
                child: FloatingActionButton.small(
                  heroTag: 'scroll_to_bottom',
                  onPressed: _scrollToBottom,
                  child: const Icon(Icons.arrow_downward),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageActionWrapper extends StatelessWidget {
  final Message message;
  final int index;
  final VoidCallback onLongPress;
  final Widget child;

  const _MessageActionWrapper({
    required this.message,
    required this.index,
    required this.onLongPress,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: child,
    );
  }
}
