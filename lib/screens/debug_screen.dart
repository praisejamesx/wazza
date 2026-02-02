import 'package:flutter/material.dart';
import 'dart:developer' as developer;
import 'package:wazza/models/ai_model.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:wazza/services/model_downloader.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  List<FileSystemEntity> _modelFiles = [];
  bool _scanningFiles = false;
  String _exportStatus = '';

  Future<void> _scanModelFiles() async {
    setState(() {
      _scanningFiles = true;
      _modelFiles = [];
    });

    try {
      // Scan PUBLIC directory first
      final publicDir = await ModelDownloader.getPublicModelsDirectory();
      final wazzaDir = Directory(publicDir);
      
      if (await wazzaDir.exists()) {
        final files = await wazzaDir.list().toList();
        _modelFiles.addAll(files.whereType<File>());
        developer.log('Found ${files.length} files in public directory: $publicDir');
      }
      
      // Also scan old locations
      final appDir = await getApplicationDocumentsDirectory();
      final oldDirs = [
        Directory('${appDir.path}/models'),
        Directory('${appDir.path}/app_flutter/models'),
      ];
      
      for (final oldDir in oldDirs) {
        if (await oldDir.exists()) {
          final oldFiles = await oldDir.list().toList();
          _modelFiles.addAll(oldFiles.whereType<File>());
        }
      }
      
      setState(() {});
    } catch (e) {
      developer.log('Error scanning model files', error: e);
    } finally {
      setState(() {
        _scanningFiles = false;
      });
    }
  }

  Future<void> _exportModelFile(File file, String modelName) async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir == null) {
        setState(() {
          _exportStatus = 'Error: Cannot access Downloads directory';
        });
        return;
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final exportFileName = 'Wazza_${modelName}_$timestamp.gguf';
      final exportPath = '${downloadsDir.path}/$exportFileName';

      await file.copy(exportPath);

      setState(() {
        _exportStatus = 'Exported to: $exportPath';
      });

      // UPDATED: Use SharePlus.instance.share() instead of deprecated Share.shareXFiles
      await Share.shareXFiles([XFile(exportPath)],
          text: 'Exported Wazza model: $modelName');
    } catch (e) {
      setState(() {
        _exportStatus = 'Export failed: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _scanModelFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Debug & Export')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Downloaded Models (from Database):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...AIModel.downloadedModels.map((model) => Card(
                child: ListTile(
                  title: Text(model.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${model.id}'),
                      Text('Path: ${model.localPath ?? "No path"}'),
                      Text('Size: ${model.sizeMB} MB'),
                      if (model.localPath != null &&
                          model.localPath!.isNotEmpty)
                        FutureBuilder<bool>(
                          future: File(model.localPath!).exists(),
                          builder: (context, snapshot) => Row(
                            children: [
                              const Text(
                                'File exists: ',
                                style: TextStyle(fontSize: 14),
                              ),
                              Text(
                                '${snapshot.data ?? false}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: snapshot.data == true
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  trailing: model.localPath != null &&
                          model.localPath!.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.download), // FIXED ICON
                          onPressed: () =>
                              _exportModelFile(File(model.localPath!), model.name),
                          tooltip: 'Export to Downloads',
                        )
                      : null,
                ),
              )),

          const SizedBox(height: 32),

          Row(
            children: [
              const Text('Raw Files in Storage:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              IconButton(
                icon: _scanningFiles
                    ? const CircularProgressIndicator.adaptive()
                    : const Icon(Icons.refresh),
                onPressed: _scanningFiles ? null : _scanModelFiles,
                tooltip: 'Rescan files',
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_modelFiles.isEmpty)
            const Text('No model files found in storage.')
          else
            ..._modelFiles.map((file) => Card(
                  child: ListTile(
                    title: Text(file.path.split('/').last),
                    subtitle: Text(file.path),
                    trailing: IconButton(
                      icon: const Icon(Icons.download), // FIXED ICON
                      onPressed: () => _exportModelFile(
                          file as File, file.path.split('/').last),
                      tooltip: 'Export to Downloads',
                    ),
                  ),
                )),

          const SizedBox(height: 32),

          if (_exportStatus.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(_exportStatus),
            ),
        ],
      ),
    );
  }
}