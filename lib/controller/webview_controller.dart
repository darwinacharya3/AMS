
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
    required Function() onSignupSuccess,
  }) async {
    final params = _getPlatformSpecificParams();
    final controller = WebViewController.fromPlatformCreationParams(params);

    await _configureController(
      controller,
      onLoadingStateChanged: onLoadingStateChanged,
      onError: onError,
      onSignupSuccess: onSignupSuccess,
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
    required Function() onSignupSuccess,
  }) async {
    await controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(_createNavigationDelegate(
        controller: controller,
        onLoadingStateChanged: onLoadingStateChanged,
        onError: onError,
        onSignupSuccess: onSignupSuccess,
      ))
      ..addJavaScriptChannel(
        'NativeFileUpload',
        onMessageReceived: (JavaScriptMessage message) {
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
    required Function() onSignupSuccess,
  }) {
    return NavigationDelegate(
      onPageStarted: (String url) {
        // print('Debug: Page started loading: $url');
        onLoadingStateChanged(true);
      },
      onPageFinished: (String url) async {
        // print('Debug: Page finished loading: $url');
        onLoadingStateChanged(false);
        await _injectFileInputHandler(controller);

        // Check if this is the student dashboard URL
        if (url.contains('extratechweb.com/student')) {
          onSignupSuccess();
        }
      },
      onWebResourceError: (WebResourceError error) {
        onError('Error: ${error.description}');
        // print('WebView Error: ${error.description}');
      },
      onNavigationRequest: (NavigationRequest request) {
        // print('Debug: Navigation requested to: ${request.url}');
        
        // Check for student dashboard URL in navigation request
        if (request.url.contains('extratechweb.com/student')) {
          // Allow the navigation to complete first
          Future.delayed(const Duration(milliseconds: 100), () {
            onSignupSuccess();
          });
        }
        
        return NavigationDecision.navigate;
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
      // print('Debug: Image picker is already active or no input identified');
      return;
    }

    try {
      _isPickerActive = true;
      _currentPicker = ImagePicker();
      
      // print('Debug: Opening image picker for input: $_lastClickedInputId');
      final XFile? image = await _currentPicker?.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        // print('Debug: Image selected: ${image.name}');
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        
        await _injectFileData(controller, base64String, image.name, _lastClickedInputId!);
        // print('Debug: File data injected successfully');
      } else {
        // print('Debug: No image selected');
      }
    } catch (e) {
      // print('Error picking image: $e');
    } finally {
      _isPickerActive = false;
      _currentPicker = null;
      _lastClickedInputId = null;
      // print('Debug: Image picker cleaned up');
    }
  }

  static Future<void> _injectFileData(
    WebViewController controller,
    String base64String,
    String fileName,
    String inputId,
  ) async {
    // print('Debug: Starting file data injection for input: $inputId');
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
      // print('Debug: File input handler injected successfully');
    } catch (e) {
      // print('Error injecting file input handler: $e');
    }
  }
}


























// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';

// class WebViewControllerService {
//   static ImagePicker? _currentPicker;
//   static bool _isPickerActive = false;
//   static String? _lastClickedInputId;  // Track which input was last clicked

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
//         onMessageReceived: (JavaScriptMessage message) {
//           // The message will contain the input identifier
//           _lastClickedInputId = message.message;
//           _handleFileUpload(controller);
//         },
//       )
//       ..loadRequest(Uri.parse('https://extratech.extratechweb.com/enrollment-form'));
//     await _injectCustomStyles(controller);
//     _configureAndroidSpecifics(controller);
//   }

// static Future<void> _injectCustomStyles(WebViewController controller) async {
//     const String customCSS = '''
//       /* Hide original navbar and logo */
//       .navbar-brand-wrapper {
//         display: none !important;
//       }
      
//       /* Hide original hamburger menu from navbar */
//       .navbar-menu-wrapper .navbar-toggler {
//         display: none !important;
//       }
      
//       /* Adjust profile section */
//       .profile-top.profile-top-flex-2 {
//         position: relative !important;
//         padding-right: 60px !important;
//       }
      
//       /* Hamburger menu styling */
//       .profile-top.profile-top-flex-2::after {
//         content: "" !important;
//         position: absolute !important;
//         right: 15px !important;
//         top: 50% !important;
//         transform: translateY(-50%) !important;
//         width: 30px !important;
//         height: 30px !important;
//         background-image: url('https://extratech.extratechweb.com/images/navigation-bar.png') !important;
//         background-size: contain !important;
//         background-repeat: no-repeat !important;
//         background-position: center !important;
//         cursor: pointer !important;
//       }
      
//       /* Profile section layout */
//       .profile-general {
//         display: flex !important;
//         align-items: center !important;
//         gap: 15px !important;
//       }
      
//       .profile-desc {
//         margin-left: 10px !important;
//       }

//       /* Hide original navigation tabs */
//       .nav.nav-tabs.student-nav-tabs {
//         display: none !important;
//       }

//       /* Sidebar styling */
//       .mdc-drawer {
//         transform: translateX(100%) !important;
//         transition: transform 0.3s ease-in-out !important;
//       }

//       .mdc-drawer.mdc-drawer--open {
//         transform: translateX(0) !important;
//       }

//       /* Ensure sidebar items maintain original styling */
//       .mdc-drawer .nav-link {
//         color: inherit !important;
//         text-decoration: none !important;
//         display: flex !important;
//         align-items: center !important;
//         padding: 12px 16px !important;
//       }

//       .mdc-drawer .nav-link i {
//         margin-right: 12px !important;
//       }

//       /* Mobile responsive adjustments */
//       @media (max-width: 768px) {
//         .profile-top.profile-top-flex-2 {
//           padding-right: 50px !important;
//         }
        
//         .profile-top.profile-top-flex-2::after {
//           right: 10px !important;
//         }
//       }
//     ''';

//     const String jsCode = '''
//       // Add custom styles
//       var style = document.createElement('style');
//       style.textContent = `${customCSS}`;
//       document.head.appendChild(style);

//       // Move navigation items to sidebar
//       function moveNavigationToSidebar() {
//         const sidebarContent = document.querySelector('.mdc-drawer__content');
//         const navItems = document.querySelectorAll('.nav-tabs .nav-link');
//         const menuList = sidebarContent.querySelector('ul');
        
//         // Get the position before logout
//         const logoutItem = menuList.querySelector('a[href*="logout"]').parentElement;
        
//         navItems.forEach(item => {
//           // Clone the entire item to preserve event listeners and data attributes
//           const newItem = item.cloneNode(true);
//           const listItem = document.createElement('li');
//           listItem.className = 'nav-item';
//           listItem.appendChild(newItem);
          
//           // Preserve all original attributes and event handlers
//           newItem.getAttributeNames().forEach(attr => {
//             if (attr.startsWith('data-bs-')) {
//               listItem.setAttribute(attr, newItem.getAttribute(attr));
//             }
//           });
          
//           // Insert before logout
//           menuList.insertBefore(listItem, logoutItem);
//         });
//       }

//       // Handle back button
//       window.addEventListener('popstate', (event) => {
//         const drawer = document.querySelector('.mdc-drawer');
//         if (drawer && drawer.classList.contains('mdc-drawer--open')) {
//           event.preventDefault();
//           drawer.classList.remove('mdc-drawer--open');
//         }
//       });

//       // Add click handler to hamburger menu
//       document.querySelector('.profile-top.profile-top-flex-2').addEventListener('click', function(e) {
//         const rect = this.getBoundingClientRect();
//         const clickX = e.clientX - rect.left;
        
