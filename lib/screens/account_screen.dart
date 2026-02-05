// lib/screens/account_screen.dart - FREE MODE VERSION
import 'package:flutter/material.dart';
import 'package:wazza/services/db_service.dart';
import 'package:wazza/screens/models_screen.dart';
import 'package:wazza/config/app_config.dart'; // ADD THIS

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

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
    
    setState(() {
      _usedMessages = used;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Subscription'),
            subtitle: AppConfig.isFreeMode
                ? const Text('Free Plan (Unlimited)')
                : const Text('Free Plan (50 messages/day)'),
            // Remove onTap in free mode
            onTap: AppConfig.showUpgradeOptions ? () => _showUpgradeDialog(context) : null,
          ),
          _loading 
            ? const ListTile(title: Text('Loading usage...'))
            : ListTile(
                title: const Text('Usage This Period'),
                subtitle: AppConfig.isFreeMode
                    ? Text('$_usedMessages messages sent')
                    : Text('$_usedMessages / ${AppConfig.freeTierLimit} messages'),
              ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Help & About'),
            subtitle: const Text('How Wazza works'),
            onTap: () => _showHelpPage(context),
          ),
          ListTile(
            title: const Text('Share Models'),
            subtitle: const Text('Send a model to a friend'),
            onTap: () => _navigateToModels(context),
          ),
          // Only show upgrade option if not in free mode
          if (AppConfig.showUpgradeOptions) ...[
            ListTile(
              title: const Text('Upgrade Plan'),
              subtitle: const Text('Unlock unlimited messages'),
              onTap: () => _showPaymentNotice(context),
            ),
          ],
        ],
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    if (AppConfig.isFreeMode) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Free & Open Source'),
          content: const Text('Wazza is now completely free and open source! Enjoy unlimited messages.'),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop, 
              child: const Text('Awesome!')
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Go Pro'),
          content: const Text('Unlock unlimited messages and access to larger models.'),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop, 
              child: const Text('Cancel')
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text('Upgrade')
            ),
          ],
        ),
      );
    }
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

  void _navigateToModels(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ModelsScreen(),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Click the share icon beside a downloaded model to share it!')),
    );
  }

  void _showPaymentNotice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment integration coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}