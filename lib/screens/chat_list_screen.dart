// lib/screens/chat_list_screen.dart - FIXED VERSION
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/models/chat.dart';
import 'package:wazza/services/db_service.dart';
import 'package:wazza/screens/chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final VoidCallback onGoToModels;
  const ChatListScreen({super.key, required this.onGoToModels});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<Chat> _chats = [];
  bool _isLoading = true;
  final DBService _dbService = DBService();

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  Future<void> _loadChats() async {
    setState(() {
      _isLoading = true;
    });
    
    final chats = await _dbService.getChats();
    
    if (mounted) {
      setState(() {
        _chats = chats;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteChat(BuildContext context, Chat chat) async {
    // Store the context locally before async operations
    final currentContext = context;
    
    final confirmed = await showDialog<bool>(
      context: currentContext,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chat'),
        content: Text('Are you sure you want to delete "${chat.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _dbService.deleteChat(chat.id);
      await _loadChats();
    }
  }

  Future<void> _renameChat(BuildContext context, Chat chat) async {
    // Store the context locally before async operations
    final currentContext = context;
    final controller = TextEditingController(text: chat.title);
    
    final newTitle = await showDialog<String>(
      context: currentContext,
      builder: (context) => AlertDialog(
        title: const Text('Rename Chat'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter new title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty && newTitle != chat.title && mounted) {
      await _dbService.updateChatTitle(chat.id, newTitle);
      await _loadChats();
    }
  }

  Future<AIModel?> _getDefaultModel() async {
    final models = AIModel.downloadedModels;
    if (models.isNotEmpty) {
      return models[0];
    }
    return null;
  }

  void _startNewChat(BuildContext context, AIModel? model) {
    if (model == null) {
      widget.onGoToModels();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please download a model first')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(initialModel: model),
      ),
    );
  }

  void _openChat(Chat chat) async {
    final model = await _getDefaultModel();
    
    if (!mounted) return;
    
    if (model == null) {
      widget.onGoToModels();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please download a model first')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          existingChat: chat,
          initialModel: model,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: widget.onGoToModels,
            tooltip: 'Download Models',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final model = await _getDefaultModel();
          if (mounted) {
            _startNewChat(context, model);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chats.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadChats,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _chats.length,
                    itemBuilder: (context, index) {
                      final chat = _chats[index];
                      final time = DateTime.fromMillisecondsSinceEpoch(chat.createdAt);
                      final timeString = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
                      
                      return Dismissible(
                        key: Key(chat.id),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        confirmDismiss: (direction) async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Chat'),
                              content: Text('Are you sure you want to delete "${chat.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          return confirmed ?? false;
                        },
                        onDismissed: (direction) async {
                          await _dbService.deleteChat(chat.id);
                          if (mounted) {
                            await _loadChats();
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.chat, size: 20),
                            ),
                            title: Text(
                              chat.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              'Created at $timeString',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'rename') {
                                  _renameChat(context, chat);
                                } else if (value == 'delete') {
                                  _deleteChat(context, chat);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'rename',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Rename'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, size: 20, color: Colors.red),
                                      SizedBox(width: 8),
                                      Text('Delete', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            onTap: () => _openChat(chat),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No Chats Yet',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a conversation by tapping the + button',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: widget.onGoToModels,
            icon: const Icon(Icons.download),
            label: const Text('Download a Model'),
          ),
        ],
      ),
    );
  }
}