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
  Widget? _currentScreen;
  String _title = 'Wazza';

  @override
  void initState() {
    super.initState();
    _checkForSharedModel();
    _loadInitialScreen();
  }

  Future<void> _loadInitialScreen() async {
    // Show welcome screen if no models downloaded
    if (AIModel.downloadedModels.isEmpty) {
      setState(() => _currentScreen = const WelcomeScreen());
    } else {
      setState(() => _currentScreen = const ChatListScreen());
    }
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
      final templateType = AIModel.inferTemplate(modelName);
      final fileSizeMB = (await File(filePath).length()) ~/ (1024 * 1024);

      final model = AIModel(
        id: modelName,
        name: modelName,
        sizeMB: fileSizeMB,
        quant: 'Q4_K_M',
        isDownloaded: true,
        localPath: filePath,
        templateType: templateType,
        description: '',
        bestFor: ''
      );

      AIModel.downloadedModels.add(model);
      _loadInitialScreen(); // Refresh UI

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
                      decoration: BoxDecoration(color: Colors.white),
                      child: Text('Wazza', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home),
                      title: const Text('Home'),
                      onTap: () {
                        _loadInitialScreen();
                        Navigator.pop(context);
                      }
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
      body: _currentScreen ?? const Center(child: CircularProgressIndicator()),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.jpg',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            const Text(
              'Wazza',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Private AI. Offline. No Nonsense.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            FilledButton.tonal(
              onPressed: () {
                final homeState = context.findAncestorStateOfType<_HomeShellState>();
                homeState?._switchTo(const ModelsScreen(), 'Models');
              },
              child: const Text('Download Your First Model'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {},
              child: const Text('How does this work?'),
            ),
          ],
        ),
      ),
    );
  }
}