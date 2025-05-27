import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();
  static const _emailKey = 'user_email';
  static const _passwordKey = 'user_password';
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id'; // Added for user ID

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

  // User ID methods
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
    debugPrint('User ID saved to secure storage: $userId');
  }

  static Future<String?> getUserId() async {
    final userId = await _storage.read(key: _userIdKey);
    debugPrint('Retrieved user ID from storage: $userId');
    return userId;
  }

  // Token handling
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> clearCredentials() async {
    await _storage.deleteAll();
  }
  
  // Debug method to print all stored values
  static Future<void> debugPrintAllStoredValues() async {
    final keys = await _storage.readAll();
    debugPrint('========== SECURE STORAGE DEBUG ==========');
    debugPrint('Total items in secure storage: ${keys.length}');
    
    for (var entry in keys.entries) {
      String value = entry.value;
      // Truncate long values like tokens
      if (value.length > 20) {
        value = '${value.substring(0, 20)}...';
      }
      debugPrint('${entry.key}: $value');
    }
    
    // Specifically check for user ID
    final userId = await getUserId();
    debugPrint('User ID specifically: $userId');
    
    debugPrint('========== END SECURE STORAGE DEBUG ==========');
  }
  // Add this somewhere after the other constants
  // Add this to your constants
static const _uuidKey = 'attendance_uuid';

// Add these methods to SecureStorageService
static Future<void> saveUuid(String uuid) async {
  await _storage.write(key: _uuidKey, value: uuid);
  debugPrint('UUID saved to secure storage: $uuid');
}

static Future<String?> getUuid() async {
  final uuid = await _storage.read(key: _uuidKey);
  debugPrint('Retrieved UUID from storage: $uuid');
  return uuid;
}

}








// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SecureStorageService {
//   static const _storage = FlutterSecureStorage();
//   static const _emailKey = 'user_email';
//   static const _passwordKey = 'user_password';
//   static const _tokenKey = 'auth_token';
//   static const _userIdKey = 'user_id'; // New key for user ID

//   static Future<void> saveUserEmail(String email) async {
//     await _storage.write(key: _emailKey, value: email);
//   }

//   static Future<String?> getUserEmail() async {
//     return await _storage.read(key: _emailKey);
//   }
  
//   static Future<void> saveUserPassword(String password) async {
//     await _storage.write(key: _passwordKey, value: password);
//   }

//   static Future<String?> getUserPassword() async {
//     return await _storage.read(key: _passwordKey);
//   }

//   static Future<void> saveUserCredentials(String email, String password) async {
//     await _storage.write(key: _emailKey, value: email);
//     await _storage.write(key: _passwordKey, value: password);
//   }

//   // New methods for user ID
//   static Future<void> saveUserId(String userId) async {
//     await _storage.write(key: _userIdKey, value: userId);
//   }

//   static Future<String?> getUserId() async {
//     return await _storage.read(key: _userIdKey);
//   }

//   // Token handling
//   static Future<void> saveToken(String token) async {
//     await _storage.write(key: _tokenKey, value: token);
//   }

//   static Future<String?> getToken() async {
//     return await _storage.read(key: _tokenKey);
//   }

//   static Future<void> clearCredentials() async {
//     await _storage.deleteAll();
//   }
// }








// import 'package:flutter/foundation.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SecureStorageService {
//   static const _storage = FlutterSecureStorage();
//   static const _emailKey = 'user_email';
//   static const _passwordKey = 'user_password';
//   static const _tokenKey = 'auth_token';

//   // Enhanced logging for debugging
//   static void _logOperation(String operation, String key, {String? value}) {
//     final bool hasValue = value != null && value.isNotEmpty;
//     debugPrint('=== SECURE STORAGE: $operation ===');
//     debugPrint('Key: $key');
//     debugPrint('Has Value: $hasValue');
//     if (key == _tokenKey && hasValue) {
//       // Only log the first few characters of the token for security
//       final String maskedValue = value!.length > 10 
//           ? '${value.substring(0, 10)}...[${value.length} chars]'
//           : '[empty or invalid token]';
//       debugPrint('Token Preview: $maskedValue');
//     }
//     debugPrint('============================');
//   }