//         if (clickX > rect.width - 60) {
//           const drawer = document.querySelector('.mdc-drawer');
//           drawer.classList.toggle('mdc-drawer--open');
          
//           if (drawer.classList.contains('mdc-drawer--open')) {
//             history.pushState({ drawerOpen: true }, '');
//           }
//         }
//       });

//       // Add swipe gesture support
//       let touchStartX = 0;
//       let touchEndX = 0;
      
//       document.addEventListener('touchstart', e => {
//         touchStartX = e.changedTouches[0].screenX;
//       }, false);
      
//       document.addEventListener('touchend', e => {
//         touchEndX = e.changedTouches[0].screenX;
//         handleSwipe();
//       }, false);
      
//       function handleSwipe() {
//         const swipeThreshold = 50;
//         const swipeLength = touchEndX - touchStartX;
//         const drawer = document.querySelector('.mdc-drawer');
        
//         if (Math.abs(swipeLength) > swipeThreshold) {
//           if (swipeLength < 0 && drawer.classList.contains('mdc-drawer--open')) {
//             // Swipe left - close drawer
//             drawer.classList.remove('mdc-drawer--open');
//           } else if (swipeLength > 0 && !drawer.classList.contains('mdc-drawer--open')) {
//             // Swipe right - open drawer
//             drawer.classList.add('mdc-drawer--open');
//             history.pushState({ drawerOpen: true }, '');
//           }
//         }
//       }

//       // Initialize everything after page load
//       window.addEventListener('load', () => {
//         moveNavigationToSidebar();
//       });
//     ''';

//     try {
//       await controller.runJavaScript(jsCode);
//       print('Debug: Custom styles and navigation handlers injected successfully');
//     } catch (e) {
//       print('Error injecting custom styles: $e');
//     }
// }


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
//          await _injectCustomStyles(controller);
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
//     if (_isPickerActive || _lastClickedInputId == null) {
//       print('Debug: Image picker is already active or no input identified');
//       return;
//     }

//     try {
//       _isPickerActive = true;
//       _currentPicker = ImagePicker();
      
//       print('Debug: Opening image picker for input: $_lastClickedInputId');
//       final XFile? image = await _currentPicker?.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );

//       if (image != null) {
//         print('Debug: Image selected: ${image.name}');
//         final bytes = await image.readAsBytes();
//         final base64String = base64Encode(bytes);
        
//         await _injectFileData(controller, base64String, image.name, _lastClickedInputId!);
//         print('Debug: File data injected successfully');
//       } else {
//         print('Debug: No image selected');
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//     } finally {
//       _isPickerActive = false;
//       _currentPicker = null;
//       _lastClickedInputId = null;
//       print('Debug: Image picker cleaned up');
//     }
//   }

//   static Future<void> _injectFileData(
//     WebViewController controller,
//     String base64String,
//     String fileName,
//     String inputId,
//   ) async {
//     print('Debug: Starting file data injection for input: $inputId');
//     await controller.runJavaScript('''
//       (function() {
//         try {
//           // Find the specific input that was clicked
//           const fileInput = document.querySelector('[data-input-id="$inputId"]');
//           if (!fileInput) {
//             console.error('No file input found with id: $inputId');
//             return;
//           }
          
//           console.log('Found file input:', fileInput.name || fileInput.id);
          
//           // Create blob from base64
//           const binaryString = atob('$base64String');
//           const bytes = new Uint8Array(binaryString.length);
//           for (let i = 0; i < binaryString.length; i++) {
//             bytes[i] = binaryString.charCodeAt(i);
//           }
//           const blob = new Blob([bytes], { type: 'image/jpeg' });
          
//           // Create file
//           const file = new File([blob], '$fileName', { type: 'image/jpeg' });
          
//           // Clear existing files
//           const dataTransfer = new DataTransfer();
//           dataTransfer.items.add(file);
//           fileInput.files = dataTransfer.files;
          
//           // Update filename display
//           const filenameDisplay = fileInput.parentElement.querySelector('.filename-display');
//           if (filenameDisplay) {
//             filenameDisplay.textContent = '$fileName';
//           }
          
//           // Trigger events
//           const changeEvent = new Event('change', { bubbles: true });
//           const inputEvent = new Event('input', { bubbles: true });
//           fileInput.dispatchEvent(changeEvent);
//           fileInput.dispatchEvent(inputEvent);
          
//           console.log('File upload completed for input: $inputId');
//         } catch (error) {
//           console.error('Error in file upload:', error);
//         }
//       })();
//     ''');
//   }

//   static Future<void> _injectFileInputHandler(WebViewController controller) async {
//     const jsCode = '''
//       // Define our file input IDs
//       const fileInputs = [
//         { id: 'profile-image', label: 'Profile Image' },
//         { id: 'passport-front', label: 'Passport Front' },
//         { id: 'passport-back', label: 'Passport Back' },
//         { id: 'payment-slip', label: 'Payment Slip' }
//       ];
      
//       function setupFileInputs() {
//         const inputs = document.querySelectorAll('input[type="file"]');
//         inputs.forEach((input, index) => {
//           if (index < fileInputs.length) {
//             // Add our custom identifier
//             input.setAttribute('data-input-id', fileInputs[index].id);
            
//             // Create filename display if doesn't exist
//             let filenameDisplay = input.parentElement.querySelector('.filename-display');
//             if (!filenameDisplay) {
//               filenameDisplay = document.createElement('span');
//               filenameDisplay.className = 'filename-display';
//               filenameDisplay.style.marginLeft = '10px';
//               input.parentElement.appendChild(filenameDisplay);
//             }
            
//             // Add click handler
//             input.addEventListener('click', function(e) {
//               e.preventDefault();
//               // Pass the input identifier to the native code
//               NativeFileUpload.postMessage(fileInputs[index].id);
//             });
//           }
//         });
//       }
      
//       // Initial setup
//       setupFileInputs();
      
//       // Watch for dynamic changes
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
//       print('Debug: File input handler injected successfully');
//     } catch (e) {
//       print('Error injecting file input handler: $e');
//     }
//   }
// }










































// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';

// class WebViewControllerService {
//   static ImagePicker? _currentPicker;
//   static bool _isPickerActive = false;
//   static String? _lastClickedInputId;  // Track which input was last clicked

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
//         onMessageReceived: (JavaScriptMessage message) {
//           // The message will contain the input identifier
//           _lastClickedInputId = message.message;
//           _handleFileUpload(controller);
//         },
//       )
//       ..loadRequest(Uri.parse('https://extratech.extratechweb.com/enrollment-form'));
//     await _injectCustomStyles(controller);
//     _configureAndroidSpecifics(controller);
//   }

// static Future<void> _injectCustomStyles(WebViewController controller) async {
//     const String customCSS = '''
//       /* Hide original navbar and logo */
//       .navbar-brand-wrapper {
//         display: none !important;
//       }
      
//       /* Hide original hamburger menu from navbar */
//       .navbar-menu-wrapper .navbar-toggler {
//         display: none !important;
//       }
      
//       /* Adjust profile section */
//       .profile-top.profile-top-flex-2 {
//         position: relative !important;
//         padding-right: 60px !important;
//       }
      
