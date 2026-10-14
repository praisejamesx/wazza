import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wazza/features/home/presentation/home_shell.dart';
import 'package:wazza/features/chat/presentation/chat_list_screen.dart';
import 'package:wazza/features/chat/presentation/chat_screen.dart';
import 'package:wazza/features/models/presentation/models_screen.dart';
import 'package:wazza/features/account/presentation/account_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const _HomeRedirect(),
          ),
          GoRoute(
            path: '/chats',
            builder: (context, state) => const ChatListScreen(),
          ),
          GoRoute(
            path: '/chat/:id',
            builder: (context, state) => ChatScreen(chatId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/models',
            builder: (context, state) => const ModelsScreen(),
          ),
          GoRoute(
            path: '/account',
            builder: (context, state) => const AccountScreen(),
          ),
        ],
      ),
    ],
  );
});

class _HomeRedirect extends ConsumerWidget {
  const _HomeRedirect();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go('/chats');
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
