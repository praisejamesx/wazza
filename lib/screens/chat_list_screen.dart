// lib/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/db_service.dart';
import 'package:wazza/screens/models_screen.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

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
          return const WelcomeScreen();
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
  const WelcomeScreen({super.key});

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
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ModelsScreen()),
            ),
            child: const Text('Download a Model'),
          ),
        ],
      ),
    );
  }
}