//       /* Hamburger menu styling */
//       .profile-top.profile-top-flex-2::after {
//         content: "" !important;
//         position: absolute !important;
//         right: 15px !important;
//         top: 50% !important;
//         transform: translateY(-50%) !important;
//         width: 30px !important;
//         height: 30px !important;
//         background-image: url('https://extratech.extratechweb.com/images/navigation-bar.png') !important;
//         background-size: contain !important;
//         background-repeat: no-repeat !important;
//         background-position: center !important;
//         cursor: pointer !important;
//       }
      
//       /* Profile section layout */
//       .profile-general {
//         display: flex !important;
//         align-items: center !important;
//         gap: 15px !important;
//       }
      
//       .profile-desc {
//         margin-left: 10px !important;
//       }

//       /* Hide original navigation tabs */
//       .nav.nav-tabs.student-nav-tabs {
//         display: none !important;
//       }

//       /* Sidebar styling */
//       .mdc-drawer {
//         transform: translateX(100%) !important;
//         transition: transform 0.3s ease-in-out !important;
//       }

//       .mdc-drawer.mdc-drawer--open {
//         transform: translateX(0) !important;
//       }

//       /* Ensure sidebar items maintain original styling */
//       .mdc-drawer .nav-link {
//         color: inherit !important;
//         text-decoration: none !important;
//         display: flex !important;
//         align-items: center !important;
//         padding: 12px 16px !important;
//       }

//       .mdc-drawer .nav-link i {
//         margin-right: 12px !important;
//       }

//       /* Mobile responsive adjustments */
//       @media (max-width: 768px) {
//         .profile-top.profile-top-flex-2 {
//           padding-right: 50px !important;
//         }
        
//         .profile-top.profile-top-flex-2::after {
//           right: 10px !important;
//         }
//       }
//     ''';

//     const String jsCode = '''
//       // Add custom styles
//       var style = document.createElement('style');
//       style.textContent = `${customCSS}`;
//       document.head.appendChild(style);

//       // Move navigation items to sidebar
//       function moveNavigationToSidebar() {
//         const sidebarContent = document.querySelector('.mdc-drawer__content');
//         const navItems = document.querySelectorAll('.nav-tabs .nav-link');
//         const menuList = sidebarContent.querySelector('ul');
        
//         // Get the position before logout
//         const logoutItem = menuList.querySelector('a[href*="logout"]').parentElement;
        
//         navItems.forEach(item => {
//           // Clone the entire item to preserve event listeners and data attributes
//           const newItem = item.cloneNode(true);
//           const listItem = document.createElement('li');
//           listItem.className = 'nav-item';
//           listItem.appendChild(newItem);
          
//           // Preserve all original attributes and event handlers
//           newItem.getAttributeNames().forEach(attr => {
//             if (attr.startsWith('data-bs-')) {
//               listItem.setAttribute(attr, newItem.getAttribute(attr));
//             }
//           });
          
//           // Insert before logout
//           menuList.insertBefore(listItem, logoutItem);
//         });
//       }

//       // Handle back button
//       window.addEventListener('popstate', (event) => {
//         const drawer = document.querySelector('.mdc-drawer');
//         if (drawer && drawer.classList.contains('mdc-drawer--open')) {
//           event.preventDefault();
//           drawer.classList.remove('mdc-drawer--open');
//         }
//       });

//       // Add click handler to hamburger menu
//       document.querySelector('.profile-top.profile-top-flex-2').addEventListener('click', function(e) {
//         const rect = this.getBoundingClientRect();
//         const clickX = e.clientX - rect.left;
        
//         if (clickX > rect.width - 60) {
//           const drawer = document.querySelector('.mdc-drawer');
//           drawer.classList.toggle('mdc-drawer--open');
          
//           if (drawer.classList.contains('mdc-drawer--open')) {
//             history.pushState({ drawerOpen: true }, '');
//           }
//         }
//       });

//       // Add swipe gesture support
//       let touchStartX = 0;
//       let touchEndX = 0;
      
//       document.addEventListener('touchstart', e => {
//         touchStartX = e.changedTouches[0].screenX;
//       }, false);
      
//       document.addEventListener('touchend', e => {
//         touchEndX = e.changedTouches[0].screenX;
//         handleSwipe();
//       }, false);
      
//       function handleSwipe() {
//         const swipeThreshold = 50;
//         const swipeLength = touchEndX - touchStartX;
//         const drawer = document.querySelector('.mdc-drawer');
        
//         if (Math.abs(swipeLength) > swipeThreshold) {
//           if (swipeLength < 0 && drawer.classList.contains('mdc-drawer--open')) {
//             // Swipe left - close drawer
//             drawer.classList.remove('mdc-drawer--open');
//           } else if (swipeLength > 0 && !drawer.classList.contains('mdc-drawer--open')) {
//             // Swipe right - open drawer
//             drawer.classList.add('mdc-drawer--open');
//             history.pushState({ drawerOpen: true }, '');
//           }
//         }
//       }

//       // Initialize everything after page load
//       window.addEventListener('load', () => {
//         moveNavigationToSidebar();
//       });
//     ''';

//     try {
//       await controller.runJavaScript(jsCode);
//       print('Debug: Custom styles and navigation handlers injected successfully');
//     } catch (e) {
//       print('Error injecting custom styles: $e');
//     }
// }


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
//          await _injectCustomStyles(controller);
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
//     if (_isPickerActive || _lastClickedInputId == null) {
//       print('Debug: Image picker is already active or no input identified');
//       return;
//     }

//     try {
//       _isPickerActive = true;
//       _currentPicker = ImagePicker();
      
//       print('Debug: Opening image picker for input: $_lastClickedInputId');
//       final XFile? image = await _currentPicker?.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );

//       if (image != null) {
//         print('Debug: Image selected: ${image.name}');
//         final bytes = await image.readAsBytes();
//         final base64String = base64Encode(bytes);
        
//         await _injectFileData(controller, base64String, image.name, _lastClickedInputId!);
//         print('Debug: File data injected successfully');
//       } else {
//         print('Debug: No image selected');
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//     } finally {
//       _isPickerActive = false;
//       _currentPicker = null;
//       _lastClickedInputId = null;
//       print('Debug: Image picker cleaned up');
//     }
//   }

//   static Future<void> _injectFileData(
//     WebViewController controller,
//     String base64String,
//     String fileName,
//     String inputId,
//   ) async {
//     print('Debug: Starting file data injection for input: $inputId');
//     await controller.runJavaScript('''
//       (function() {
//         try {
//           // Find the specific input that was clicked
//           const fileInput = document.querySelector('[data-input-id="$inputId"]');
//           if (!fileInput) {
//             console.error('No file input found with id: $inputId');
//             return;
//           }
          
//           console.log('Found file input:', fileInput.name || fileInput.id);
          
//           // Create blob from base64
//           const binaryString = atob('$base64String');
//           const bytes = new Uint8Array(binaryString.length);
//           for (let i = 0; i < binaryString.length; i++) {
//             bytes[i] = binaryString.charCodeAt(i);
//           }
//           const blob = new Blob([bytes], { type: 'image/jpeg' });
          
//           // Create file
//           const file = new File([blob], '$fileName', { type: 'image/jpeg' });
          
//           // Clear existing files
//           const dataTransfer = new DataTransfer();
//           dataTransfer.items.add(file);
//           fileInput.files = dataTransfer.files;
          
//           // Update filename display
//           const filenameDisplay = fileInput.parentElement.querySelector('.filename-display');
//           if (filenameDisplay) {
//             filenameDisplay.textContent = '$fileName';
//           }
          
