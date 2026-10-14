import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazza/app_router.dart';
import 'package:wazza/core/providers.dart';
import 'package:wazza/core/theme/app_theme.dart';

class WazzaApp extends ConsumerStatefulWidget {
  final bool initialDarkMode;
  const WazzaApp({super.key, required this.initialDarkMode});

  @override
  ConsumerState<WazzaApp> createState() => _WazzaAppState();
}

class _WazzaAppState extends ConsumerState<WazzaApp> {
  @override
  void initState() {
    super.initState();
    ref.read(darkModeProvider.notifier).initialize(widget.initialDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: 'Wazza',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
