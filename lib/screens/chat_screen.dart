import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/widgets/input_bar.dart';
import 'package:wazza/widgets/message_widget.dart';
import 'package:wazza/models/message.dart';
import 'package:wazza/services/llm_service.dart';

class ChatScreen extends StatefulWidget {
  final AIModel? initialModel;
  const ChatScreen({super.key, this.initialModel});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final TextEditingController _textController = TextEditingController();
  AIModel? _selectedModel;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel ??
        (AIModel.downloadedModels.isNotEmpty
            ? AIModel.downloadedModels[0]
            : null);
  }

  void _sendMessage() async {
    print('[DEBUG] _sendMessage called');
    final text = _textController.text.trim();
    if (text.isEmpty) {
      print('[DEBUG] Text is empty');
      return;
    }
    if (_selectedModel == null) {
      print('[DEBUG] No model selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No model selected')),
      );
      return;
    }
    if (_isGenerating) {
      print('[DEBUG] Already generating');
      return;
    }

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _textController.clear();
      _isGenerating = true;
    });

    try {
      print('[DEBUG] Loading model: ${_selectedModel!.name}');
      print('[DEBUG] Model path: ${_selectedModel!.localPath}');
      
      await LLMService().loadModel(_selectedModel!);
      print('[DEBUG] Model loaded successfully');
      
      final stream = LLMService().generate(text);
      print('[DEBUG] Generation stream obtained');
      
      String fullResponse = '';
      int tokenCount = 0;

      await for (final token in stream) {
        tokenCount++;
        print('[DEBUG] Token $tokenCount: ${token.length} chars');
        
        if (!mounted) return;
        
        setState(() {
          fullResponse = token;
          if (_messages.isNotEmpty && !_messages.last.isUser) {
            _messages[_messages.length - 1] = Message(text: fullResponse, isUser: false);
          } else {
            _messages.add(Message(text: fullResponse, isUser: false));
          }
        });
      }
      
      print('[DEBUG] Stream completed. Total tokens: $tokenCount');
    } catch (e, stack) {
      print('[DEBUG] Error in _sendMessage: $e');
      print('[DEBUG] Stack trace: $stack');
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      print('[DEBUG] Setting _isGenerating = false');
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea( // ← WRAP ENTIRE BODY IN SafeArea
        bottom: true, // ← CRITICAL: Protects bottom content
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? const Center(child: Text('Start a conversation'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        return MessageWidget(message: _messages[index]);
                      },
                    ),
            ),
            if (_selectedModel != null)
              InputBar(
                controller: _textController,
                onSend: _sendMessage,
                selectedModel: _selectedModel!,
                onModelSelected: (model) => setState(() => _selectedModel = model),
              )
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