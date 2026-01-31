// lib/screens/chat_screen.dart
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

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel ??
        (AIModel.downloadedModels.isNotEmpty
            ? AIModel.downloadedModels[0]
            : AIModel.remoteModels[0]);
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || _selectedModel == null) return;

    setState(() {
      _messages.add(Message(text: text, isUser: true));
      _textController.clear();
    });

    LLMService().loadModel(_selectedModel!);
    final stream = LLMService().generate(text);
    String fullResponse = '';

    stream.listen(
      (token) {
        fullResponse = token;
        if (!mounted) return;
        setState(() {
          if (_messages.isNotEmpty && !_messages.last.isUser) {
            _messages[_messages.length - 1] = Message(text: fullResponse, isUser: false);
          } else {
            _messages.add(Message(text: fullResponse, isUser: false));
          }
        });
      },
      onError: (err, stack) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $err')));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[_messages.length - 1 - index];
              return MessageWidget(message: message);
            },
          ),
        ),
        InputBar(
          controller: _textController,
          onSend: _sendMessage,
          selectedModel: _selectedModel!,
          onModelSelected: (model) => setState(() => _selectedModel = model),
        ),
      ],
    );
  }
}