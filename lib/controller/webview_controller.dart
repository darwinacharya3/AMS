// file: lib/controllers/webview_controller.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class WebViewControllerService {
  static ImagePicker? _currentPicker;
  static bool _isPickerActive = false;
  static String? _lastClickedInputId;  // Track which input was last clicked

  static Future<WebViewController> initialize({
    required Function(bool) onLoadingStateChanged,
    required Function(String) onError,
  }) async {
    final params = _getPlatformSpecificParams();
    final controller = WebViewController.fromPlatformCreationParams(params);

    await _configureController(
      controller,
      onLoadingStateChanged: onLoadingStateChanged,
      onError: onError,
    );

    return controller;
  }

  static PlatformWebViewControllerCreationParams _getPlatformSpecificParams() {
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      return WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    }
    return const PlatformWebViewControllerCreationParams();
  }

  static Future<void> _configureController(
    WebViewController controller, {
    required Function(bool) onLoadingStateChanged,
    required Function(String) onError,
  }) async {
    await controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(_createNavigationDelegate(
        controller: controller,
        onLoadingStateChanged: onLoadingStateChanged,
        onError: onError,
      ))
      ..addJavaScriptChannel(
        'NativeFileUpload',
        onMessageReceived: (JavaScriptMessage message) {
          // The message will contain the input identifier
          _lastClickedInputId = message.message;
          _handleFileUpload(controller);
        },
      )
      ..loadRequest(Uri.parse('https://extratech.extratechweb.com/enrollment-form'));

    _configureAndroidSpecifics(controller);
  }

  static NavigationDelegate _createNavigationDelegate({
    required WebViewController controller,
    required Function(bool) onLoadingStateChanged,
    required Function(String) onError,
  }) {
    return NavigationDelegate(
      onPageStarted: (_) => onLoadingStateChanged(true),
      onPageFinished: (String url) async {
        onLoadingStateChanged(false);
        await _injectFileInputHandler(controller);
      },
      onWebResourceError: (WebResourceError error) {
        onError('Error: ${error.description}');
        print('WebView Error: ${error.description}');
      },
    );
  }

  static void _configureAndroidSpecifics(WebViewController controller) {
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
  }

  static Future<void> _handleFileUpload(WebViewController controller) async {
    if (_isPickerActive || _lastClickedInputId == null) {
      print('Debug: Image picker is already active or no input identified');
      return;
    }

    try {
      _isPickerActive = true;
      _currentPicker = ImagePicker();
      
      print('Debug: Opening image picker for input: $_lastClickedInputId');
      final XFile? image = await _currentPicker?.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        print('Debug: Image selected: ${image.name}');
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        
        await _injectFileData(controller, base64String, image.name, _lastClickedInputId!);
        print('Debug: File data injected successfully');
      } else {
        print('Debug: No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
    } finally {
      _isPickerActive = false;
      _currentPicker = null;
      _lastClickedInputId = null;
      print('Debug: Image picker cleaned up');
    }
  }

  static Future<void> _injectFileData(
    WebViewController controller,
    String base64String,
    String fileName,
    String inputId,
  ) async {
    print('Debug: Starting file data injection for input: $inputId');
    await controller.runJavaScript('''
      (function() {
        try {
          // Find the specific input that was clicked
          const fileInput = document.querySelector('[data-input-id="$inputId"]');
          if (!fileInput) {
            console.error('No file input found with id: $inputId');
            return;
          }
          
          console.log('Found file input:', fileInput.name || fileInput.id);
          
          // Create blob from base64
          const binaryString = atob('$base64String');
          const bytes = new Uint8Array(binaryString.length);
          for (let i = 0; i < binaryString.length; i++) {
            bytes[i] = binaryString.charCodeAt(i);
          }
          const blob = new Blob([bytes], { type: 'image/jpeg' });
          
          // Create file
          const file = new File([blob], '$fileName', { type: 'image/jpeg' });
          
          // Clear existing files
          const dataTransfer = new DataTransfer();
          dataTransfer.items.add(file);
          fileInput.files = dataTransfer.files;
          
          // Update filename display
          const filenameDisplay = fileInput.parentElement.querySelector('.filename-display');
          if (filenameDisplay) {
            filenameDisplay.textContent = '$fileName';
          }
          
          // Trigger events
          const changeEvent = new Event('change', { bubbles: true });
          const inputEvent = new Event('input', { bubbles: true });
          fileInput.dispatchEvent(changeEvent);
          fileInput.dispatchEvent(inputEvent);
          
          console.log('File upload completed for input: $inputId');
        } catch (error) {
          console.error('Error in file upload:', error);
        }
      })();
    ''');
  }

  static Future<void> _injectFileInputHandler(WebViewController controller) async {
    const jsCode = '''
      // Define our file input IDs
      const fileInputs = [
        { id: 'profile-image', label: 'Profile Image' },
        { id: 'passport-front', label: 'Passport Front' },
        { id: 'passport-back', label: 'Passport Back' },
        { id: 'payment-slip', label: 'Payment Slip' }
      ];
      
      function setupFileInputs() {
        const inputs = document.querySelectorAll('input[type="file"]');
        inputs.forEach((input, index) => {
          if (index < fileInputs.length) {
            // Add our custom identifier
            input.setAttribute('data-input-id', fileInputs[index].id);
            
            // Create filename display if doesn't exist
            let filenameDisplay = input.parentElement.querySelector('.filename-display');
            if (!filenameDisplay) {
              filenameDisplay = document.createElement('span');
              filenameDisplay.className = 'filename-display';
              filenameDisplay.style.marginLeft = '10px';
              input.parentElement.appendChild(filenameDisplay);
            }
            
            // Add click handler
            input.addEventListener('click', function(e) {
              e.preventDefault();
              // Pass the input identifier to the native code
              NativeFileUpload.postMessage(fileInputs[index].id);
            });
          }
        });
      }
      
      // Initial setup
      setupFileInputs();
      
      // Watch for dynamic changes
      const observer = new MutationObserver(function(mutations) {
        setupFileInputs();
      });
      
      observer.observe(document.body, { 
        childList: true, 
        subtree: true 
      });
    ''';

    try {
      await controller.runJavaScript(jsCode);
      print('Debug: File input handler injected successfully');
    } catch (e) {
      print('Error injecting file input handler: $e');
    }
  }
}



