//           // Trigger events
//           const changeEvent = new Event('change', { bubbles: true });
//           const inputEvent = new Event('input', { bubbles: true });
//           fileInput.dispatchEvent(changeEvent);
//           fileInput.dispatchEvent(inputEvent);
          
//           console.log('File upload completed for input: $inputId');
//         } catch (error) {
//           console.error('Error in file upload:', error);
//         }
//       })();
//     ''');
//   }

//   static Future<void> _injectFileInputHandler(WebViewController controller) async {
//     const jsCode = '''
//       // Define our file input IDs
//       const fileInputs = [
//         { id: 'profile-image', label: 'Profile Image' },
//         { id: 'passport-front', label: 'Passport Front' },
//         { id: 'passport-back', label: 'Passport Back' },
//         { id: 'payment-slip', label: 'Payment Slip' }
//       ];
      
//       function setupFileInputs() {
//         const inputs = document.querySelectorAll('input[type="file"]');
//         inputs.forEach((input, index) => {
//           if (index < fileInputs.length) {
//             // Add our custom identifier
//             input.setAttribute('data-input-id', fileInputs[index].id);
            
//             // Create filename display if doesn't exist
//             let filenameDisplay = input.parentElement.querySelector('.filename-display');
//             if (!filenameDisplay) {
//               filenameDisplay = document.createElement('span');
//               filenameDisplay.className = 'filename-display';
//               filenameDisplay.style.marginLeft = '10px';
//               input.parentElement.appendChild(filenameDisplay);
//             }
            
//             // Add click handler
//             input.addEventListener('click', function(e) {
//               e.preventDefault();
//               // Pass the input identifier to the native code
//               NativeFileUpload.postMessage(fileInputs[index].id);
//             });
//           }
//         });
//       }
      
//       // Initial setup
//       setupFileInputs();
      
//       // Watch for dynamic changes
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
//       print('Debug: File input handler injected successfully');
//     } catch (e) {
//       print('Error injecting file input handler: $e');
//     }
//   }
// }













// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';

// typedef UrlChangeCallback = void Function(String url);


// class WebViewControllerService {
//   static ImagePicker? _currentPicker;
//   static bool _isPickerActive = false;
//   static String? _lastClickedInputId;  // Track which input was last clicked

//   static Future<WebViewController> initialize({
//     required Function(bool) onLoadingStateChanged,
//     required Function(String) onError,
//     required UrlChangeCallback onUrlChanged,
//   }) async {
//     final params = _getPlatformSpecificParams();
//     final controller = WebViewController.fromPlatformCreationParams(params);

//     await _configureController(
//       controller,
//       onLoadingStateChanged: onLoadingStateChanged,
//       onError: onError,
//       onUrlChanged: onUrlChanged,
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
//   WebViewController controller, {
//   required Function(bool) onLoadingStateChanged,
//   required Function(String) onError,
//   required UrlChangeCallback onUrlChanged,
// }) async {
//   await controller
//     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..setBackgroundColor(const Color(0x00000000))
//     ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             onLoadingStateChanged(true);
//             onUrlChanged(url);
//           },
//           onPageFinished: (String url) {
//             onLoadingStateChanged(false);
//             onUrlChanged(url);
//           },
//           onWebResourceError: (WebResourceError error) {
//             onError('Error: ${error.description}');
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             onUrlChanged(request.url);
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//     ..setNavigationDelegate(_createNavigationDelegate(
//       controller: controller,
//       onLoadingStateChanged: onLoadingStateChanged,
//       onError: onError,
//     ))
//     ..addJavaScriptChannel(
//       'NativeFileUpload',
//       onMessageReceived: (JavaScriptMessage message) {
//         _lastClickedInputId = message.message;
//         _handleFileUpload(controller);
//       },
//     )
//     // Just load the URL, do NOT inject items here
//     ..loadRequest(Uri.parse('https://extratech.extratechweb.com/enrollment-form'));

//   // Optionally inject CSS only
//   await _injectCustomStyles(controller);

//   _configureAndroidSpecifics(controller);
// }

// static Future<bool> handleBackNavigation(WebViewController controller) async {
//     try {
//       final canGoBack = await controller.canGoBack();
//       if (canGoBack) {
//         // Prevent any automatic redirection after going back
//         await controller.runJavaScript('''
//           window.addEventListener('popstate', function(event) {
//             event.preventDefault();
//           }, { once: true });
//         ''');
        
//         await controller.goBack();
//         return false; // Don't close the app
//       }
//       return true; // Allow closing the app
//     } catch (e) {
//       print('Error handling back navigation: $e');
//       return true; // Allow closing the app if there's an error
//     }
//   }

// //  static Future<bool> handleBackNavigation(WebViewController controller) async {
// //     try {
// //       final canGoBack = await controller.canGoBack();
// //       if (canGoBack) {
// //         await controller.goBack();
// //         return false; // Don't close the app
// //       }
// //       return true; // Allow closing the app
// //     } catch (e) {
// //       print('Error handling back navigation: $e');
// //       return true; // Allow closing the app if there's an error
// //     }
// //   }


// static Future<void> _injectCustomStyles(WebViewController controller) async {
//     const String customCSS = '''
//       /* Hide original navbar and logo */
//       .navbar-brand-wrapper {
//         display: none !important;
//       }
      
//       /* Hide original hamburger menu from navbar */
//       .navbar-menu-wrapper .navbar-toggler {
//         display: none !important;
//       }
      
//       /* Adjust profile section */
//       .profile-top.profile-top-flex-2 {
//         position: relative !important;
//         padding-right: 60px !important;
//       }
      
//       /* Hamburger menu styling */
//       .profile-top.profile-top-flex-2::after {
//         content: "" !important;
//         position: absolute !important;
//         right: 15px !important;
//         top: 50% !important;
//         transform: translateY(-50%) !important;
//         width: 30px !important;
//         height: 30px !important;
//         background-image: url('https://extratech.extratechweb.com/images/navigation-bar.png') !important;
//         background-size: contain !important;
//         background-repeat: no-repeat !important;
//         background-position: center !important;
//         cursor: pointer !important;
//       }
      
//       /* Profile section layout */
//       .profile-general {
//         display: flex !important;
//         align-items: center !important;
//         gap: 15px !important;
//       }
      
//       .profile-desc {
//         margin-left: 10px !important;
//       }

//       /* Hide original navigation tabs */
//       .nav.nav-tabs.student-nav-tabs {
//         display: none !important;
//       }

//       /* Sidebar styling */
//       .mdc-drawer {
//         transform: translateX(100%) !important;
//         transition: transform 0.3s ease-in-out !important;
//       }

//       .mdc-drawer.mdc-drawer--open {
//         transform: translateX(0) !important;
//       }

//       /* Ensure sidebar items maintain original styling */
//       .mdc-drawer .nav-link {
//         color: inherit !important;
//         text-decoration: none !important;
//         display: flex !important;
//         align-items: center !important;
//         padding: 12px 16px !important;
//       }

//       .mdc-drawer .nav-link i {
//         margin-right: 12px !important;
//       }

//       /* Mobile responsive adjustments */
//       @media (max-width: 768px) {
//         .profile-top.profile-top-flex-2 {
//           padding-right: 50px !important;
//         }
        
//         .profile-top.profile-top-flex-2::after {
//           right: 10px !important;
//         }
//       }
//     ''';

//     // Add click handler for the new hamburger menu
//     const String jsCode = '''
//       // Add custom styles
//       var style = document.createElement('style');
//       style.textContent = `${customCSS}`;
//       document.head.appendChild(style);
      
