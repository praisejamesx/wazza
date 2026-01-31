// lib/services/model_downloader.dart
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:wazza/models/ai_model.dart';

class ModelDownloader {
  static Future<String> downloadModel(AIModel model) async {
    // Use real Hugging Face URLs
    final urls = {
      'tinyllama': 'https://huggingface.co/TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF/resolve/main/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf?download=true',
      'phi2': 'https://huggingface.co/TheBloke/phi-2-GGUF/resolve/main/phi-2.Q4_K_M.gguf?download=true',
    };

    final url = urls[model.id];
    if (url == null) throw Exception('No URL for ${model.name}');

    final filename = '${model.id}.Q4_K_M.gguf';
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/$filename';
    final file = File(filePath);

    if (await file.exists()) {
      return filePath;
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }
}