import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

class KeyVault {
  static const _storage = FlutterSecureStorage();
  static const _keyAlias = 'hive_quick_master_encryption_key';

  /// Retrieves an existing encryption key or generates a new 256-bit key.
  static Future<Uint8List> getOrCreateKey() async {
    final existingKey = await _storage.read(key: _keyAlias);
    if (existingKey != null) {
      return base64Url.decode(existingKey);
    }

    final newKey = Hive.generateSecureKey();
    await _storage.write(
      key: _keyAlias,
      value: base64Url.encode(newKey),
    );
    return Uint8List.fromList(newKey);
  }
}
