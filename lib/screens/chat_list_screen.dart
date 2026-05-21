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
  List<Chat> _filteredChats = [];
  bool _isLoading = true;
  final DBService _dbService = DBService();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadChats() async {
    setState(() => _isLoading = true);
    final chats = await _dbService.getChats();
    if (mounted) {
      setState(() {
        _chats = chats;
        _filteredChats = chats;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
      if (query.isEmpty) {
        _filteredChats = _chats;
      } else {
        final lower = query.toLowerCase();
        _filteredChats = _chats.where((c) =>
          c.title.toLowerCase().contains(lower)
        ).toList();
      }
    });
  }

  Future<void> _deleteChat(Chat chat) async {
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

    if (confirmed == true && mounted) {
      await _dbService.deleteChat(chat.id);
      await _loadChats();
    }
  }

  Future<void> _renameChat(Chat chat) async {
    final controller = TextEditingController(text: chat.title);
    final newTitle = await showDialog<String>(
      context: context,
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
    if (models.isNotEmpty) return models[0];
    return null;
  }

  void _startNewChat(AIModel? model) {
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
    ).then((_) => _loadChats());
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
        builder: (context) => ChatScreen(existingChat: chat, initialModel: model),
      ),
    ).then((_) => _loadChats());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          if (mounted) _startNewChat(model);
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark ? Colors.grey[800] : Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredChats.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _isSearching ? Icons.search_off : Icons.chat,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _isSearching ? 'No chats found' : 'No Chats Yet',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            if (!_isSearching) ...[
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
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadChats,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: _filteredChats.length,
                          itemBuilder: (context, index) {
                            final chat = _filteredChats[index];
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
                                if (mounted) await _loadChats();
                              },
                              child: Card(
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                color: isDark ? Colors.grey[850] : null,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isDark ? Colors.grey[700] : null,
                                    child: Icon(Icons.chat, size: 20, color: isDark ? Colors.white : null),
                                  ),
                                  title: Text(
                                    chat.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : null,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${chat.messageCount} msgs • $timeString',
                                    style: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[600]),
                                  ),
                                  trailing: PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'rename') {
                                        _renameChat(chat);
                                      } else if (value == 'delete') {
                                        _deleteChat(chat);
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
          ),
        ],
      ),
    );
  }
}
