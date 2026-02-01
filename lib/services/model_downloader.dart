// lib/services/model_downloader.dart
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:wazza/models/ai_model.dart';
import 'package:wazza/utils/cancel_token.dart';

class ModelDownloader {
    static Future<String> downloadModel({
      required AIModel model,
      required void Function(int progress, int downloaded, int total) onProgress,
      required CancelToken cancelToken,
    }) async {
      final urls = {
        'tinyllama': 'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf?download=true',
        'phi2': 'https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf?download=true',
      };

      final url = urls[model.id];
      if (url == null) throw Exception('No URL for ${model.name}');

      final filename = '${model.id}_${model.quant}.gguf'; // Removed timestamp to avoid duplicates
      final dir = await getApplicationDocumentsDirectory();
      final modelsDir = Directory('${dir.path}/models');
      
      if (!await modelsDir.exists()) {
        await modelsDir.create(recursive: true);
      }
      
      final filePath = '${modelsDir.path}/$filename';
      final file = File(filePath);

      // Keep if exists (don't waste data)
      if (await file.exists()) {
        final size = await file.length();
        if (size > 0) {
          onProgress(100, size, size);
          return filePath;
        }
      }

      final client = http.Client();
      try {
        final request = http.Request('GET', Uri.parse(url));
        final response = await client.send(request);
        
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}: Failed to download');
        }

        final contentLength = response.contentLength ?? 0;
        int downloaded = 0;
        final List<int> chunks = [];

        await for (final chunk in response.stream) {
          if (cancelToken.isCancelled) {
            client.close();
            if (await file.exists()) await file.delete();
            throw Exception('Download cancelled by user');
          }

          chunks.addAll(chunk);
          downloaded += chunk.length;
          
          // *** CRITICAL FIX: SINGLE progress logic ***
          if (contentLength > 0) {
            final progress = ((downloaded / contentLength) * 100).round();
            onProgress(progress, downloaded, contentLength);
          } else {
            onProgress(-1, downloaded, contentLength);
          }
          
          // Write in chunks (100KB)
          if (chunks.length >= 1024 * 100) {
            await file.writeAsBytes(chunks, mode: FileMode.append);
            chunks.clear();
          }
        }

        // Write remaining bytes
        if (chunks.isNotEmpty) {
          await file.writeAsBytes(chunks, mode: FileMode.append);
        }

        return filePath;
      } catch (e) {
        if (await file.exists()) await file.delete();
        rethrow;
      } finally {
        client.close();
      }
    }

  static Future<String> getModelsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory('${dir.path}/models');
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir.path;
  }
}