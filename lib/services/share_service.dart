// lib/services/share_service.dart - COMPLETE
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class ShareService {
  static const platform = MethodChannel('com.wazza.app/share');
  static const eventChannel = EventChannel('com.wazza.app/share_events');

  /// Check for shared files on app start
  static Future<String?> checkForSharedFileOnLaunch() async {
    try {
      final filePath = await platform.invokeMethod<String?>('getInitialSharedFile');
      return filePath;
    } on PlatformException catch (e) {
      debugPrint("Failed to get shared file: ${e.message}");
      return null;
    }
  }

  /// Listen for incoming shares while app is running
  static Stream<String?> get sharedFileStream {
    return eventChannel
        .receiveBroadcastStream()
        .map((event) => event as String?);
  }

  /// Share a model file with other apps
  static Future<void> shareModelFile(String filePath) async {
    try {
      await platform.invokeMethod('shareFile', {
        'filePath': filePath,
        'mimeType': 'application/octet-stream',
        'subject': 'Wazza AI Model',
      });
    } on PlatformException catch (e) {
      debugPrint("Failed to share file: ${e.message}");
    }
  }

  /// Get directory where shared files are stored
  static Future<String> getSharedFilesDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final sharedDir = Directory('${dir.path}/shared');
    if (!await sharedDir.exists()) {
      await sharedDir.create(recursive: true);
    }
    return sharedDir.path;
  }

  /// Copy shared file to app's directory
  static Future<String?> copySharedFile(String sourcePath) async {
    try {
      final sourceFile = File(sourcePath);
      if (!await sourceFile.exists()) return null;

      final sharedDir = await getSharedFilesDirectory();
      final fileName = sourcePath.split('/').last;
      final destPath = '$sharedDir/$fileName';
      // final destFile = File(destPath);

      await sourceFile.copy(destPath);
      return destPath;
    } catch (e) {
      debugPrint("Error copying shared file: $e");
      return null;
    }
  }
}