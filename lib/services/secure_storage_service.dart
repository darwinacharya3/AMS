import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _emailKey = 'user_email';
  static const _passwordKey = 'user_password';
  static const _tokenKey = 'auth_token'; // New key for token

  static Future<void> saveUserEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  static Future<String?> getUserEmail() async {
    return await _storage.read(key: _emailKey);
  }
  
  static Future<void> saveUserPassword(String password) async {
    await _storage.write(key: _passwordKey, value: password);
  }

  static Future<String?> getUserPassword() async {
    return await _storage.read(key: _passwordKey);
  }

  static Future<void> saveUserCredentials(String email, String password) async {
    await _storage.write(key: _emailKey, value: email);
    await _storage.write(key: _passwordKey, value: password);
  }

  // New methods for token handling
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }
}













// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SecureStorageService {
//   static const _storage = FlutterSecureStorage();
//   static const _emailKey = 'user_email';
//   static const _passwordKey = 'user_password'; // New key for password

//   static Future<void> saveUserEmail(String email) async {
//     await _storage.write(key: _emailKey, value: email);
//   }

//   static Future<String?> getUserEmail() async {
//     return await _storage.read(key: _emailKey);
//   }
  
//   // New methods for password handling
//   static Future<void> saveUserPassword(String password) async {
//     await _storage.write(key: _passwordKey, value: password);
//   }

//   static Future<String?> getUserPassword() async {
//     return await _storage.read(key: _passwordKey);
//   }

//   // Combined method to save both credentials at once
//   static Future<void> saveUserCredentials(String email, String password) async {
//     await _storage.write(key: _emailKey, value: email);
//     await _storage.write(key: _passwordKey, value: password);
//   }

//   static Future<void> clearCredentials() async {
//     await _storage.deleteAll();
//   }
// }













// // secure_storage_service.dart
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SecureStorageService {
//   static const _storage = FlutterSecureStorage();
//   static const _emailKey = 'user_email';

//   static Future<void> saveUserEmail(String email) async {
//     await _storage.write(key: _emailKey, value: email);
//   }

//   static Future<String?> getUserEmail() async {
//     return await _storage.read(key: _emailKey);
//   }

//   static Future<void> clearCredentials() async {
//     await _storage.deleteAll();
//   }
// }
