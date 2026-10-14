import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionKeyManager {
  static const _keyName = 'wazza_db_encryption_key';
  final FlutterSecureStorage _storage;

  EncryptionKeyManager({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<String> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.isNotEmpty) return existing;

    final key = _generateKey();
    await _storage.write(key: _keyName, value: key);
    return key;
  }

  Future<String?> getKey() => _storage.read(key: _keyName);

  Future<void> deleteKey() => _storage.delete(key: _keyName);

  String _generateKey() {
    final random = Random.secure();
    final bytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256)),
    );
    return base64Url.encode(bytes);
  }
}
