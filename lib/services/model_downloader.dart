import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/utils/cancel_token.dart';
import 'dart:developer' as developer;

class ModelDownloader {
  static Future<String> downloadModel({
    required AIModel model,
    required void Function(int progress, int downloaded, int total) onProgress,
    required CancelToken cancelToken,
  }) async {
    final urls = {
      'tinyllama': 'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf?download=true',
      'phi2': 'https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf?download=true',
      // 'phi2': 'https://raw.githubusercontent.com/flutter/website/main/examples/layout/lakes/step6/images/lake.jpg',
    };

    final url = urls[model.id];
    if (url == null) throw Exception('No URL for ${model.name}');

    // ✅ USE PUBLIC DOWNLOADS DIRECTORY
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) throw Exception('Cannot access Downloads directory');
    
    final wazzaDir = Directory('${downloadsDir.path}/WazzaModels');
    if (!await wazzaDir.exists()) {
      await wazzaDir.create(recursive: true);
    }
    
    final filename = '${model.id}.gguf';
    final filePath = '${wazzaDir.path}/$filename';
    final file = File(filePath);

    // ✅ Check if file already exists
    if (await file.exists()) {
      final length = await file.length();
      developer.log('[ModelDownloader] Using existing file: $filePath ($length bytes)');
      onProgress(100, length, length);
      return filePath;
    }

    // ✅ Check old locations
    final oldPaths = await _findInOldLocations(model.id);
    if (oldPaths.isNotEmpty) {
      developer.log('[ModelDownloader] Found old file(s), moving to public directory');
      final oldFile = File(oldPaths.first);
      await oldFile.copy(filePath);
      final length = await file.length();
      onProgress(100, length, length);
      return filePath;
    }

    // ✅ DOWNLOAD WITH PROPER PROGRESS UPDATES
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final response = await client.send(request);
    
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: Failed to download');
    }

    final contentLength = response.contentLength ?? 0;
    int downloaded = 0;
    int lastProgress = 0; // Track last progress to avoid too many updates
    final fileStream = file.openWrite();

    try {
      await for (final chunk in response.stream) {
        if (cancelToken.isCancelled) {
          client.close();
          fileStream.close();
          if (await file.exists()) await file.delete();
          throw Exception('Download cancelled by user');
        }

        fileStream.add(chunk);
        downloaded += chunk.length;

        // ✅ FIXED: Calculate progress properly and throttle updates
        int currentProgress;
        if (contentLength > 0) {
          currentProgress = ((downloaded / contentLength) * 100).round();
        } else {
          // For unknown file size, use a dummy progress that increments slowly
          currentProgress = (downloaded ~/ (1024 * 1024)) * 2; // ~2% per MB
          if (currentProgress > 99) currentProgress = 99;
        }

        // ✅ Only update if progress actually changed (throttle)
        if (currentProgress > lastProgress) {
          lastProgress = currentProgress;
          onProgress(currentProgress, downloaded, contentLength);
        }
      }
      
      await fileStream.close();
      
      // ✅ Always send 100% at the end, even if we missed it
      if (downloaded > 0) {
        onProgress(100, downloaded, downloaded);
      }
      
      return filePath;
    } catch (e) {
      await fileStream.close();
      if (await file.exists()) await file.delete();
      rethrow;
    } finally {
      client.close();
    }
  }

  // Helper to find files in old storage locations
  static Future<List<String>> _findInOldLocations(String modelId) async {
    final List<String> foundPaths = [];
    final appDir = await getApplicationDocumentsDirectory();
    
    final possibleOldDirs = [
      Directory('${appDir.path}/models'),
      Directory('${appDir.path}/app_flutter/models'),
      appDir,
    ];

    for (final dir in possibleOldDirs) {
      if (await dir.exists()) {
        try {
          final files = await dir.list().toList();
          for (final file in files.whereType<File>()) {
            if (file.path.contains(modelId) && file.path.endsWith('.gguf')) {
              foundPaths.add(file.path);
            }
          }
        } catch (e) {
          // Skip directories we can't read
        }
      }
    }
    return foundPaths;
  }

  static Future<String> getPublicModelsDirectory() async {
    final downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Cannot access Downloads directory');
    }
    final wazzaDir = Directory('${downloadsDir.path}/WazzaModels');
    if (!await wazzaDir.exists()) {
      await wazzaDir.create(recursive: true);
    }
    return wazzaDir.path;
  }
}