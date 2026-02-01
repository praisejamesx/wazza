import 'package:flutter/material.dart';
import 'package:wazza/screens/home_shell.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/db_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = DBService();
  AIModel.downloadedModels = await db.getDownloadedModels();
  runApp(const WazzaApp());
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
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
      ),
      home: const HomeShell(),
    );
  }
}