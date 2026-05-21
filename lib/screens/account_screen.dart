import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wazza/services/db_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AccountScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final bool isDarkMode;

  const AccountScreen({super.key, this.onToggleTheme, required this.isDarkMode});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  int _usedMessages = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUsage();
  }

  Future<void> _loadUsage() async {
    setState(() => _loading = true);
    final db = DBService();
    final used = await db.getMessagesUsedInCurrentPeriod();
    if (mounted) {
      setState(() {
        _usedMessages = used;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(40),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 40),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Wazza',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              'Free • Offline • Private',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: isDark ? Colors.grey[850] : null,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.inbox),
                  title: const Text('Subscription'),
                  subtitle: const Text('Free Plan (Unlimited)'),
                ),
                const Divider(height: 1),
                _loading
                    ? const ListTile(title: Text('Loading usage...'))
                    : ListTile(
                        leading: const Icon(Icons.bar_chart),
                        title: const Text('Messages (24h)'),
                        subtitle: Text('$_usedMessages messages sent'),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: isDark ? Colors.grey[850] : null,
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                  ),
                  title: Text(isDark ? 'Light Mode' : 'Dark Mode'),
                  trailing: Switch(
                    value: isDark,
                    onChanged: (_) => widget.onToggleTheme?.call(),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Help & About'),
                  subtitle: const Text('How Wazza works'),
                  onTap: () => _showHelpPage(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpPage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Help & About')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wazza',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Free, Offline & Private AI.\n'
                  'Version 2.0.0',
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Features:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(Icons.chat, 'Chat with local AI models offline'),
                _buildFeatureItem(Icons.language, 'Web search when online'),
                _buildFeatureItem(Icons.mic, 'Voice input support'),
                _buildFeatureItem(Icons.volume_up, 'Text-to-speech for responses'),
                _buildFeatureItem(Icons.image, 'Image attachment'),
                _buildFeatureItem(Icons.dark_mode, 'Dark mode support'),
                _buildFeatureItem(Icons.search, 'Search your chats'),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Support Wazza',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Wazza is free and open source. Consider supporting development!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Card(
                  color: isDark ? Colors.grey[850] : null,
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.coffee, color: Colors.brown),
                        title: const Text('Buy Me a Coffee'),
                        subtitle: const Text('Support via Selar'),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => _launchURL(context, 'https://selar.com/showlove/praisejamesx'),
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.currency_bitcoin, color: Colors.orange),
                        title: const Text('Bitcoin'),
                        subtitle: const Text(
                          'bc1qfqp6pg6fcrf4zfndd55fvjcrregkzfalt2vfj8',
                          style: TextStyle(fontSize: 12),
                        ),
                        trailing: const Icon(Icons.copy, size: 18),
                        onTap: () => _copyToClipboard(
                          context,
                          'bc1qfqp6pg6fcrf4zfndd55fvjcrregkzfalt2vfj8',
                          'Bitcoin address copied',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _launchURL(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        _showFallbackLink(context, url);
      }
    } catch (e) {
      _showFallbackLink(context, url);
    }
  }

  void _showFallbackLink(BuildContext context, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Open: $url'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () => _copyToClipboard(context, url, 'Link copied'),
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text, String successMessage) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(successMessage), duration: const Duration(seconds: 2)),
    );
  }
}
