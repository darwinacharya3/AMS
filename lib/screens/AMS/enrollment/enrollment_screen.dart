import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../widgets/AMS/enrollment_widget/web_view_container.dart';
import '../../../controller/webview_controller.dart';
import '../home/dashboard_screen.dart';
import 'package:ems/screens/welcome/welcome_screen.dart';

class EnrollmentScreen extends StatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  State<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends State<EnrollmentScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isNavigating = false;

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
    if (_isNavigating) return;
    _isNavigating = true;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => DashboardScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _navigateBackToSelectionScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => SelectionScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: null, // Remove the title completely
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFFE9008D)),
          onPressed: _navigateBackToSelectionScreen,
        ),
      ),
      body: _controller == null
          ? const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9008D)),
            ))
          : WebViewContainer(
              controller: _controller!,
              isLoading: _isLoading,
              errorMessage: _errorMessage,
              onRetry: () => _controller?.reload(),
            ),
    );
  }
}












// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import '../../../widgets/AMS/enrollment_widget/web_view_container.dart';
// import '../../../controller/webview_controller.dart';
// import '../home/dashboard_screen.dart';
// import 'package:ems/screens/welcome/welcome_screen.dart';  // Import the selection screen

// class EnrollmentScreen extends StatefulWidget {
//   const EnrollmentScreen({super.key});

//   @override
//   State<EnrollmentScreen> createState() => _EnrollmentScreenState();
// }

// class _EnrollmentScreenState extends State<EnrollmentScreen> {
//   WebViewController? _controller;
//   bool _isLoading = true;
//   String _errorMessage = '';
//   bool _isNavigating = false;

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebView();
//   }

//   Future<void> _initializeWebView() async {
//     try {
//       final controller = await WebViewControllerService.initialize(
//         onLoadingStateChanged: _handleLoadingState,
//         onError: _handleError,
//         onSignupSuccess: _handleSignupSuccess,
//       );
      
//       if (mounted) {
//         setState(() {
//           _controller = controller;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         _handleError(e.toString());
//       }
//     }
//   }

//   void _handleLoadingState(bool isLoading) {
//     if (mounted) {
//       setState(() {
//         _isLoading = isLoading;
//         if (isLoading) _errorMessage = '';
//       });
//     }
//   }

//   void _handleError(String error) {
//     if (mounted) {
//       setState(() {
//         _errorMessage = error;
//         _isLoading = false;
//       });
//     }
//   }

//   void _handleSignupSuccess() {
//     if (_isNavigating) return;
//     _isNavigating = true;

//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => DashboardScreen()),
//       (Route<dynamic> route) => false,
//     );
//   }

//   void _navigateBackToSelectionScreen() {
//     Navigator.of(context).pushAndRemoveUntil(
//       MaterialPageRoute(builder: (context) => SelectionScreen()),
//       (Route<dynamic> route) => false,
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: 
//         Text(
//           'Student Enrollment',
//           style: TextStyle(
//             color: Color(0xFFE9008D),
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Color(0xFFE9008D)),
//           onPressed: _navigateBackToSelectionScreen,
//         ),
//       ),
//       body: _controller == null
//           ? const Center(child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9008D)),
//             ))
//           : WebViewContainer(
//               controller: _controller!,
//               isLoading: _isLoading,
//               errorMessage: _errorMessage,
//               onRetry: () => _controller?.reload(),
//             ),
//     );
//   }
// }