//       // Add click handler to new hamburger menu
//       document.querySelector('.profile-top.profile-top-flex-2').addEventListener('click', function(e) {
//         // Check if click was on the hamburger menu area
//         const rect = this.getBoundingClientRect();
//         const clickX = e.clientX - rect.left;
        
//         if (clickX > rect.width - 60) { // If click is in hamburger menu area
//           // Trigger original navbar toggle
//           document.querySelector('.navbar-toggler').click();
//         }
//       });
//     ''';

//     try {
//       await controller.runJavaScript(jsCode);
//       // print('Debug: Custom styles and click handler injected successfully');
//     } catch (e) {
//       // print('Error injecting custom styles: $e');
//     }

// }


// static Future<void> _injectSidebarNavItems(WebViewController controller) async {
//   const String jsCode = '''
//     (function() {
//       // Locate the sidebar navigation container and the Dashboard item
//       var sidebarNav = document.querySelector('#sidebar ul.nav');
//       if (!sidebarNav) {
//         console.error("Sidebar navigation container not found.");
//         return;
//       }

//       var dashboardItem = sidebarNav.querySelector('li.nav-item.active');
//       if (!dashboardItem) {
//         console.error("Dashboard item not found.");
//         return;
//       }

//       // Select the hidden nav items from the profile section
//       var profileNavItems = document.querySelectorAll('.nav.nav-tabs.student-nav-tabs a.nav-link');
//       if (!profileNavItems.length) {
//         console.error("Profile nav items not found.");
//         return;
//       }

//       profileNavItems.forEach(function(item) {
//         // Create a new <li> to match the sidebar structure
//         var newItem = document.createElement('li');
//         newItem.className = 'nav-item';

//         // Clone the <a> tag
//         var clonedLink = item.cloneNode(true);

//         // Make sure it has the nav-link class so existing CSS and JS can target it
//         clonedLink.classList.add('nav-link');

//         // Attach a click listener that closes the sidebar
//         clonedLink.addEventListener('click', function() {
//           var drawer = document.querySelector('.mdc-drawer');
//           if (drawer) {
//             drawer.classList.remove('mdc-drawer--open');
//           }
//         });

//         // Optional: remove classes that cause misalignment (e.g., 'col', 'general-section')
//         clonedLink.classList.remove('col', 'general-section');

//         // Insert the link in the new <li>
//         newItem.appendChild(clonedLink);

//         // Insert the new <li> right after the Dashboard item
//         dashboardItem.parentNode.insertBefore(newItem, dashboardItem.nextSibling);

//         // Update reference so next item goes after the newly inserted one
//         dashboardItem = newItem;
//       });
//     })();
//   ''';

//   try {
//     await controller.runJavaScript(jsCode);
//     print('Debug: Sidebar navigation items injected successfully');
//   } catch (e) {
//     print('Error injecting sidebar navigation items: $e');
//   }
// }


// static Future<void> _injectCloseSidebarOnClick(WebViewController controller) async {
//   const String jsCode = '''
//     (function() {
//       // Get the sidebar drawer
//       var drawer = document.querySelector('.mdc-drawer');
//       if (!drawer) return;

//       // Select all nav-link anchors within the drawer
//       var navLinks = drawer.querySelectorAll('a.nav-link');
//       navLinks.forEach(function(link) {
//         link.addEventListener('click', function() {
//           // Remove the class that keeps the drawer open
//           drawer.classList.remove('mdc-drawer--open');
//         });
//       });
//     })();
//   ''';

//   try {
//     await controller.runJavaScript(jsCode);
//     print('Debug: Sidebar will now close on link click');
//   } catch (e) {
//     print('Error injecting close on link click logic: $e');
//   }
// }


// static NavigationDelegate _createNavigationDelegate({
//     required WebViewController controller,
//     required Function(bool) onLoadingStateChanged,
//     required Function(String) onError,
//   }) {
//     return NavigationDelegate(
//       onPageStarted: (_) => onLoadingStateChanged(true),
//       onPageFinished: (String url) async {
//       onLoadingStateChanged(false);
//       await _injectFileInputHandler(controller);
//       await _injectCustomStyles(controller);
//       await _injectSidebarNavItems(controller);  // Only once here
//       await Future.delayed(const Duration(milliseconds: 300));
//       await _injectCloseSidebarOnClick(controller);
//     },
      
//       onWebResourceError: (WebResourceError error) {
//         onError('Error: ${error.description}');
//         // print('WebView Error: ${error.description}');

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
//     if (_isPickerActive || _lastClickedInputId == null) {
//       // print('Debug: Image picker is already active or no input identified');
//       return;
//     }

//     try {
//       _isPickerActive = true;
//       _currentPicker = ImagePicker();
      
//       // print('Debug: Opening image picker for input: $_lastClickedInputId');
//       final XFile? image = await _currentPicker?.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );

//       if (image != null) {
//         // print('Debug: Image selected: ${image.name}');
//         final bytes = await image.readAsBytes();
//         final base64String = base64Encode(bytes);
        
//         await _injectFileData(controller, base64String, image.name, _lastClickedInputId!);
//         // print('Debug: File data injected successfully');
//       } else {
//         // print('Debug: No image selected');
//       }
//     } catch (e) {
//       // print('Error picking image: $e');
//     } finally {
//       _isPickerActive = false;
//       _currentPicker = null;
//       _lastClickedInputId = null;
//       // print('Debug: Image picker cleaned up');
//     }
//   }

//   static Future<void> _injectFileData(
//     WebViewController controller,
//     String base64String,
//     String fileName,
//     String inputId,
//   ) async {
//     // print('Debug: Starting file data injection for input: $inputId');
//     await controller.runJavaScript('''
//       (function() {
//         try {
//           // Find the specific input that was clicked
//           const fileInput = document.querySelector('[data-input-id="$inputId"]');
//           if (!fileInput) {
//             console.error('No file input found with id: $inputId');
//             return;
//           }
          
//           console.log('Found file input:', fileInput.name || fileInput.id);
          
//           // Create blob from base64
//           const binaryString = atob('$base64String');
//           const bytes = new Uint8Array(binaryString.length);
//           for (let i = 0; i < binaryString.length; i++) {
//             bytes[i] = binaryString.charCodeAt(i);
//           }
//           const blob = new Blob([bytes], { type: 'image/jpeg' });
          
//           // Create file
//           const file = new File([blob], '$fileName', { type: 'image/jpeg' });
          
//           // Clear existing files
//           const dataTransfer = new DataTransfer();
//           dataTransfer.items.add(file);
//           fileInput.files = dataTransfer.files;
          
//           // Update filename display
//           const filenameDisplay = fileInput.parentElement.querySelector('.filename-display');
//           if (filenameDisplay) {
//             filenameDisplay.textContent = '$fileName';
//           }
          
//           // Trigger events
//           const changeEvent = new Event('change', { bubbles: true });
//           const inputEvent = new Event('input', { bubbles: true });
//           fileInput.dispatchEvent(changeEvent);
//           fileInput.dispatchEvent(inputEvent);
          
//           console.log('File upload completed for input: $inputId');
//         } catch (error) {
//           console.error('Error in file upload:', error);
//         }
//       })();
//     ''');
//   }

//   static Future<void> _injectFileInputHandler(WebViewController controller) async {
//     const jsCode = '''
//       // Define our file input IDs
//       const fileInputs = [
//         { id: 'profile-image', label: 'Profile Image' },
//         { id: 'passport-front', label: 'Passport Front' },
//         { id: 'passport-back', label: 'Passport Back' },
//         { id: 'payment-slip', label: 'Payment Slip' }
//       ];
      
