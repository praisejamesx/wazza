// lib/screens/home_shell.dart
import 'package:flutter/material.dart';
import 'package:wazza/screens/chat_list_screen.dart';
import 'package:wazza/screens/models_screen.dart';
import 'package:wazza/screens/account_screen.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/share_service.dart';
import 'dart:io';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  Widget _currentScreen = const ChatListScreen();
  String _title = 'Chats';

  @override
  void initState() {
    super.initState();
    _checkForSharedModel();
  }

  Future<void> _checkForSharedModel() async {
    final path = await ShareService.getSharedModelPath();
    if (path != null && path.endsWith('.gguf')) {
      _registerReceivedModel(path);
    }
  }

  Future<void> _registerReceivedModel(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final modelName = fileName.replaceFirst('.gguf', '');

      // 🔥 CRITICAL: Auto-detect templateType from filename
      final templateType = AIModel.inferTemplate(modelName);

      final fileSizeMB = (await File(filePath).length()) ~/ (1024 * 1024);

      // Create model with correct templateType
      final model = AIModel(
        id: modelName,
        name: modelName,
        sizeMB: fileSizeMB,
        quant: 'Q4_K_M',
        isDownloaded: true,
        localPath: filePath,
        templateType: templateType, // ✅ REQUIRED for flutter_llama
      );

      AIModel.downloadedModels.add(model);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Model imported: $modelName')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import failed: $e')),
      );
    }
  }

  void _switchTo(Widget screen, String title) {
    setState(() {
      _currentScreen = screen;
      _title = title;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        leading: Builder(builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        )),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Text('Wazza', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Chats'),
              onTap: () {
                _switchTo(const ChatListScreen(), 'Chats');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Models'),
              onTap: () {
                _switchTo(const ModelsScreen(), 'Models');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle_outlined),
              title: const Text('Account'),
              onTap: () {
                _switchTo(const AccountScreen(), 'Account');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: _currentScreen,
    );
  }
}