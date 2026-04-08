// lib/services/model_downloader.dart

import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/utils/cancel_token.dart';
import 'package:path/path.dart' as path;
import 'dart:developer' as developer;

class ModelDownloader {
  static Future<String> downloadModel({
    required AIModel model,
    required void Function(int progress, int downloaded, int total) onProgress,
    required CancelToken cancelToken,
  }) async {
    final urls = {
      'qwen1_5_1_8b': 'https://huggingface.co/Qwen/Qwen1.5-1.8B-Chat-GGUF/resolve/main/qwen1_5-1_8b-chat-q4_k_m.gguf?download=true',
      'phi2': 'https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf',
      'gemma1_5b': 'https://huggingface.co/mradermacher/Gemma-1.5B-GGUF/resolve/main/Gemma-1.5B.Q8_0.gguf',
      'tinyllama': 'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf',
    };
    final url = urls[model.id];
    if (url == null) throw Exception('No URL for ${model.name}');

    // Use private app storage
    final modelsDir = await getModelsDirectory();
    final filename = '${model.id}.gguf';
    final filePath = path.join(modelsDir.path, filename);
    final file = File(filePath);

    // Check if file already exists
    if (await file.exists()) {
      final length = await file.length();
      developer.log('[ModelDownloader] Using existing file: $filePath ($length bytes)');
      onProgress(100, length, length);
      return filePath;
    }

    // Download
    final client = http.Client();
    final request = http.Request('GET', Uri.parse(url));
    final response = await client.send(request);
    
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: Failed to download');
    }

    final contentLength = response.contentLength ?? 0;
    int downloaded = 0;
    int lastProgress = 0;
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

        int currentProgress;
        if (contentLength > 0) {
          currentProgress = ((downloaded / contentLength) * 100).round();
        } else {
          currentProgress = (downloaded ~/ (1024 * 1024)) * 2;
          if (currentProgress > 99) currentProgress = 99;
        }

        if (currentProgress > lastProgress) {
          lastProgress = currentProgress;
          onProgress(currentProgress, downloaded, contentLength);
        }
      }
      
      await fileStream.close();
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

  static Future<Directory> getModelsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory(path.join(appDir.path, 'models'));
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir;
  }

  // Keep for any existing calls expecting a string path
  static Future<String> getPublicModelsDirectory() async {
    return (await getModelsDirectory()).path;
  }
}