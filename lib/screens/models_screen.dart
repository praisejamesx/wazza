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
  // Add a refresh trigger to update the UI
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
              const _SectionHeader('DOWNLOADED MODELS'),
              ...AIModel.downloadedModels.map((m) => _DownloadedModelCard(
                model: m,
                onModelDeleted: _refreshScreen,
              )),
              const Divider(height: 1),
            ],
            const _SectionHeader('BROWSE MODELS'),
            ...AIModel.remoteModels.map((m) => _RemoteModelCard(
              model: m,
              onModelDownloaded: _refreshScreen,
            )),
          ],
        ),
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
  final VoidCallback? onModelDeleted; // Callback when model is deleted
  const _DownloadedModelCard({required this.model, this.onModelDeleted});

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
      // Delete from memory list
      AIModel.downloadedModels.removeWhere((m) => m.id == model.id);
      
      // Delete from DB
      await DBService().deleteDownloadedModel(model.id);
      
      // Delete file if exists
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
        // Call callback to refresh parent screen instead of Navigator.pushReplacement
        if (onModelDeleted != null) {
          onModelDeleted!();
        }
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
  final VoidCallback? onModelDownloaded; // Callback when download completes
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
  bool _dialogOpen = false;

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }

  // Helper to safely update UI state
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  Future<void> _downloadModel() async {
    if (AIModel.listDownloaded(widget.model.id) || _isDownloading) return;

    _safeSetState(() {
      _isDownloading = true;
      _downloadProgress = 0;
      _downloadedBytes = 0;
      _totalBytes = 0;
      _cancelToken = CancelToken();
      _dialogOpen = true;
    });

    // Show download dialog
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Downloading ${widget.model.name}'),
              content: SizedBox(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _downloadedBytes > 0 && _totalBytes > 0
                          ? '${(_downloadedBytes / (1024 * 1024)).toStringAsFixed(2)} MB / ${(_totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB'
                          : 'Connecting to server...',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (_totalBytes > 0)
                      LinearProgressIndicator(
                        value: _downloadProgress / 100,
                        backgroundColor: Colors.grey[200],
                        color: Colors.blue,
                        minHeight: 8,
                      )
                    else
                      LinearProgressIndicator(
                        backgroundColor: Colors.grey[200],
                        color: Colors.blue,
                        minHeight: 8,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      _totalBytes > 0 ? '$_downloadProgress%' : 'Downloading...',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    _cancelToken?.cancel();
                    if (mounted && _dialogOpen) {
                      Navigator.pop(context);
                      _dialogOpen = false;
                    }
                    _safeSetState(() {
                      _isDownloading = false;
                      _downloadProgress = 0;
                    });
                  },
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
              ],
            );
          },
        );
      },
    );

    try {
      final savedPath = await ModelDownloader.downloadModel(
        model: widget.model,
        onProgress: (progress, downloaded, total) {
          // Use WidgetsBinding to safely update state
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _downloadProgress = progress;
                _downloadedBytes = downloaded;
                _totalBytes = total;
              });
            }
          });
        },
        cancelToken: _cancelToken!,
      );

      // Mark as downloaded
      AIModel.markAsDownloaded(widget.model, savedPath);
      
      // Save to database
      final db = DBService();
      await db.saveDownloadedModel(AIModel.downloadedModels.last);
      
      if (mounted && _dialogOpen) {
        Navigator.pop(context);
        _dialogOpen = false;
      }
      
      _safeSetState(() {
        _isDownloading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.model.name} downloaded successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Call callback to refresh parent screen instead of Navigator.pushReplacement
        if (widget.onModelDownloaded != null) {
          widget.onModelDownloaded!();
        }
      }
    } catch (e) {
      if (mounted && _dialogOpen) {
        Navigator.pop(context);
        _dialogOpen = false;
      }
      
      _safeSetState(() {
        _isDownloading = false;
      });
      
      final errorMsg = e.toString();
      if (mounted) {
        if (errorMsg.contains('cancelled')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Download failed: $errorMsg'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } finally {
      _cancelToken = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.model.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(widget.model.description, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 4),
            Text('Best for: ${widget.model.bestFor}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${widget.model.sizeMB} MB • ${widget.model.quant}'),
                if (_isDownloading) ...[
                  SizedBox(
                    width: 100,
                    height: 20,
                    child: _totalBytes > 0
                        ? LinearProgressIndicator(
                            value: _downloadProgress / 100,
                            backgroundColor: Colors.grey[200],
                            color: Colors.blue,
                          )
                        : LinearProgressIndicator(
                            backgroundColor: Colors.grey[200],
                            color: Colors.blue,
                          ),
                  ),
                  Text(
                    _totalBytes > 0 ? '$_downloadProgress%' : '...',
                    style: const TextStyle(fontSize: 12),
                  ),
                ] else
                  OutlinedButton(
                    onPressed: AIModel.listDownloaded(widget.model.id) ? null : _downloadModel,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AIModel.listDownloaded(widget.model.id) ? Colors.grey : Colors.blue,
                      ),
                    ),
                    child: Text(
                      AIModel.listDownloaded(widget.model.id) ? 'Downloaded' : 'Download',
                      style: TextStyle(
                        fontSize: 12,
                        color: AIModel.listDownloaded(widget.model.id) ? Colors.grey : Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}