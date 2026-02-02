// main.dart - UPDATED VERSION
import 'package:flutter/material.dart';
import 'package:wazza/screens/home_shell.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize database
    final db = DBService();
    await db.database; // Initialize DB
    
    // Load downloaded models from DB
    AIModel.downloadedModels = await db.getDownloadedModels();
    
    // ✅ CRITICAL: Sync remoteModels with downloaded state
    AIModel.syncWithDownloadedModels(AIModel.downloadedModels);
    
    runApp(const WazzaApp());
  } catch (e) {
    // If DB fails, start with empty models
    debugPrint('DB init error: $e');
    AIModel.downloadedModels = [];
    runApp(const WazzaApp());
  }
}

class WazzaApp extends StatelessWidget {
  const WazzaApp({super.key});

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
      home: const HomeShell(),
    );
  }
}