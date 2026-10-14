import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class FileUtils {
  static Future<Directory> getModelsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final modelsDir = Directory(p.join(appDir.path, 'models'));
    if (!await modelsDir.exists()) {
      await modelsDir.create(recursive: true);
    }
    return modelsDir;
  }

  static Future<Directory> getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory(p.join(appDir.path, 'cache'));
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  static Future<List<File>> scanForModelFiles(Directory dir) async {
    final files = <File>[];
    try {
      final entities = await dir.list().toList();
      for (final entity in entities) {
        if (entity is File) {
          if (entity.path.endsWith('.gguf') ||
              entity.path.endsWith('.bin') ||
              entity.path.endsWith('.model')) {
            files.add(entity);
          }
        } else if (entity is Directory) {
          files.addAll(await scanForModelFiles(entity));
        }
      }
    } catch (_) {}
    return files;
  }

  static Future<bool> fileExists(String path) async {
    return File(path).exists();
  }

  static Future<int> getFileSize(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return 0;
      final stat = await file.stat();
      return stat.size;
    } catch (_) {
      return 0;
    }
  }

  static String getFileName(String path) => p.basename(path);
  
  static String getFileNameWithoutExtension(String path) {
    final name = p.basename(path);
    final ext = p.extension(name);
    return name.substring(0, name.length - ext.length);
  }
}
