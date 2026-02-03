// lib/screens/chat_screen.dart - NO UUID VERSION
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/widgets/input_bar.dart';
import 'package:wazza/widgets/message_widget.dart';
import 'package:wazza/models/message.dart';
import 'package:wazza/models/chat.dart';
import 'package:wazza/services/llm_service.dart';
import 'package:wazza/services/db_service.dart';

class ChatScreen extends StatefulWidget {
  final AIModel? initialModel;
  final Chat? existingChat; // For continuing existing chats
  const ChatScreen({super.key, this.initialModel, this.existingChat});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final DBService _dbService = DBService();
  final Random _random = Random();
  
  AIModel? _selectedModel;
  bool _isGenerating = false;
  bool _modelReady = false;
  String? _modelError;
  bool _modelLoading = false;
  String _chatId = ''; // Will be set based on existing or new chat
  Chat? _currentChat;
  StreamSubscription<String>? _generationSubscription;

  // Helper to generate unique ID without uuid package
  String _generateChatId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(16, (index) => chars[_random.nextInt(chars.length)]).join();
  }

  @override
  void initState() {
    super.initState();
    _initializeChat();
    _initializeModel();
  }

  @override
  void dispose() {
    _generationSubscription?.cancel();
    LLMService().stop();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    if (widget.existingChat != null) {
      // Load existing chat
      _chatId = widget.existingChat!.id;
      _currentChat = widget.existingChat;
      
      // Load messages from database
      final messages = await _dbService.getMessages(_chatId);
      if (mounted) {
        setState(() {
          _messages.addAll(messages);
        });
      }
    } else {
      // Create new chat
      _chatId = _generateChatId();
      _currentChat = Chat(
        id: _chatId,
        title: 'New Chat',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      
      // Save new chat to database
      await _dbService.saveChat(_currentChat!);
    }
  }

  Future<void> _initializeModel() async {
    try {
      setState(() {
        _modelLoading = true;
        _modelError = null;
        _modelReady = false;
      });

      _selectedModel = widget.initialModel ??
          (AIModel.downloadedModels.isNotEmpty
              ? AIModel.downloadedModels[0]
              : null);

      if (_selectedModel == null) {
        setState(() {
          _modelError = 'No model available. Please download one first.';
          _modelReady = false;
          _modelLoading = false;
        });
        return;
      }

      if (_selectedModel!.localPath == null || 
          _selectedModel!.localPath!.isEmpty) {
        setState(() {
          _modelError = 'Model file path is missing.';
          _modelReady = false;
          _modelLoading = false;
        });
        return;
      }

      final fileExists = await File(_selectedModel!.localPath!).exists();
      if (!fileExists) {
        setState(() {
          _modelError = 'Model file not found on device.';
          _modelReady = false;
          _modelLoading = false;
        });
        return;
      }

      // Try to load model with a timeout
      final loadFuture = LLMService().loadModel(_selectedModel!);
      final timeoutFuture = Future.delayed(const Duration(seconds: 5), () {
        throw TimeoutException('Model loading timed out after 5 seconds');
      });

      await Future.any([loadFuture, timeoutFuture]);
      
      setState(() {
        _modelReady = true;
        _modelLoading = false;
        _modelError = null;
      });
      
    } on TimeoutException catch (_) {
      setState(() {
        _modelError = 'Model loading timed out. File may be corrupted or wrong format.';
        _modelReady = false;
        _modelLoading = false;
      });
    } catch (e) {
      setState(() {
        _modelError = 'Failed to load model: ${e.toString().split('\n').first}';
        _modelReady = false;
        _modelLoading = false;
      });
    }
  }

  void _sendMessage() async {
    if (!_modelReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Model is not ready yet. Please wait.')),
      );
      return;
    }

    if (_isGenerating) {
      _stopGeneration();
      return;
    }

    final text = _textController.text.trim();
    if (text.isEmpty) return;
    if (_selectedModel == null) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _textController.clear();
      _isGenerating = true;
    });

    // Save user message to database
    await _dbService.saveMessage(_chatId, Message(text: text, isUser: true));

    // Update chat title if it's the first message
    if (_messages.length == 1 && _currentChat?.title == 'New Chat') {
      final newTitle = text.length > 30 ? '${text.substring(0, 30)}...' : text;
      await _dbService.updateChatTitle(_chatId, newTitle);
      if (mounted) {
        setState(() {
          _currentChat = _currentChat?.copyWith(title: newTitle);
        });
      }
    }

    try {
      // Use generateWithContext instead of generate
      final stream = LLMService().generateWithContext(text, _messages);
      String fullResponse = '';

      _generationSubscription = stream.listen((token) {
        fullResponse += token;
        
        if (!mounted) return;
        
        setState(() {
          if (_messages.isNotEmpty && !_messages.last.isUser) {
            // Update existing AI message
            _messages[_messages.length - 1] = Message(text: fullResponse, isUser: false);
          } else {
            // Add new AI message
            _messages.add(Message(text: fullResponse, isUser: false));
          }
        });
      }, onDone: () async {
        // Save final AI response to database
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
          setState(() => _isGenerating = false);
        }
      });

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().split('\n').first}')),
      );
      setState(() => _isGenerating = false);
    }
  }

  void _stopGeneration() {
    _generationSubscription?.cancel();
    LLMService().stop();
    setState(() {
      _isGenerating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentChat?.title ?? 'Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          // Display messages used count
          FutureBuilder<int>(
            future: _dbService.getMessagesUsedInCurrentPeriod(),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: Text(
                    '$count/${DBService.freeTierLimit}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty && _modelError == null
                  ? const Center(child: Text('Start a conversation'))
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (_modelError != null)
                          Container(
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
                          ),
                        ..._messages.map((message) => MessageWidget(message: message)),
                        if (_isGenerating && _messages.isNotEmpty && _messages.last.isUser)
                          const MessageWidget(
                            message: Message(text: '...', isUser: false),
                          ),
                      ],
                    ),
            ),
            
            // Show loading indicator
            if (_modelLoading)
              Container(
                padding: const EdgeInsets.all(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading model...'),
                  ],
                ),
              )
            // Show input bar when model is ready
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
              )
            // Show error with retry button
            else if (_modelError != null)
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey[100],
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
            // No model available
            else
              Container(
                padding: const EdgeInsets.all(16),
                child: const Text('No model selected. Download one first.'),
              ),
          ],
        ),
      ),
    );
  }
}