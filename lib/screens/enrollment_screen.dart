import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    late final PlatformWebViewControllerCreationParams params;

    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _errorMessage = '';
            });
          },
          onPageFinished: (String url) async {
            setState(() {
              _isLoading = false;
            });
            
            // Inject JavaScript after page loads
            await controller.runJavaScript('''
              function setupFileInputs() {
                const fileInputs = document.querySelectorAll('input[type="file"]');
                fileInputs.forEach(input => {
                  input.addEventListener('click', function(e) {
                    e.preventDefault();
                    // Call our custom channel
                    NativeFileUpload.postMessage('selectFile');
                  });
                });
              }
              
              // Run setup immediately and after any dynamic changes
              setupFileInputs();
              // Watch for dynamic changes
              const observer = new MutationObserver(function(mutations) {
                setupFileInputs();
              });
              observer.observe(document.body, { 
                childList: true, 
                subtree: true 
              });
            ''');
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _errorMessage = 'Error: ${error.description}';
              _isLoading = false;
            });
            print('WebView Error: ${error.description}');
          },
        ),
      )
      ..addJavaScriptChannel(
        'NativeFileUpload',
        onMessageReceived: (JavaScriptMessage message) async {
          print('File upload requested');  // Debug log
          final ImagePicker picker = ImagePicker();
          try {
            final XFile? image = await picker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 1024,
              maxHeight: 1024,
            );
            
            if (image != null) {
              print('Image selected: ${image.name}');  // Debug log
              final bytes = await image.readAsBytes();
              final base64String = base64Encode(bytes);
              final fileName = image.name;
              
              // Inject the selected file
              await controller.runJavaScript('''
                (function() {
                  try {
                    const fileInput = document.querySelector('input[type="file"]');
                    if (!fileInput) {
                      console.error('No file input found');
                      return;
                    }
                    
                    // Create blob from base64
                    const binaryString = atob('$base64String');
                    const bytes = new Uint8Array(binaryString.length);
                    for (let i = 0; i < binaryString.length; i++) {
                      bytes[i] = binaryString.charCodeAt(i);
                    }
                    const blob = new Blob([bytes], { type: 'image/jpeg' });
                    
                    // Create file
                    const file = new File([blob], '$fileName', { type: 'image/jpeg' });
                    
                    // Set file to input
                    const dataTransfer = new DataTransfer();
                    dataTransfer.items.add(file);
                    fileInput.files = dataTransfer.files;
                    
                    // Trigger change event
                    const event = new Event('change', { bubbles: true });
                    fileInput.dispatchEvent(event);
                    
                    console.log('File uploaded successfully');
                  } catch (error) {
                    console.error('Error in file upload:', error);
                  }
                })();
              ''');
            }
          } catch (e) {
            print('Error picking image: $e');
          }
        },
      )
      ..loadRequest(Uri.parse('https://extratech.extratechweb.com/enrollment-form'));

    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
        ..setMediaPlaybackRequiresUserGesture(false);
    }

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_errorMessage.isNotEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                  ElevatedButton(
                    onPressed: () => _controller.reload(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}







