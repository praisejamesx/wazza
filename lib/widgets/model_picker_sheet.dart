import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/model_downloader.dart';

class ModelPickerSheet extends StatelessWidget {
  final Function(AIModel) onSelect;
  const ModelPickerSheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          const Padding(padding: EdgeInsets.all(16), child: Text('Select Model', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(
            child: ListView(
              children: [
                if (AIModel.downloadedModels.isNotEmpty) ...[
                  const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('DOWNLOADED', style: TextStyle(fontSize: 12, color: Colors.grey))),
                  ...AIModel.downloadedModels.map((m) => _ModelTile(model: m, onSelect: onSelect)),
                  const Divider(),
                ],
                const Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8), child: Text('AVAILABLE TO DOWNLOAD', style: TextStyle(fontSize: 12, color: Colors.grey))),
                ...AIModel.remoteModels.map((m) => _ModelTile(model: m, onSelect: onSelect)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  final AIModel model;
  final Function(AIModel) onSelect;
  const _ModelTile({required this.model, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: model.isDownloaded ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.cloud_download_outlined),
      title: Text(model.name),
      subtitle: Text('${model.sizeMB} MB • ${model.quant}'),
      trailing: !model.isDownloaded
          ? IconButton(icon: const Icon(Icons.download_outlined, size: 18), onPressed: () => _downloadModel(context, model))
          : null,
      onTap: model.isDownloaded ? () {
        Navigator.pop(context);
        onSelect(model);
      } : null,
    );
  }

  Future<void> _downloadModel(BuildContext context, AIModel model) async {
    if (AIModel.listDownloaded(model.id)) return;

    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Downloading...'),
            SizedBox(height: 8),
            LinearProgressIndicator(),
          ],
        ),
      ),
    );

    try {
      if (!context.mounted) return;
      final path = await ModelDownloader.downloadModel(model);
      AIModel.markAsDownloaded(model, path);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${model.name} ready!')));
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}