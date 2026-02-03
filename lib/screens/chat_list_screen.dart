import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/db_service.dart';
import 'package:wazza/screens/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final VoidCallback onGoToModels;
  const ChatListScreen({super.key, required this.onGoToModels}); // ADD PARAMETER

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List> _future;

  @override
  void initState() {
    super.initState();
    _future = Future.wait([DBService().getChats(), _loadDefaultModel()]);
  }

  Future<AIModel?> _loadDefaultModel() async {
    if (AIModel.downloadedModels.isNotEmpty) {
      return AIModel.downloadedModels[0];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final chats = snapshot.data![0] as List;
        final defaultModel = snapshot.data![1] as AIModel?;

        if (chats.isEmpty && defaultModel == null) {
          return WelcomeScreen(onGoToModels: widget.onGoToModels); // USE CALLBACK
        }

        return ListView.builder(
          itemCount: chats.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return ListTile(
                title: const Text('New Chat'),
                leading: const Icon(Icons.add),
                onTap: () => _startChat(context, defaultModel!),
              );
            }
            final chat = chats[index - 1];
            return ListTile(title: Text(chat.title));
          },
        );
      },
    );
  }

  void _startChat(BuildContext context, AIModel model) {
    Navigator.push(context, MaterialPageRoute(builder: (c) => ChatScreen(initialModel: model)));
  }
}

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGoToModels; // ADD THIS
  const WelcomeScreen({super.key, required this.onGoToModels}); // ADD REQUIRED PARAMETER

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Wazza', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Private AI. No internet. No tracking.', textAlign: TextAlign.center),
          const SizedBox(height: 32),
          OutlinedButton(
            // USE THE CALLBACK, NOT Navigator.push
            onPressed: onGoToModels,
            child: const Text('Download a Model'),
          ),
        ],
      ),
    );
  }
}