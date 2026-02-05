// main.dart - UPDATED
import 'package:flutter/material.dart';
import 'package:wazza/screens/home_shell.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run app immediately without blocking on DB
  runApp(const WazzaApp());
}

class WazzaApp extends StatefulWidget {
  const WazzaApp({super.key});

  @override
  State<WazzaApp> createState() => _WazzaAppState();
}

class _WazzaAppState extends State<WazzaApp> {
  // Track initialization state
  bool _isInitializing = true;
  String? _initError;

  @override
  void initState() {
    super.initState();
    _initializeAppAsync();
  }

  Future<void> _initializeAppAsync() async {
    try {
      // Don't reset database - this is what deleted your chats/models
      // Just initialize it normally
      final db = DBService();
      
      // Load models in background
      AIModel.downloadedModels = await db.getDownloadedModels();
      
      // Sync state
      AIModel.syncWithDownloadedModels(AIModel.downloadedModels);
      
      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      debugPrint('App init error: $e');
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
      ),
      home: _isInitializing
          ? _buildLoadingScreen()
          : _initError != null
              ? _buildErrorScreen(_initError!)
              : const HomeShell(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading Wazza...'),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 20),
              const Text(
                'Initialization Error',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Error: ${error.split('\n').first}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isInitializing = true;
                    _initError = null;
                  });
                  _initializeAppAsync();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}