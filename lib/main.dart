// main.dart - CLEAN VERSION
import 'package:flutter/material.dart';
import 'package:wazza/screens/home_shell.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/db_service.dart';
import 'dart:developer' as developer;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WazzaApp());
}

class WazzaApp extends StatefulWidget {
  const WazzaApp({super.key});

  @override
  State<WazzaApp> createState() => _WazzaAppState();
}

class _WazzaAppState extends State<WazzaApp> {
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeAppAsync();
  }

  Future<void> _initializeAppAsync() async {
    try {
      developer.log('[WazzaApp] Starting initialization...');
      
      // Initialize database service
      final db = DBService();
      
      // Check and recover any models from filesystem
      developer.log('[WazzaApp] Checking for existing models...');
      await db.checkAndRecoverModels();
      
      // Load downloaded models from DB
      AIModel.downloadedModels = await db.getDownloadedModels();
      developer.log('[WazzaApp] Loaded ${AIModel.downloadedModels.length} models from DB');
      
      // Sync remoteModels with downloaded state
      AIModel.syncWithDownloadedModels(AIModel.downloadedModels);
      developer.log('[WazzaApp] Model sync complete');
      
      setState(() {
        _isInitializing = false;
      });
      
      developer.log('[WazzaApp] Initialization complete');
    } catch (e) {
      developer.log('[WazzaApp] Init error: $e');
      setState(() {
        _isInitializing = false;
        _initError = e.toString();
      });
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
        useMaterial3: true,
      ),
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
    
    return const HomeShell();
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
            const SizedBox(height: 24),
            const Text(
              'Loading Wazza...',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Models found: ${AIModel.downloadedModels.length}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            if (AIModel.downloadedModels.isEmpty) ...[
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'No models found. Download models from settings.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
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
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 24),
              const Text(
                'Initialization Error',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Failed to start the app',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFCCCCCC)),
                ),
                child: Text(
                  error.length > 200 ? '${error.substring(0, 200)}...' : error,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontFamily: 'monospace',
                  ),
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
                      setState(() {
                        _initError = null;
                      });
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