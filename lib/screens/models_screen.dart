import 'package:flutter/material.dart';
import 'dart:io';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/model_downloader.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wazza/services/db_service.dart';
import 'package:wazza/utils/cancel_token.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:connectivity_plus/connectivity_plus.dart';

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});

  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  final Connectivity _connectivity = Connectivity();

  Future<bool> _isOnline() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<void> _importModel() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['gguf', 'bin'],
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) return;

    final sourcePath = result.files.single.path!;
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File not found')),
        );
      }
      return;
    }

    try {
      final modelsDir = await ModelDownloader.getModelsDirectory();
      final fileName = path.basename(sourcePath);
      final destPath = path.join(modelsDir.path, fileName);
      final destFile = File(destPath);

      if (await destFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$fileName already exists in models')),
          );
        }
        return;
      }

      await sourceFile.copy(destPath);
      await DBService().reconcileModels();
      _refresh();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$fileName imported successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Models'),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: _importModel,
            tooltip: 'Import model from device',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(),
        child: ListView(
          children: [
            if (AIModel.downloadedModels.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Your Models (${AIModel.downloadedModels.length})',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : Colors.grey,
                  ),
                ),
              ),
              ...AIModel.downloadedModels.map((m) => _DownloadedModelCard(
                    model: m,
                    onModelDeleted: _refresh,
                  )),
              const Divider(height: 20),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Available Models',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[400] : Colors.grey,
                ),
              ),
            ),
            ...AIModel.remoteModels
                .where((m) => !m.isDownloaded)
                .map((m) => _RemoteModelCard(
                      model: m,
                      onModelDownloaded: _refresh,
                      checkOnline: _isOnline,
                    )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DownloadedModelCard extends StatelessWidget {
  final AIModel model;
  final VoidCallback? onModelDeleted;
  const _DownloadedModelCard({required this.model, this.onModelDeleted});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? Colors.grey[850] : null,
      child: ListTile(
        leading: const Icon(Icons.download_done, color: Colors.green),
        title: Text(model.name, style: TextStyle(color: isDark ? Colors.white : null)),
        subtitle: Text('${model.sizeMB} MB • ${model.quant}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.share, size: 18, color: isDark ? Colors.grey[400] : null),
              onPressed: () => _shareModel(context, model),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, size: 18, color: isDark ? Colors.grey[400] : null),
              onPressed: () => _deleteModel(context, model),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteModel(BuildContext context, AIModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Model'),
        content: Text('Delete ${model.name}? This will free up ${model.sizeMB}MB.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      AIModel.markAsNotDownloaded(model.id);
      await DBService().deleteDownloadedModel(model.id);

      if (model.localPath != null) {
        final file = File(model.localPath!);
        if (await file.exists()) await file.delete();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${model.name} deleted')));
        onModelDeleted?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  Future<void> _shareModel(BuildContext context, AIModel model) async {
    if (model.localPath == null || !Platform.isAndroid) return;

    try {
      final file = XFile(model.localPath!);
      // ignore: deprecated_member_use
      await Share.shareXFiles([file],
        text: 'Check out this AI model for Wazza: ${model.name}',
        subject: 'Wazza AI Model',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    }
  }
}

class _RemoteModelCard extends StatefulWidget {
  final AIModel model;
  final VoidCallback? onModelDownloaded;
  final Future<bool> Function() checkOnline;

  const _RemoteModelCard({
    required this.model,
    this.onModelDownloaded,
    required this.checkOnline,
  });

  @override
  State<_RemoteModelCard> createState() => _RemoteModelCardState();
}

class _RemoteModelCardState extends State<_RemoteModelCard> {
  bool _isDownloading = false;
  int _downloadProgress = 0;
  int _downloadedBytes = 0;
  int _totalBytes = 0;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  Future<void> _downloadModel() async {
    if (AIModel.listDownloaded(widget.model.id) || widget.model.isDownloaded || _isDownloading) return;

    final online = await widget.checkOnline();
    if (!online) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection. Connect to the internet first.')),
        );
      }
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _downloadedBytes = 0;
      _totalBytes = 0;
      _cancelToken = CancelToken();
    });

    try {
      final savedPath = await ModelDownloader.downloadModel(
        model: widget.model,
        onProgress: (progress, downloaded, total) {
          if (mounted) {
            setState(() {
              _downloadProgress = progress;
              _downloadedBytes = downloaded;
              _totalBytes = total;
            });
          }
        },
        cancelToken: _cancelToken!,
      );

      AIModel.markAsDownloaded(widget.model, savedPath);
      final modelToSave = AIModel.downloadedModels.firstWhere(
        (m) => m.id == widget.model.id,
        orElse: () => widget.model,
      );
      await DBService().saveDownloadedModel(modelToSave);

      if (mounted) {
        setState(() => _isDownloading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.model.name} downloaded!'), backgroundColor: Colors.green),
        );
        widget.onModelDownloaded?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
        final errorMsg = e.toString();
        if (errorMsg.contains('cancelled')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Download cancelled')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Download failed: $errorMsg')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDownloaded = AIModel.listDownloaded(widget.model.id) || widget.model.isDownloaded;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? Colors.grey[850] : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.model.name,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: isDark ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.model.sizeMB} MB • ${widget.model.quant}',
              style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[500] : Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              widget.model.description,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : null),
            ),
            const SizedBox(height: 12),
            if (_isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _totalBytes > 0 ? _downloadProgress / 100 : null,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_downloadProgress% • ${(_downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                    style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : null),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () => _cancelToken?.cancel(),
                    child: const Text('Cancel'),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isDownloaded ? null : _downloadModel,
                  child: Text(isDownloaded ? 'Downloaded' : 'Download'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
