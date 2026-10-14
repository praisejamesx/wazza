import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wazza/core/providers.dart';

class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _Section(
            children: [
              ListTile(
                leading: const Icon(Icons.smart_toy),
                title: const Text('Models'),
                subtitle: const Text('Download and manage AI models'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/models'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            children: [
              SwitchListTile(
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Dark Mode'),
                subtitle: const Text('Pure black and white'),
                value: isDark,
                onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About Wazza'),
                subtitle: const Text('v2.0.0  Local AI for your phone'),
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'Wazza',
                  applicationVersion: '2.0.0',
                  children: [
                    const Text('Local AI operating layer for your phone.\nAll processing happens on device.\nNo data leaves your phone.'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final List<Widget> children;
  const _Section({required this.children});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(children: children),
    );
  }
}
