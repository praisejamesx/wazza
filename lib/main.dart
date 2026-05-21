import 'package:flutter/material.dart';
import 'package:wazza/screens/home_shell.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/db_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('dark_mode') ?? false;

  runApp(WazzaApp(initialDarkMode: isDark));
}

class WazzaApp extends StatefulWidget {
  final bool initialDarkMode;
  const WazzaApp({super.key, required this.initialDarkMode});

  @override
  State<WazzaApp> createState() => _WazzaAppState();

  static _WazzaAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_WazzaAppState>();
  }
}

class _WazzaAppState extends State<WazzaApp> {
  late bool _isDarkMode;
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.initialDarkMode;
    _initializeAppAsync();
  }

  void toggleTheme() async {
    setState(() => _isDarkMode = !_isDarkMode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', _isDarkMode);
  }

  Future<void> _initializeAppAsync() async {
    try {
      developer.log('[WazzaApp] Starting initialization...');

      final db = DBService();

      developer.log('[WazzaApp] Checking for existing models...');
      await db.checkAndRecoverModels();

      AIModel.downloadedModels = await db.getDownloadedModels();
      developer.log('[WazzaApp] Loaded ${AIModel.downloadedModels.length} models from DB');

      AIModel.syncWithDownloadedModels(AIModel.downloadedModels);
      developer.log('[WazzaApp] Model sync complete');

      if (mounted) {
        setState(() => _isInitializing = false);
      }

      developer.log('[WazzaApp] Initialization complete');
    } catch (e) {
      developer.log('[WazzaApp] Init error: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _initError = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wazza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        cardTheme: const CardThemeData(
          elevation: 0.5,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF121212),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 0.5,
        ),
        useMaterial3: true,
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _buildHome(),
    );
  }

  Widget _buildHome() {
    if (_isInitializing) {
      return _buildLoadingScreen();
    }

    if (_initError != null) {
      return _buildErrorScreen(_initError!);
    }

    return HomeShell(onToggleTheme: toggleTheme, isDarkMode: _isDarkMode);
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(_isDarkMode ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Wazza...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: _isDarkMode ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Models found: ${AIModel.downloadedModels.length}',
              style: TextStyle(
                fontSize: 14,
                color: _isDarkMode ? Colors.grey[500] : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (AIModel.downloadedModels.isEmpty) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'No models found. Download models from settings.',
                  style: TextStyle(
                    fontSize: 13,
                    color: _isDarkMode ? Colors.grey[500] : Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.red, size: 64),
              const SizedBox(height: 24),
              const Text(
                'Initialization Error',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to start the app',
                style: TextStyle(fontSize: 16, color: _isDarkMode ? Colors.grey[400] : Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                ),
                child: Text(
                  error.length > 200 ? '${error.substring(0, 200)}...' : error,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isInitializing = true;
                        _initError = null;
                      });
                      _initializeAppAsync();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {
                      setState(() => _initError = null);
                    },
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Continue Anyway'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