//   static Future<void> saveUserEmail(String email) async {
//     _logOperation('SAVE EMAIL', _emailKey, value: email);
//     await _storage.write(key: _emailKey, value: email);
//   }

//   static Future<String?> getUserEmail() async {
//     final email = await _storage.read(key: _emailKey);
//     _logOperation('GET EMAIL', _emailKey, value: email);
//     return email;
//   }
  
//   static Future<void> saveUserPassword(String password) async {
//     _logOperation('SAVE PASSWORD', _passwordKey, value: '[MASKED]');
//     await _storage.write(key: _passwordKey, value: password);
//   }

//   static Future<String?> getUserPassword() async {
//     final password = await _storage.read(key: _passwordKey);
//     _logOperation('GET PASSWORD', _passwordKey, value: password != null ? '[MASKED]' : null);
//     return password;
//   }

//   static Future<void> saveUserCredentials(String email, String password) async {
//     _logOperation('SAVE CREDENTIALS', 'email and password');
//     await _storage.write(key: _emailKey, value: email);
//     await _storage.write(key: _passwordKey, value: password);
//   }

//   // Enhanced token methods with better logging
//   static Future<void> saveToken(String token) async {
//     _logOperation('SAVE TOKEN', _tokenKey, value: token);
//     await _storage.write(key: _tokenKey, value: token);
    
//     // Also save with key 'token' for compatibility with some systems
//     await _storage.write(key: 'token', value: token);
//     debugPrint('Token also saved with key "token" for compatibility');
//   }

//   static Future<String?> getToken() async {
//     // Try both 'auth_token' and 'token' keys for better compatibility
//     String? token = await _storage.read(key: _tokenKey);
    
//     if (token == null || token.isEmpty) {
//       debugPrint('Token not found with key "$_tokenKey", trying key "token"...');
//       token = await _storage.read(key: 'token');
//     }
    
//     _logOperation('GET TOKEN', token != null ? _tokenKey : 'token', value: token);
//     return token;
//   }

//   static Future<bool> hasToken() async {
//     final token = await getToken();
//     return token != null && token.isNotEmpty;
//   }

//   static Future<void> clearCredentials() async {
//     _logOperation('CLEAR ALL CREDENTIALS', 'all keys');
//     await _storage.deleteAll();
//   }
  
//   static Future<void> clearToken() async {
//     _logOperation('CLEAR TOKEN', _tokenKey);
//     await _storage.delete(key: _tokenKey);
//     await _storage.delete(key: 'token');
//   }
  
//   // Debug method to list all stored keys and values (for development only)
//   static Future<Map<String, String>> debugReadAll() async {
//     if (kDebugMode) {
//       final all = await _storage.readAll();
//       debugPrint('=== ALL STORED SECURE DATA ===');
//       all.forEach((key, value) {
//         final maskedValue = key.contains('token') || key.contains('password')
//             ? (value.isNotEmpty ? '${value.substring(0, 5)}...[MASKED]' : '[empty]') 
//             : value;
//         debugPrint('$key: $maskedValue');
//       });
//       debugPrint('==============================');
//       return all;
//     }
//     return {};
//   }
// }













// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class SecureStorageService {
//   static const _storage = FlutterSecureStorage();
//   static const _emailKey = 'user_email';
//   static const _passwordKey = 'user_password';
//   static const _tokenKey = 'auth_token'; // New key for token

//   static Future<void> saveUserEmail(String email) async {
//     await _storage.write(key: _emailKey, value: email);
//   }

//   static Future<String?> getUserEmail() async {
//     return await _storage.read(key: _emailKey);
//   }
  
//   static Future<void> saveUserPassword(String password) async {
//     await _storage.write(key: _passwordKey, value: password);
//   }

//   static Future<String?> getUserPassword() async {
//     return await _storage.read(key: _passwordKey);
//   }

//   static Future<void> saveUserCredentials(String email, String password) async {
//     await _storage.write(key: _emailKey, value: email);
//     await _storage.write(key: _passwordKey, value: password);
//   }

//   // New methods for token handling
//   static Future<void> saveToken(String token) async {
//     await _storage.write(key: _tokenKey, value: token);
//   }

//   static Future<String?> getToken() async {
//     return await _storage.read(key: _tokenKey);
//   }

//   static Future<void> clearCredentials() async {
//     await _storage.deleteAll();
//   }
// }













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
