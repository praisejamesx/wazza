import 'package:flutter/material.dart';
import 'package:wazza/screens/home_shell.dart';

void main() => runApp(const WazzaApp());

class WazzaApp extends StatelessWidget {
  const WazzaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wazza',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        fontFamily: 'IBMPlexMono',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.white, foregroundColor: Colors.black),
      ),
      home: const HomeShell(),
    );
  }
}