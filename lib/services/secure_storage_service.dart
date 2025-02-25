// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart'; // Add this import for WebViewController

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

//   static const String _sessionIdKey = 'session_id';
//   static const String _authTokenKey = 'auth_token';

//   // Store session ID
//   static Future<void> saveSessionId(String sessionId) async {
//     await _storage.write(key: _sessionIdKey, value: sessionId);
//   }

//   // Get session ID
//   static Future<String?> getSessionId() async {
//     return await _storage.read(key: _sessionIdKey);
//   }

//   // Store auth token
//   static Future<void> saveAuthToken(String authToken) async {
//     await _storage.write(key: _authTokenKey, value: authToken);
//   }

//   // Get auth token
//   static Future<String?> getAuthToken() async {
//     return await _storage.read(key: _authTokenKey);
//   }

//   // Method to extract and save cookies from WebView
//   static Future<void> extractAndSaveCookiesFromWebView(WebViewController controller) async {
//     try {
//       final script = '''
//         (function() {
//           try {
//             const cookies = document.cookie;
//             return cookies || '';
//           } catch (e) {
//             console.error('Error getting cookies:', e);
//             return '';
//           }
//         })()
//       ''';
      
//       final result = await controller.runJavaScriptReturningResult(script);
//       final cookieString = result.toString().replaceAll('"', '');
      
//       if (cookieString.isNotEmpty && cookieString != 'null') {
//         final cookiePairs = cookieString.split(';');
        
//         for (final pair in cookiePairs) {
//           final keyValue = pair.trim().split('=');
//           if (keyValue.length == 2) {
//             final key = keyValue[0];
//             final value = keyValue[1];
            
//             // Store specific cookies we need
//             if (key == 'PHPSESSID') {
//               await saveSessionId(value);
//             } else if (key.contains('auth') || key.contains('token')) {
//               await saveAuthToken(value);
//             }
//             // Add more conditions for other important cookies
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Error extracting cookies: $e');
//     }
//   }
// }























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
