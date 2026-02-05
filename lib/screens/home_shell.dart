// lib/screens/home_shell.dart - COMPLETE VERSION
import 'package:flutter/material.dart';
import 'package:wazza/screens/chat_list_screen.dart';
import 'package:wazza/screens/models_screen.dart';
import 'package:wazza/screens/account_screen.dart';
import 'package:wazza/models/ai_model.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  Widget? _currentScreen;
  String _title = 'Wazza';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInitialScreen();
  }

  void _goToModelsScreen() {
    _switchTo(const ModelsScreen(), 'Models');
  }

  void _goToChatScreen() {
    _switchTo(
      ChatListScreen(onGoToModels: _goToModelsScreen),
      'Chats',
    );
  }

  Future<void> _loadInitialScreen() async {
    // Small delay to ensure everything is loaded
    await Future.delayed(const Duration(milliseconds: 100));

    if (AIModel.downloadedModels.isEmpty) {
      setState(() {
        _currentScreen = WelcomeScreen(onGoToModels: _goToModelsScreen); // Pass callback
        _title = 'Wazza';
        _isLoading = false;
      });
    } else {
      setState(() {
        _currentScreen = ChatListScreen(onGoToModels: _goToModelsScreen); // Pass callback
        _title = 'Chats';
        _isLoading = false;
      });
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
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _currentScreen ?? _buildDefaultScreen(),
    );
  }

  Widget _buildDefaultScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Something went wrong'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialScreen,
            child: const Text('Restart App'),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.white),
            child: Text(
              'Wazza',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              _loadInitialScreen();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('Chats'),
            onTap: () {
              _goToChatScreen();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text('Models'),
            onTap: () {
              _goToModelsScreen();
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
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  final VoidCallback onGoToModels;
  const WelcomeScreen({super.key, required this.onGoToModels});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Wazza',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Free, Offline & Private AI.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            FilledButton.tonal(
              onPressed: onGoToModels, // Uses the callback now
              child: const Text('Download Your First Model'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('How it works')),
                      body: const Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• Runs AI models entirely on your device\n'
                              '• No internet required after download\n'
                              '• No account, no tracking\n'
                              '• Share models directly with friends\n'
                              '• All data stays on your phone',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              child: const Text('How does this work?'),
            ),
          ],
        ),
      ),
    );
  }
}