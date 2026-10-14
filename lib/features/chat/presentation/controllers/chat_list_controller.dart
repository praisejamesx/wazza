import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazza/core/providers.dart';
import 'package:wazza/features/chat/domain/chat.dart';

final chatListProvider = StreamNotifierProvider<ChatListController, List<Chat>>(ChatListController.new);

class ChatListController extends StreamNotifier<List<Chat>> {
  @override
  Stream<List<Chat>> build() {
    return ref.watch(chatRepositoryProvider).watchChats();
  }

  Future<Chat> createChat({String? title, String? modelId}) async {
    return ref.read(chatRepositoryProvider).createChat(title: title, modelId: modelId);
  }

  Future<void> updateTitle(String chatId, String title) async {
    await ref.read(chatRepositoryProvider).updateTitle(chatId, title);
  }

  Future<void> deleteChat(String chatId) async {
    await ref.read(chatRepositoryProvider).deleteChat(chatId);
  }

  Future<void> togglePin(String chatId) async {
    await ref.read(chatRepositoryProvider).togglePin(chatId);
  }

  Future<List<Chat>> searchChats(String query) async {
    return ref.read(chatRepositoryProvider).searchChats(query);
  }
}
