import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:wazza/features/chat/presentation/controllers/chat_list_controller.dart';
import 'package:wazza/features/chat/domain/chat.dart';
import 'package:wazza/core/utils/extensions.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  Widget build(BuildContext context) {
    final chatsAsync = ref.watch(chatListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search chats...', border: InputBorder.none),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text('Chats'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () => setState(() { _isSearching = !_isSearching; _searchQuery = ''; }),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewChat(context),
          ),
        ],
      ),
      body: chatsAsync.when(
        data: (chats) {
          final filtered = _searchQuery.isNotEmpty
              ? chats.where((c) => (c.title ?? '').toLowerCase().contains(_searchQuery.toLowerCase())).toList()
              : chats;

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('No chats yet', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                  const SizedBox(height: 8),
                  FilledButton.tonal(onPressed: () => _createNewChat(context), child: const Text('Start a chat')),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final chat = filtered[index];
              return _ChatTile(
                chat: chat,
                onTap: () => context.go('/chat/${chat.id}'),
                onDelete: () async {
                  await ref.read(chatListProvider.notifier).deleteChat(chat.id);
                },
                onRename: () => _showRenameDialog(context, chat),
              ).animate().fadeIn(delay: Duration(milliseconds: 30 * index), duration: 300.ms).slideX(begin: 0.05, end: 0);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _createNewChat(BuildContext context) async {
    final chat = await ref.read(chatListProvider.notifier).createChat();
    if (context.mounted) context.go('/chat/${chat.id}');
  }

  void _showRenameDialog(BuildContext context, Chat chat) {
    final controller = TextEditingController(text: chat.title);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Chat'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              ref.read(chatListProvider.notifier).updateTitle(chat.id, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _ChatTile({required this.chat, required this.onTap, required this.onDelete, required this.onRename});

  @override
  Widget build(BuildContext context) {
    final time = DateTime.fromMillisecondsSinceEpoch(chat.createdAt);

    return Dismissible(
      key: Key(chat.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Chat'),
            content: Text('Delete "${chat.title}"?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => onDelete(),
      child: ListTile(
        onTap: onTap,
        onLongPress: onRename,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
          child: Text(
            (chat.title ?? 'N')[0].toUpperCase(),
            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(chat.title ?? 'New Chat', maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text('${chat.messageCount} messages  ${time.timeAgo}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        trailing: chat.isPinned ? const Icon(Icons.push_pin, size: 16, color: Colors.grey) : null,
      ),
    );
  }
}
