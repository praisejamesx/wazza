import 'package:flutter/material.dart';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/model_downloader.dart';
import 'package:wazza/services/db_service.dart';
import 'package:wazza/utils/cancel_token.dart';

class ModelPickerSheet extends StatelessWidget {
  final Function(AIModel) onSelect;
  const ModelPickerSheet({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Stack(
              children: [
                const Center(
                  child: Text('Select Model', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (AIModel.downloadedModels.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text('DOWNLOADED', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ),
                  ...AIModel.downloadedModels.map((m) => _ModelTile(model: m, onSelect: onSelect)),
                  const Divider(),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('AVAILABLE TO DOWNLOAD', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ),
                ...AIModel.remoteModels
                    .where((m) => !m.isDownloaded)
                    .map((m) => _ModelTile(model: m, onSelect: onSelect)),
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
      leading: model.isDownloaded
          ? const Icon(Icons.check_circle, color: Colors.green)
          : const Icon(Icons.cloud_download_outlined),
      title: Text(model.name),
      subtitle: Text('${model.sizeMB} MB • ${model.quant}'),
      trailing: !model.isDownloaded
          ? IconButton(
              icon: const Icon(Icons.download_outlined, size: 18),
              onPressed: () => _downloadModel(context, model),
            )
          : null,
      onTap: model.isDownloaded
          ? () {
              Navigator.pop(context);
              onSelect(model);
            }
          : null,
    );
  }

  Future<void> _downloadModel(BuildContext context, AIModel model) async {
    if (AIModel.listDownloaded(model.id)) return;

    final cancelToken = CancelToken();
    int progress = 0;
    int downloaded = 0;
    int total = 0;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Downloading ${model.name}'),
              content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    LinearProgressIndicator(
                      value: total > 0 ? progress / 100 : null,
                      backgroundColor: Colors.grey[200],
                      color: Colors.blue,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '$progress%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      downloaded > 0 && total > 0
                          ? '${(downloaded / (1024 * 1024)).toStringAsFixed(1)} MB / ${(total / (1024 * 1024)).toStringAsFixed(1)} MB'
                          : 'Starting download...',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    cancelToken.cancel();
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == false) return;

    try {
      final savedPath = await ModelDownloader.downloadModel(
        model: model,
        onProgress: (p, d, t) {
          if (Navigator.of(context, rootNavigator: false).canPop()) {
            progress = p;
            downloaded = d;
            total = t;
            (context as Element).markNeedsBuild();
          }
        },
        cancelToken: cancelToken,
      );

      AIModel.markAsDownloaded(model, savedPath);
      final modelToSave = AIModel.downloadedModels.firstWhere(
        (m) => m.id == model.id,
        orElse: () => model,
      );
      await DBService().saveDownloadedModel(modelToSave);

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${model.name} ready!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        if (!e.toString().contains('cancelled')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e')),
          );
        }
      }
    }
  }
}
