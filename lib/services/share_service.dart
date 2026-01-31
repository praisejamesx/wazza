// lib/services/share_service.dart
import 'package:flutter/services.dart';

class ShareService {
  static const MethodChannel _channel = MethodChannel('wazza.share');

  /// Called on app launch to check if a .gguf file was shared to Wazza
  static Future<String?> getSharedModelPath() async {
    try {
      final String? path = await _channel.invokeMethod('getSharedFile');
      return path;
    } catch (_) {
      return null;
    }
  }
}