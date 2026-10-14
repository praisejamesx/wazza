import 'package:permission_handler/permission_handler.dart';
import 'dart:developer' as dev;

class PermissionService {
  Future<bool> requestStoragePermission() async {
    try {
      final statuses = await [
        Permission.storage,
        Permission.photos,
        Permission.audio,
      ].request();

      final allGranted = statuses.values.every(
        (s) => s.isGranted || s.isLimited,
      );

      dev.log('[PermissionService] Storage permissions: $statuses (granted: $allGranted)');
      return allGranted;
    } catch (e) {
      dev.log('[PermissionService] Error requesting permissions: $e');
      return false;
    }
  }

  Future<bool> requestPhotoPermission() async {
    try {
      final status = await Permission.photos.request();
      if (status.isGranted || status.isLimited) return true;
      final fallback = await Permission.storage.request();
      return fallback.isGranted;
    } catch (e) {
      dev.log('[PermissionService] Error requesting photo permission: $e');
      return false;
    }
  }

  Future<bool> requestAudioPermission() async {
    try {
      final status = await Permission.audio.request();
      if (status.isGranted) return true;
      final fallback = await Permission.storage.request();
      return fallback.isGranted;
    } catch (e) {
      dev.log('[PermissionService] Error requesting audio permission: $e');
      return false;
    }
  }

  Future<bool> hasStoragePermission() async {
    final storage = await Permission.storage.status;
    final photos = await Permission.photos.status;
    return storage.isGranted || storage.isLimited || photos.isGranted || photos.isLimited;
  }

  Future<bool> hasAudioPermission() async {
    final audio = await Permission.audio.status;
    final storage = await Permission.storage.status;
    return audio.isGranted || storage.isGranted;
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}