//       function setupFileInputs() {
//         const inputs = document.querySelectorAll('input[type="file"]');
//         inputs.forEach((input, index) => {
//           if (index < fileInputs.length) {
//             // Add our custom identifier
//             input.setAttribute('data-input-id', fileInputs[index].id);
            
//             // Create filename display if doesn't exist
//             let filenameDisplay = input.parentElement.querySelector('.filename-display');
//             if (!filenameDisplay) {
//               filenameDisplay = document.createElement('span');
//               filenameDisplay.className = 'filename-display';
//               filenameDisplay.style.marginLeft = '10px';
//               input.parentElement.appendChild(filenameDisplay);
//             }
            
//             // Add click handler
//             input.addEventListener('click', function(e) {
//               e.preventDefault();
//               // Pass the input identifier to the native code
//               NativeFileUpload.postMessage(fileInputs[index].id);
//             });
//           }
//         });
//       }
      
//       // Initial setup
//       setupFileInputs();
      
//       // Watch for dynamic changes
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
//       // print('Debug: File input handler injected successfully');
//     } catch (e) {
//       // print('Error injecting file input handler: $e');
//     }
//   }
// }









// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';

// class WebViewControllerService {
//   static ImagePicker? _currentPicker;
//   static bool _isPickerActive = false;
//   static String? _lastClickedInputId;  // Track which input was last clicked

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
//   WebViewController controller, {
//   required Function(bool) onLoadingStateChanged,
//   required Function(String) onError,
// }) async {
//   await controller
//     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..setBackgroundColor(const Color(0x00000000))
//     ..setNavigationDelegate(_createNavigationDelegate(
//       controller: controller,
//       onLoadingStateChanged: onLoadingStateChanged,
//       onError: onError,
//     ))
//     ..addJavaScriptChannel(
//       'NativeFileUpload',
//       onMessageReceived: (JavaScriptMessage message) {
//         _lastClickedInputId = message.message;
//         _handleFileUpload(controller);
//       },
//     )
//     // Just load the URL, do NOT inject items here
//     ..loadRequest(Uri.parse('https://extratech.extratechweb.com/enrollment-form'));

//   // Optionally inject CSS only
//   await _injectCustomStyles(controller);

//   _configureAndroidSpecifics(controller);
// }



//   // static Future<void> _configureController(
//   //   WebViewController controller, {
//   //   required Function(bool) onLoadingStateChanged,
//   //   required Function(String) onError,
//   // }) async {
//   //   await controller
//   //     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//   //     ..setBackgroundColor(const Color(0x00000000))
//   //     ..setNavigationDelegate(_createNavigationDelegate(
//   //       controller: controller,
//   //       onLoadingStateChanged: onLoadingStateChanged,
//   //       onError: onError,
//   //     ))
//   //     ..addJavaScriptChannel(
//   //       'NativeFileUpload',
//   //       onMessageReceived: (JavaScriptMessage message) {
//   //         // The message will contain the input identifier
//   //         _lastClickedInputId = message.message;
//   //         _handleFileUpload(controller);
//   //       },
//   //     )
//   //     ..loadRequest(Uri.parse('https://extratech.extratechweb.com/enrollment-form'));
     
//   //   await _injectCustomStyles(controller);
//   //   await _injectSidebarNavItems(controller);
    
//   //   _configureAndroidSpecifics(controller);
//   // }



// static Future<void> _injectCustomStyles(WebViewController controller) async {
//     const String customCSS = '''
//       /* Hide original navbar and logo */
//       .navbar-brand-wrapper {
//         display: none !important;
//       }
      
//       /* Hide original hamburger menu from navbar */
//       .navbar-menu-wrapper .navbar-toggler {
//         display: none !important;
//       }
      
//       /* Adjust profile section */
//       .profile-top.profile-top-flex-2 {
//         position: relative !important;
//         padding-right: 60px !important;
//       }
      
//       /* Hamburger menu styling */
//       .profile-top.profile-top-flex-2::after {
//         content: "" !important;
//         position: absolute !important;
//         right: 15px !important;
//         top: 50% !important;
//         transform: translateY(-50%) !important;
//         width: 30px !important;
//         height: 30px !important;
//         background-image: url('https://extratech.extratechweb.com/images/navigation-bar.png') !important;
//         background-size: contain !important;
//         background-repeat: no-repeat !important;
//         background-position: center !important;
//         cursor: pointer !important;
//       }
      
//       /* Profile section layout */
//       .profile-general {
//         display: flex !important;
//         align-items: center !important;
//         gap: 15px !important;
//       }
      
//       .profile-desc {
//         margin-left: 10px !important;
//       }

//       /* Hide original navigation tabs */
//       .nav.nav-tabs.student-nav-tabs {
//         display: none !important;
//       }

//       /* Sidebar styling */
//       .mdc-drawer {
//         transform: translateX(100%) !important;
//         transition: transform 0.3s ease-in-out !important;
//       }

//       .mdc-drawer.mdc-drawer--open {
//         transform: translateX(0) !important;
//       }

//       /* Ensure sidebar items maintain original styling */
//       .mdc-drawer .nav-link {
//         color: inherit !important;
//         text-decoration: none !important;
//         display: flex !important;
//         align-items: center !important;
//         padding: 12px 16px !important;
//       }

//       .mdc-drawer .nav-link i {
//         margin-right: 12px !important;
//       }

//       /* Mobile responsive adjustments */
//       @media (max-width: 768px) {
//         .profile-top.profile-top-flex-2 {
//           padding-right: 50px !important;
//         }
        
//         .profile-top.profile-top-flex-2::after {
//           right: 10px !important;
//         }
//       }
//     ''';

//     // Add click handler for the new hamburger menu
//     const String jsCode = '''
//       // Add custom styles
//       var style = document.createElement('style');
//       style.textContent = `${customCSS}`;
//       document.head.appendChild(style);
      
//       // Add click handler to new hamburger menu
//       document.querySelector('.profile-top.profile-top-flex-2').addEventListener('click', function(e) {
//         // Check if click was on the hamburger menu area
//         const rect = this.getBoundingClientRect();
//         const clickX = e.clientX - rect.left;
        
//         if (clickX > rect.width - 60) { // If click is in hamburger menu area
//           // Trigger original navbar toggle
//           document.querySelector('.navbar-toggler').click();
//         }
//       });
//     ''';

//     try {
//       await controller.runJavaScript(jsCode);
//       // print('Debug: Custom styles and click handler injected successfully');
//     } catch (e) {
//       // print('Error injecting custom styles: $e');
//     }

// }


// static Future<void> _injectSidebarNavItems(WebViewController controller) async {
//   const String jsCode = '''
//     (function() {
//       // Locate the sidebar navigation container and the Dashboard item
//       var sidebarNav = document.querySelector('#sidebar ul.nav');
//       if (!sidebarNav) {
//         console.error("Sidebar navigation container not found.");
//         return;
//       }

//       var dashboardItem = sidebarNav.querySelector('li.nav-item.active');
//       if (!dashboardItem) {
//         console.error("Dashboard item not found.");
//         return;
//       }

//       // Select the hidden nav items from the profile section
//       var profileNavItems = document.querySelectorAll('.nav.nav-tabs.student-nav-tabs a.nav-link');
//       if (!profileNavItems.length) {
//         console.error("Profile nav items not found.");
//         return;
//       }

