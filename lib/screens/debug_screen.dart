// lib/screens/debug_screen.dart (temporary)
import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
// import 'package:wazza/services/db_service.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug Info')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Downloaded Models:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...AIModel.downloadedModels.map((model) => Card(
            child: ListTile(
              title: Text(model.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ID: ${model.id}'),
                  Text('Path: ${model.localPath ?? "No path"}'),
                  Text('Size: ${model.sizeMB} MB'),
                  if (model.localPath != null) 
                    FutureBuilder<bool>(
                      future: File(model.localPath!).exists(),
                      builder: (context, snapshot) => Text(
                        'File exists: ${snapshot.data ?? false}',
                        style: TextStyle(
                          color: snapshot.data == true ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )),
          
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              final dir = await getApplicationDocumentsDirectory();
              final modelsDir = Directory('${dir.path}/models');
              if (await modelsDir.exists()) {
                final files = await modelsDir.list().toList();
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Files in models directory'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView(
                        shrinkWrap: true,
                        children: files.map((file) => Text(file.path)).toList(),
                      ),
                    ),
                  ),
                );
              }
            },
            child: const Text('Check Models Directory'),
          ),
        ],
      ),
    );
  }
}

