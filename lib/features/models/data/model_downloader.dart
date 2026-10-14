import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:wazza/features/models/domain/ai_model.dart';
import 'package:path/path.dart' as path;

class DownloadProgress {
  final int percent;
  final int downloadedBytes;
  final int totalBytes;
  DownloadProgress({required this.percent, required this.downloadedBytes, required this.totalBytes});
}

class ModelDownloader {
  final http.Client _client = http.Client();

  static Future<Directory> getModelsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory(path.join(appDir.path, 'models'));
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir;
  }

  Future<String> downloadModel({
    required AIModel model,
    required void Function(DownloadProgress) onProgress,
    CancellationToken? cancelToken,
  }) async {
    final modelsDir = await getModelsDirectory();
    final filename = '${model.id}.gguf';
    final filePath = path.join(modelsDir.path, filename);
    final file = File(filePath);

    if (await file.exists()) {
      final length = await file.length();
      onProgress(DownloadProgress(percent: 100, downloadedBytes: length, totalBytes: length));
      return filePath;
    }

    final request = http.Request('GET', Uri.parse(model.hfUrl));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: Failed to download ${model.name}');
    }

    final contentLength = response.contentLength ?? 0;
    int downloaded = 0;
    int lastProgress = -1;
    final fileStream = file.openWrite();

    try {
      await for (final chunk in response.stream) {
        if (cancelToken?.isCancelled == true) {
          await fileStream.flush();
          await fileStream.close();
          if (await file.exists()) await file.delete();
          throw Exception('Download cancelled');
        }

        fileStream.add(chunk);
        downloaded += chunk.length;

        int currentProgress;
        if (contentLength > 0) {
          currentProgress = ((downloaded / contentLength) * 100).round();
        } else {
          currentProgress = ((downloaded / (model.sizeMB * 1024 * 1024)) * 100).round();
          if (currentProgress > 99) currentProgress = 99;
        }

        if (currentProgress != lastProgress) {
          lastProgress = currentProgress;
          onProgress(DownloadProgress(
            percent: currentProgress,
            downloadedBytes: downloaded,
            totalBytes: contentLength,
          ));
        }
      }

      await fileStream.flush();
      await fileStream.close();
      onProgress(DownloadProgress(percent: 100, downloadedBytes: downloaded, totalBytes: downloaded));
      return filePath;
    } catch (e) {
      await fileStream.close().catchError((_) {});
      if (await file.exists()) await file.delete();
      rethrow;
    }
  }

  Future<void> cancel() async {
    _client.close();
  }

  Future<bool> deleteModel(String filePath) async {
    try {
      final modelsDir = await getModelsDirectory();
      final normalizedPath = File(filePath).resolveSymbolicLinksSync();
      final normalizedModelsDir = modelsDir.resolveSymbolicLinksSync();
      if (!normalizedPath.startsWith(normalizedModelsDir)) return false;

      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

class CancellationToken {
  bool _cancelled = false;
  bool get isCancelled => _cancelled;
  void cancel() => _cancelled = true;
}
