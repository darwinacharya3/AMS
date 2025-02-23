import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../widgets/web_view_container.dart';
import '../../controller/webview_controller.dart';
import '../home/dashboard_screen.dart';  // Import your home screen

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;  // Add this to prevent multiple navigations

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      final controller = await WebViewControllerService.initialize(
        onLoadingStateChanged: _handleLoadingState,
        onError: _handleError,
        onSignupSuccess: _handleSignupSuccess,
      );
      
      if (mounted) {
        setState(() {
          _controller = controller;
        });
      }
    } catch (e) {
      if (mounted) {
        _handleError(e.toString());
      }
    }
  }

  void _handleLoadingState(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
        if (isLoading) _errorMessage = '';
      });
    }
  }

  void _handleError(String error) {
    if (mounted) {
      setState(() {
        _errorMessage = error;
        _isLoading = false;
      });
    }
  }

  void _handleSignupSuccess() {
    if (_isNavigating) return;  // Prevent multiple navigations
    _isNavigating = true;

    // Navigate to home screen and remove all previous routes
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller == null
          ? const Center(child: CircularProgressIndicator())
          : WebViewContainer(
              controller: _controller!,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              onRetry: () => _controller?.reload(),
            ),
    );
  }
}