//       profileNavItems.forEach(function(item) {
//         // Create a new <li> to match the sidebar structure
//         var newItem = document.createElement('li');
//         newItem.className = 'nav-item';

//         // Clone the <a> tag
//         var clonedLink = item.cloneNode(true);

//         // Make sure it has the nav-link class so existing CSS and JS can target it
//         clonedLink.classList.add('nav-link');

//         // Attach a click listener that closes the sidebar
//         clonedLink.addEventListener('click', function() {
//           var drawer = document.querySelector('.mdc-drawer');
//           if (drawer) {
//             drawer.classList.remove('mdc-drawer--open');
//           }
//         });

//         // Optional: remove classes that cause misalignment (e.g., 'col', 'general-section')
//         clonedLink.classList.remove('col', 'general-section');

//         // Insert the link in the new <li>
//         newItem.appendChild(clonedLink);

//         // Insert the new <li> right after the Dashboard item
//         dashboardItem.parentNode.insertBefore(newItem, dashboardItem.nextSibling);

//         // Update reference so next item goes after the newly inserted one
//         dashboardItem = newItem;
//       });
//     })();
//   ''';

//   try {
//     await controller.runJavaScript(jsCode);
//     print('Debug: Sidebar navigation items injected successfully');
//   } catch (e) {
//     print('Error injecting sidebar navigation items: $e');
//   }
// }


// static Future<void> _injectCloseSidebarOnClick(WebViewController controller) async {
//   const String jsCode = '''
//     (function() {
//       // Get the sidebar drawer
//       var drawer = document.querySelector('.mdc-drawer');
//       if (!drawer) return;

//       // Select all nav-link anchors within the drawer
//       var navLinks = drawer.querySelectorAll('a.nav-link');
//       navLinks.forEach(function(link) {
//         link.addEventListener('click', function() {
//           // Remove the class that keeps the drawer open
//           drawer.classList.remove('mdc-drawer--open');
//         });
//       });
//     })();
//   ''';

//   try {
//     await controller.runJavaScript(jsCode);
//     print('Debug: Sidebar will now close on link click');
//   } catch (e) {
//     print('Error injecting close on link click logic: $e');
//   }
// }


// static NavigationDelegate _createNavigationDelegate({
//     required WebViewController controller,
//     required Function(bool) onLoadingStateChanged,
//     required Function(String) onError,
//   }) {
//     return NavigationDelegate(
//       onPageStarted: (_) => onLoadingStateChanged(true),
//       onPageFinished: (String url) async {
//       onLoadingStateChanged(false);
//       await _injectFileInputHandler(controller);
//       await _injectCustomStyles(controller);
//       await _injectSidebarNavItems(controller);  // Only once here
//       await Future.delayed(const Duration(milliseconds: 300));
//       await _injectCloseSidebarOnClick(controller);
//     },
      
//       onWebResourceError: (WebResourceError error) {
//         onError('Error: ${error.description}');
//         // print('WebView Error: ${error.description}');

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
//     if (_isPickerActive || _lastClickedInputId == null) {
//       // print('Debug: Image picker is already active or no input identified');
//       return;
//     }

//     try {
//       _isPickerActive = true;
//       _currentPicker = ImagePicker();
      
//       // print('Debug: Opening image picker for input: $_lastClickedInputId');
//       final XFile? image = await _currentPicker?.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );

//       if (image != null) {
//         // print('Debug: Image selected: ${image.name}');
//         final bytes = await image.readAsBytes();
//         final base64String = base64Encode(bytes);
        
//         await _injectFileData(controller, base64String, image.name, _lastClickedInputId!);
//         // print('Debug: File data injected successfully');
//       } else {
//         // print('Debug: No image selected');
//       }
//     } catch (e) {
//       // print('Error picking image: $e');
//     } finally {
//       _isPickerActive = false;
//       _currentPicker = null;
//       _lastClickedInputId = null;
//       // print('Debug: Image picker cleaned up');
//     }
//   }

//   static Future<void> _injectFileData(
//     WebViewController controller,
//     String base64String,
//     String fileName,
//     String inputId,
//   ) async {
//     // print('Debug: Starting file data injection for input: $inputId');
//     await controller.runJavaScript('''
//       (function() {
//         try {
//           // Find the specific input that was clicked
//           const fileInput = document.querySelector('[data-input-id="$inputId"]');
//           if (!fileInput) {
//             console.error('No file input found with id: $inputId');
//             return;
//           }
          
//           console.log('Found file input:', fileInput.name || fileInput.id);
          
//           // Create blob from base64
//           const binaryString = atob('$base64String');
//           const bytes = new Uint8Array(binaryString.length);
//           for (let i = 0; i < binaryString.length; i++) {
//             bytes[i] = binaryString.charCodeAt(i);
//           }
//           const blob = new Blob([bytes], { type: 'image/jpeg' });
          
//           // Create file
//           const file = new File([blob], '$fileName', { type: 'image/jpeg' });
          
//           // Clear existing files
//           const dataTransfer = new DataTransfer();
//           dataTransfer.items.add(file);
//           fileInput.files = dataTransfer.files;
          
//           // Update filename display
//           const filenameDisplay = fileInput.parentElement.querySelector('.filename-display');
//           if (filenameDisplay) {
//             filenameDisplay.textContent = '$fileName';
//           }
          
//           // Trigger events
//           const changeEvent = new Event('change', { bubbles: true });
//           const inputEvent = new Event('input', { bubbles: true });
//           fileInput.dispatchEvent(changeEvent);
//           fileInput.dispatchEvent(inputEvent);
          
//           console.log('File upload completed for input: $inputId');
//         } catch (error) {
//           console.error('Error in file upload:', error);
//         }
//       })();
//     ''');
//   }

//   static Future<void> _injectFileInputHandler(WebViewController controller) async {
//     const jsCode = '''
//       // Define our file input IDs
//       const fileInputs = [
//         { id: 'profile-image', label: 'Profile Image' },
//         { id: 'passport-front', label: 'Passport Front' },
//         { id: 'passport-back', label: 'Passport Back' },
//         { id: 'payment-slip', label: 'Payment Slip' }
//       ];
      
//       function setupFileInputs() {
//         const inputs = document.querySelectorAll('input[type="file"]');
//         inputs.forEach((input, index) => {
//           if (index < fileInputs.length) {
//             // Add our custom identifier
//             input.setAttribute('data-input-id', fileInputs[index].id);
            
//             // Create filename display if doesn't exist
//             let filenameDisplay = input.parentElement.querySelector('.filename-display');
//             if (!filenameDisplay) {
//               filenameDisplay = document.createElement('span');
//               filenameDisplay.className = 'filename-display';
//               filenameDisplay.style.marginLeft = '10px';
//               input.parentElement.appendChild(filenameDisplay);
//             }
            
//             // Add click handler
//             input.addEventListener('click', function(e) {
//               e.preventDefault();
//               // Pass the input identifier to the native code
//               NativeFileUpload.postMessage(fileInputs[index].id);
//             });
//           }
//         });
//       }
      
//       // Initial setup
//       setupFileInputs();
      
//       // Watch for dynamic changes
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
//       // print('Debug: File input handler injected successfully');
//     } catch (e) {
//       // print('Error injecting file input handler: $e');
//     }
//   }
// }



















// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart';
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:convert';

