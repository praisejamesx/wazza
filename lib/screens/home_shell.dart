import 'package:flutter/material.dart';
import 'package:wazza/screens/chat_list_screen.dart';
import 'package:wazza/screens/models_screen.dart';
import 'package:wazza/screens/account_screen.dart';
import 'package:wazza/models/ai_model.dart';

class HomeShell extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const HomeShell({super.key, this.onToggleTheme, required this.isDarkMode});

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
    await Future.delayed(const Duration(milliseconds: 100));

    if (AIModel.downloadedModels.isEmpty) {
      setState(() {
        _currentScreen = WelcomeScreen(onGoToModels: _goToModelsScreen);
        _title = 'Wazza';
        _isLoading = false;
      });
    } else {
      setState(() {
        _currentScreen = ChatListScreen(onGoToModels: _goToModelsScreen);
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
    final isDark = widget.isDarkMode;

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
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.white : Colors.black),
              ),
            )
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
    final isDark = widget.isDarkMode;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(Icons.smart_toy, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Wazza',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Free, Offline & Private AI',
                  style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
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
              _switchTo(AccountScreen(onToggleTheme: widget.onToggleTheme, isDarkMode: isDark), 'Account');
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
            trailing: Switch(
              value: isDark,
              onChanged: (_) => widget.onToggleTheme?.call(),
            ),
            onTap: () => widget.onToggleTheme?.call(),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            Text(
              'Wazza',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Free, Offline & Private AI.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey),
            ),
            const SizedBox(height: 40),
            FilledButton.tonal(
              onPressed: onGoToModels,
              child: const Text('Download Your First Model'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('How it works')),
                      body: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• Runs AI models entirely on your device\n'
                              '• No internet required after download\n'
                              '• No account, no tracking\n'
                              '• Share models directly with friends\n'
                              '• All data stays on your phone',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'Tips:',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '• Long-press any message to copy, delete, or regenerate\n'
                              '• Tap the globe icon to enable web search\n'
                              '• Use the microphone button for voice input\n'
                              '• Tap the speaker icon on AI messages for text-to-speech\n'
                              '• Long-press the chat title to edit the system prompt',
                              style: TextStyle(fontSize: 14),
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
