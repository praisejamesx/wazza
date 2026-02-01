// lib/screens/account_screen.dart
import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          _AccountTile(
            title: 'Subscription',
            subtitle: 'Free Plan',
            onTap: () => _showUpgradeDialog(context),
          ),
          const _AccountTile(
            title: 'Usage Today',
            subtitle: '3 / 10 messages',
          ),
          const Divider(height: 1),
          _AccountTile(
            title: 'Help & About',
            subtitle: 'How Wazza works',
            onTap: () => _showHelpPage(context),
          ),
          _AccountTile(
            title: 'Share Wazza Models',
            subtitle: 'Send a model to a friend',
            onTap: () => _shareApp(context),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Go Pro'),
        content: const Text('Unlock unlimited messages and larger models.'),
        actions: [
          TextButton(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
          ElevatedButton(onPressed: () {}, child: const Text('Upgrade')),
        ],
      ),
    );
  }

  void _showHelpPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Help & About')),
          body: const Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wazza', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text(
                  '• Runs AI models entirely on your device\n'
                  '• No internet required after download\n'
                  '• No account, no tracking\n'
                  '• Share models directly with friends',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    // Basic sharing of app info
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share feature coming soon!')),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _AccountTile({required this.title, this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }
}