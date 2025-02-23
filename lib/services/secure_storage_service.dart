// secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _emailKey = 'user_email';

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _emailKey);
  }

  static Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }
}
