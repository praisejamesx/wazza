import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wazza/app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as dev;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;
  final defaultPrompt = prefs.getString('default_system_prompt');

  // Set default system prompt if not set
  if (defaultPrompt == null) {
    await prefs.setString('default_system_prompt', 'You are a helpful, accurate assistant. Be concise and factual.');
  }

  dev.log('[Wazza] Starting app...');
  
  runApp(ProviderScope(
    child: WazzaApp(initialDarkMode: isDark),
  ));
}
