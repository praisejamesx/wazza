// lib/screens/models_screen.dart
import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/model_downloader.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wazza/services/db_service.dart';
import 'dart:io' show Platform;

class ModelsScreen extends StatelessWidget {
  const ModelsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Models')),
      body: ListView(
        children: [
          if (AIModel.downloadedModels.isNotEmpty) ...[
            const _SectionHeader('DOWNLOADED MODELS'),
            ...AIModel.downloadedModels.map((m) => _DownloadedModelCard(model: m)),
            const Divider(height: 1),
          ],
          const _SectionHeader('BROWSE MODELS'),
          ...AIModel.remoteModels.map((m) => _RemoteModelCard(model: m)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    );
  }
}

class _DownloadedModelCard extends StatelessWidget {
  final AIModel model;
  const _DownloadedModelCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        title: Text(model.name),
        subtitle: Text('${model.sizeMB} MB • ${model.quant}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.share, size: 18),
              onPressed: () => _shareModel(context, model),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: () {
                AIModel.downloadedModels.remove(model);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${model.name} deleted')),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareModel(BuildContext context, AIModel model) async {
    if (model.localPath == null || !Platform.isAndroid) return;
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(model.localPath!)],
          subject: 'Wazza Model',
          title: 'Share Model',
        ),
      );
      // Optional: handle result.status
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Share failed')),
        );
      }
    }
  }
}

class _RemoteModelCard extends StatelessWidget {
  final AIModel model;
  const _RemoteModelCard({required this.model});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(model.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(model.description, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Best for: ${model.bestFor}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${model.sizeMB} MB • ${model.quant}'),
                OutlinedButton(
                  onPressed: () => _downloadModel(context, model),
                  child: const Text('Download', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _downloadModel(BuildContext context, AIModel model) async {
    if (AIModel.listDownloaded(model.id)) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Downloading ${model.name}'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Please keep the app open.'),
            SizedBox(height: 8),
            Text('This may take 2-5 minutes on mobile data.'),
            SizedBox(height: 16),
            LinearProgressIndicator(minHeight: 4),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    try {
      final path = await ModelDownloader.downloadModel(model, (progress) {});
      AIModel.markAsDownloaded(model, path);
      final db = DBService();
      await db.saveDownloadedModel(AIModel.downloadedModels.last);
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${model.name} ready!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }
}