// // file: lib/controllers/webview_controller.dart
// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';

// class WebViewControllerService {
  

//   static Future<WebViewController> initialize({
//     required Function(bool) onLoadingStateChanged,
//     required Function(String) onError,
//   }) async {
//     final params = _getPlatformSpecificParams();
//     final controller = WebViewController.fromPlatformCreationParams(params);

//     await _configureController(
//       controller,
//       onLoadingStateChanged: onLoadingStateChanged,
//       onError: onError,
//     );

//     return controller;
//   }

//   static PlatformWebViewControllerCreationParams _getPlatformSpecificParams() {
//     if (WebViewPlatform.instance is WebKitWebViewPlatform) {
//       return WebKitWebViewControllerCreationParams(
//         allowsInlineMediaPlayback: true,
//         mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
//       );
//     }
//     return const PlatformWebViewControllerCreationParams();
//   }

//   static Future<void> _configureController(
//     WebViewController controller, {
//     required Function(bool) onLoadingStateChanged,
//     required Function(String) onError,
//   }) async {
//     await controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(_createNavigationDelegate(
//         controller: controller,
//         onLoadingStateChanged: onLoadingStateChanged,
//         onError: onError,
//       ))
//       ..addJavaScriptChannel(
//         'NativeFileUpload',
//         onMessageReceived: (message) => _handleFileUpload(controller),
//       )
//       ..loadRequest(Uri.parse('https://extratech.extratechweb.com/enrollment-form'));

//     _configureAndroidSpecifics(controller);
//   }

//   static NavigationDelegate _createNavigationDelegate({
//     required WebViewController controller,
//     required Function(bool) onLoadingStateChanged,
//     required Function(String) onError,
//   }) {
//     return NavigationDelegate(
//       onPageStarted: (_) => onLoadingStateChanged(true),
//       onPageFinished: (String url) async {
//         onLoadingStateChanged(false);
//         await _injectFileInputHandler(controller);
//       },
//       onWebResourceError: (WebResourceError error) {
//         onError('Error: ${error.description}');
//         print('WebView Error: ${error.description}');
//       },
//     );
//   }

//   static void _configureAndroidSpecifics(WebViewController controller) {
//     if (controller.platform is AndroidWebViewController) {
//       AndroidWebViewController.enableDebugging(true);
//       (controller.platform as AndroidWebViewController)
//           .setMediaPlaybackRequiresUserGesture(false);
//     }
//   }

//   static Future<void> _handleFileUpload(WebViewController controller) async {
//     final ImagePicker picker = ImagePicker();
//     try {
//       final XFile? image = await picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );

//       if (image != null) {
//         final bytes = await image.readAsBytes();
//         final base64String = base64Encode(bytes);
//         await _injectFileData(controller, base64String, image.name);
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//     }
//   }

//   static Future<void> _injectFileData(
//     WebViewController controller,
//     String base64String,
//     String fileName,
//   ) async {
//     await controller.runJavaScript('''
//       (function() {
//         try {
//           const fileInput = document.querySelector('input[type="file"]');
//           if (!fileInput) {
//             console.error('No file input found');
//             return;
//           }
          
//           const binaryString = atob('$base64String');
//           const bytes = new Uint8Array(binaryString.length);
//           for (let i = 0; i < binaryString.length; i++) {
//             bytes[i] = binaryString.charCodeAt(i);
//           }
//           const blob = new Blob([bytes], { type: 'image/jpeg' });
//           const file = new File([blob], '$fileName', { type: 'image/jpeg' });
          
//           const dataTransfer = new DataTransfer();
//           dataTransfer.items.add(file);
//           fileInput.files = dataTransfer.files;
          
//           const event = new Event('change', { bubbles: true });
//           fileInput.dispatchEvent(event);
//         } catch (error) {
//           console.error('Error in file upload:', error);
//         }
//       })();
//     ''');
//   }

//   static Future<void> _injectFileInputHandler(WebViewController controller) async {
//     // JavaScript to handle file input clicks
//     const jsCode = '''
//       function setupFileInputs() {
//         const fileInputs = document.querySelectorAll('input[type="file"]');
//         fileInputs.forEach(input => {
//           input.addEventListener('click', function(e) {
//             e.preventDefault();
//             NativeFileUpload.postMessage('selectFile');
//           });
//         });
//       }
      
//       setupFileInputs();
//       const observer = new MutationObserver(function(mutations) {
//         setupFileInputs();
//       });
//       observer.observe(document.body, { 
//         childList: true, 
//         subtree: true 
//       });
//     ''';

//     try {
//       await controller.runJavaScript(jsCode);
//     } catch (e) {
//       print('Error injecting file input handler: $e');
//     }
//   }
// }