// class WebViewControllerService {
//   static ImagePicker? _currentPicker;
//   static bool _isPickerActive = false;
//   static String? _lastClickedInputId;  // Track which input was last clicked

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
//         onMessageReceived: (JavaScriptMessage message) {
//           // The message will contain the input identifier
//           _lastClickedInputId = message.message;
//           _handleFileUpload(controller);
//         },
//       )
//       ..loadRequest(Uri.parse('https://extratech.extratechweb.com/enrollment-form'));
//     await _injectCustomStyles(controller);
//     _configureAndroidSpecifics(controller);
//   }



//   static Future<void> _injectCustomStyles(WebViewController controller) async {
//     const String customCSS = '''
//       /* Hide original navbar and logo */
//       .navbar-brand-wrapper {
//         display: none !important;
//       }
      
//       /* Hide original hamburger menu from navbar */
//       .navbar-menu-wrapper .navbar-toggler {
//         display: none !important;
//       }
      
//       /* Adjust profile section to accommodate hamburger menu */
//       .profile-top.profile-top-flex-2 {
//         position: relative !important;
//         padding-right: 60px !important; /* Space for hamburger menu */
//       }
      
//       /* Create new hamburger menu in profile section */
//       .profile-top.profile-top-flex-2::after {
//         content: "" !important;
//         position: absolute !important;
//         right: 15px !important;
//         top: 50% !important;
//         transform: translateY(-50%) !important;
//         width: 30px !important;
//         height: 30px !important;
//         background-image: url('https://extratech.extratechweb.com/images/navigation-bar.png') !important;
//         background-size: contain !important;
//         background-repeat: no-repeat !important;
//         background-position: center !important;
//         cursor: pointer !important;
//       }
      
//       /* Ensure profile section layout */
//       .profile-general {
//         display: flex !important;
//         align-items: center !important;
//         gap: 15px !important;
//       }
      
//       .profile-desc {
//         margin-left: 10px !important;
//       }
      
//       /* Mobile responsive adjustments */
//       @media (max-width: 768px) {
//         .profile-top.profile-top-flex-2 {
//           padding-right: 50px !important;
//         }
        
//         .profile-top.profile-top-flex-2::after {
//           right: 10px !important;
//         }
//       }
      
//       /* Ensure other elements maintain their position */
//       .course-col, .student-dash-col {
//         position: relative !important;
//         z-index: 1 !important;
        
//       }
//     ''';

//     // Add click handler for the new hamburger menu
//     const String jsCode = '''
//       // Add custom styles
//       var style = document.createElement('style');
//       style.textContent = `${customCSS}`;
//       document.head.appendChild(style);
      
//       // Add click handler to new hamburger menu
//       document.querySelector('.profile-top.profile-top-flex-2').addEventListener('click', function(e) {
//         // Check if click was on the hamburger menu area
//         const rect = this.getBoundingClientRect();
//         const clickX = e.clientX - rect.left;
        
//         if (clickX > rect.width - 60) { // If click is in hamburger menu area
//           // Trigger original navbar toggle
//           document.querySelector('.navbar-toggler').click();
//         }
//       });
//     ''';

//     try {
//       await controller.runJavaScript(jsCode);
//       print('Debug: Custom styles and click handler injected successfully');
//     } catch (e) {
//       print('Error injecting custom styles: $e');
//     }
// }


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
//          await _injectCustomStyles(controller);
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
//     if (_isPickerActive || _lastClickedInputId == null) {
//       print('Debug: Image picker is already active or no input identified');
//       return;
//     }

//     try {
//       _isPickerActive = true;
//       _currentPicker = ImagePicker();
      
//       print('Debug: Opening image picker for input: $_lastClickedInputId');
//       final XFile? image = await _currentPicker?.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );

//       if (image != null) {
//         print('Debug: Image selected: ${image.name}');
//         final bytes = await image.readAsBytes();
//         final base64String = base64Encode(bytes);
        
//         await _injectFileData(controller, base64String, image.name, _lastClickedInputId!);
//         print('Debug: File data injected successfully');
//       } else {
//         print('Debug: No image selected');
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//     } finally {
//       _isPickerActive = false;
//       _currentPicker = null;
//       _lastClickedInputId = null;
//       print('Debug: Image picker cleaned up');
//     }
//   }

//   static Future<void> _injectFileData(
//     WebViewController controller,
//     String base64String,
//     String fileName,
//     String inputId,
//   ) async {
//     print('Debug: Starting file data injection for input: $inputId');
//     await controller.runJavaScript('''
//       (function() {
//         try {
//           // Find the specific input that was clicked
//           const fileInput = document.querySelector('[data-input-id="$inputId"]');
//           if (!fileInput) {
//             console.error('No file input found with id: $inputId');
//             return;
//           }
          
//           console.log('Found file input:', fileInput.name || fileInput.id);
          
//           // Create blob from base64
//           const binaryString = atob('$base64String');
//           const bytes = new Uint8Array(binaryString.length);
//           for (let i = 0; i < binaryString.length; i++) {
//             bytes[i] = binaryString.charCodeAt(i);
//           }
//           const blob = new Blob([bytes], { type: 'image/jpeg' });
          
//           // Create file
//           const file = new File([blob], '$fileName', { type: 'image/jpeg' });
          
//           // Clear existing files
//           const dataTransfer = new DataTransfer();
//           dataTransfer.items.add(file);
//           fileInput.files = dataTransfer.files;
          
//           // Update filename display
//           const filenameDisplay = fileInput.parentElement.querySelector('.filename-display');
//           if (filenameDisplay) {
//             filenameDisplay.textContent = '$fileName';
//           }
          
//           // Trigger events
//           const changeEvent = new Event('change', { bubbles: true });
//           const inputEvent = new Event('input', { bubbles: true });
//           fileInput.dispatchEvent(changeEvent);
//           fileInput.dispatchEvent(inputEvent);
          
//           console.log('File upload completed for input: $inputId');
//         } catch (error) {
//           console.error('Error in file upload:', error);
//         }
//       })();
//     ''');
//   }

//   static Future<void> _injectFileInputHandler(WebViewController controller) async {
//     const jsCode = '''
//       // Define our file input IDs
//       const fileInputs = [
//         { id: 'profile-image', label: 'Profile Image' },
//         { id: 'passport-front', label: 'Passport Front' },
//         { id: 'passport-back', label: 'Passport Back' },
//         { id: 'payment-slip', label: 'Payment Slip' }
//       ];
      
//       function setupFileInputs() {
//         const inputs = document.querySelectorAll('input[type="file"]');
//         inputs.forEach((input, index) => {
//           if (index < fileInputs.length) {
//             // Add our custom identifier
//             input.setAttribute('data-input-id', fileInputs[index].id);
            
//             // Create filename display if doesn't exist
//             let filenameDisplay = input.parentElement.querySelector('.filename-display');
//             if (!filenameDisplay) {
//               filenameDisplay = document.createElement('span');
//               filenameDisplay.className = 'filename-display';
//               filenameDisplay.style.marginLeft = '10px';
//               input.parentElement.appendChild(filenameDisplay);
//             }
            
//             // Add click handler
//             input.addEventListener('click', function(e) {
//               e.preventDefault();
//               // Pass the input identifier to the native code
//               NativeFileUpload.postMessage(fileInputs[index].id);
//             });
//           }
//         });
//       }
      
//       // Initial setup
//       setupFileInputs();
      
//       // Watch for dynamic changes
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
//       print('Debug: File input handler injected successfully');
//     } catch (e) {
//       print('Error injecting file input handler: $e');
//     }
//   }
// }







































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