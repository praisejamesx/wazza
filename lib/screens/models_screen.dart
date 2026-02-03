import 'package:flutter/material.dart';
import 'dart:io';
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/services/model_downloader.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wazza/services/db_service.dart';
import 'package:wazza/utils/cancel_token.dart';

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({super.key});

  @override
  State<ModelsScreen> createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen> {
  int _refreshTrigger = 0;

  void _refreshScreen() {
    setState(() {
      _refreshTrigger++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Models')),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
          return;
        },
        child: ListView(
          children: [
            if (AIModel.downloadedModels.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Your Models',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ),
              ...AIModel.downloadedModels.map((m) => _DownloadedModelCard(
                    model: m,
                    onModelDeleted: _refreshScreen,
                  )),
              const Divider(height: 20),
            ],
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                'Available Models',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ...AIModel.remoteModels.map((m) => _RemoteModelCard(
                  model: m,
                  onModelDownloaded: _refreshScreen,
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: const Icon(Icons.download_done, color: Colors.green),
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
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
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
        if (await file.exists()) {
          await file.delete();
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${model.name} deleted')),
        );
        onModelDeleted?.call();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete failed: $e')),
        );
      }
    }
  }

  Future<void> _shareModel(BuildContext context, AIModel model) async {
    if (model.localPath == null || !Platform.isAndroid) return;

    try {
      final file = XFile(model.localPath!);
      await Share.shareXFiles([file],
        text: 'Check out this AI model for Wazza: ${model.name}',
        subject: 'Wazza AI Model',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    }
  }
}

class _RemoteModelCard extends StatefulWidget {
  final AIModel model;
  final VoidCallback? onModelDownloaded;
  const _RemoteModelCard({required this.model, this.onModelDownloaded});

  @override
  State<_RemoteModelCard> createState() => __RemoteModelCardState();
}

class __RemoteModelCardState extends State<_RemoteModelCard> {
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

  void _safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  Future<void> _downloadModel() async {
    if (AIModel.listDownloaded(widget.model.id) || widget.model.isDownloaded || _isDownloading) return;

    _safeSetState(() {
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
          _safeSetState(() {
            _downloadProgress = progress;
            _downloadedBytes = downloaded;
            _totalBytes = total;
          });
        },
        cancelToken: _cancelToken!,
      );

      AIModel.markAsDownloaded(widget.model, savedPath);
      await DBService().saveDownloadedModel(AIModel.downloadedModels.last);
      
      _safeSetState(() {
        _isDownloading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.model.name} downloaded!'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onModelDownloaded?.call();
      }
    } catch (e) {
      _safeSetState(() {
        _isDownloading = false;
      });
      
      final errorMsg = e.toString();
      if (mounted) {
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
    } finally {
      _cancelToken = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDownloaded = AIModel.listDownloaded(widget.model.id) || widget.model.isDownloaded;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.model.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.model.sizeMB} MB • ${widget.model.quant}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.model.description,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            if (_isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(
                    value: _downloadProgress / 100,
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$_downloadProgress% • ${(_downloadedBytes / (1024 * 1024)).toStringAsFixed(1)} MB',
                    style: const TextStyle(fontSize: 12),
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