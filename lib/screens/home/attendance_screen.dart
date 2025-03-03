import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ems/controller/attendance_controller.dart';
import 'package:ems/screens/home/dashboard_screen.dart';
import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/custom_widgets/custom_navigation.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({Key? key}) : super(key: key);

  // Handle back button behavior
  Future<bool> _onWillPop(BuildContext context, AttendanceController controller) async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const DashboardScreen()),
      );
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(attendanceControllerProvider.notifier);
    final webViewController = ref.watch(attendanceControllerProvider);

    return WillPopScope(
      onWillPop: () => _onWillPop(context, controller),
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Attendance',
          icon: Icons.calendar_today,
          showBackButton: true,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'Attendance',
          onItemSelected: (String item) {
            CustomNavigation.navigateToScreen(item, context,);
          },
        ),
        body: Stack(
  children: [
    // White background that will show while content loads
    Container(
      color: Colors.white,
    ),
    
    // WebView on top of the white background
    WebViewWidget(controller: webViewController),
    
    // Loading indicator that displays until page is fully loaded
    // Consumer(
    //   builder: (context, ref, child) {
    //     final isLoading = ref.watch(attendanceControllerProvider.select(
    //       (controller) => controller.isLoading,
    //     ));
        
    //     return isLoading 
    //       ? const Center(child: CircularProgressIndicator())
    //       : const SizedBox.shrink();
    //   },
    // ),
  ],
),
    ),);
  }
}















// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:webview_flutter_android/webview_flutter_android.dart'; // Add this import
// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart'; // Add this import
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_navigation.dart';
// import 'package:ems/services/secure_storage_service.dart';

// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({Key? key}) : super(key: key);

//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
//   late WebViewController _controller;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeWebView();
//   }

//   Future<void> _initializeWebView() async {
//     // Create platform-specific params
//     late final PlatformWebViewControllerCreationParams params;
//     if (WebViewPlatform.instance is WebKitWebViewPlatform) {
//       params = WebKitWebViewControllerCreationParams(
//         allowsInlineMediaPlayback: true,
//         mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
//       );
//     } else {
//       params = const PlatformWebViewControllerCreationParams();
//     }

//     // Create the controller with params
//     _controller = WebViewController.fromPlatformCreationParams(params);

//     // Configure the controller
//     _controller
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setBackgroundColor(const Color(0x00000000))
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() {
//               _isLoading = true;
//             });
//           },
//           onPageFinished: (String url) async {
//             // Navigate to the attendance section and hide unnecessary elements
//             await Future.delayed(const Duration(milliseconds: 1000));
//             await _navigateToAttendanceSection();
//             // await _hideWebsiteElements();
            
//             setState(() {
//               _isLoading = false;
//             });
//           },
//           onWebResourceError: (WebResourceError error) {
//             debugPrint('WebView Error: ${error.description}');
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             // Allow navigation within your domain
//             if (!request.url.startsWith('https://extratech.extratechweb.com')) {
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       );

//     // Configure platform-specific settings
//     if (_controller.platform is AndroidWebViewController) {
//       AndroidWebViewController.enableDebugging(true);
//       (_controller.platform as AndroidWebViewController)
//           .setMediaPlaybackRequiresUserGesture(false);
//     }

//     // Get stored cookies from SecureStorageService
//     final cookies = await _getStoredCookies();
    
//     // Load the student dashboard URL with cookies
//     await _controller.loadRequest(
//       Uri.parse('https://extratech.extratechweb.com/student'),
//       headers: {'Cookie': cookies},
//     );
//   }

//   Future<String> _getStoredCookies() async {
//     try {
//       // Get stored cookies
//       final sessionId = await SecureStorageService.getSessionId() ?? '';
//       final authToken = await SecureStorageService.getAuthToken() ?? '';
      
//       // Format cookies as a string
//       final cookies = <String>[];
//       if (sessionId.isNotEmpty) cookies.add('PHPSESSID=$sessionId');
//       if (authToken.isNotEmpty) cookies.add('auth_token=$authToken');
      
//       return cookies.join('; ');
//     } catch (e) {
//       debugPrint('Error retrieving cookies: $e');
//       return '';
//     }
//   }

//   Future<void> _navigateToAttendanceSection() async {
//   const script = '''
//     (function() {
//       try {
//         // Note the spelling: "attendence" instead of "attendance" 
//         // to match the website's HTML
//         const selectors = [
//           'a[href*="attendance"]',
//           'a[href*="attendence"]',
//           'button:contains("Attendance")',
//           '.attendence-section',
//           '.attendance-tab',
//           '#attendance-tab',
//           'a:contains("Attendance")'
//         ];
        
//         for (const selector of selectors) {
//           const elements = document.querySelectorAll(selector);
//           if (elements && elements.length > 0) {
//             console.log('Found attendance element:', elements[0]);
//             elements[0].click();
//             return true;
//           }
//         }
        
//         // If targeting the section directly
//         const attendenceSection = document.querySelector('section.attendence-section');
//         if (attendenceSection) {
//           console.log('Found attendance section:', attendenceSection);
//           // You might need to make this section visible or scroll to it
//           attendenceSection.scrollIntoView();
//           return true;
//         }
        
//         // If no element found, try direct navigation
//         console.log('No attendance elements found, trying direct navigation');
//         window.location.href = 'https://extratech.extratechweb.com/student/attendance';
//         return true;
//       } catch (e) {
//         console.error('Error navigating to attendance:', e);
//         return false;
//       }
//     })();
//   ''';
  
//   try {
//     await _controller.runJavaScript(script);
//   } catch (e) {
//     debugPrint('Error running navigation script: $e');
//   }
// }

 
//   Future<bool> _onWillPop() async {
//     if (Get.previousRoute.isNotEmpty) {
//       Get.to(() => DashboardScreen());
//       return false;
//     }
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Attendance',
//           icon: Icons.calendar_today,
//           showBackButton: true,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Attendance',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Stack(
//           children: [
//             WebViewWidget(controller: _controller),
            
//             if (_isLoading)
//               const Center(
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }








// import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_navigation.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({Key? key}) : super(key: key);

//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
//   late WebViewController _controller;
//   bool _isLoading = true;
//   Map<String, String> _cookies = {};

//   @override
//   void initState() {
//     super.initState();
//     _loadSessionCookies();
//   }

//   Future<void> _loadSessionCookies() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Retrieve session cookies from SharedPreferences
//     // Assuming you've stored them during the sign-in process
//     final sessionId = prefs.getString('sessionId') ?? '';
//     final authToken = prefs.getString('authToken') ?? '';
//     // Add any other cookies needed for authentication
    
//     setState(() {
//       _cookies = {
//         'sessionId': sessionId,
//         'authToken': authToken,
//         // Add other cookies as needed
//       };
//     });
    
//     _initializeWebView();
//   }

//   void _initializeWebView() {
//     _controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() {
//               _isLoading = true;
//             });
//           },
//           onPageFinished: (String url) async {
//             // Navigate to the attendance section on the web page
//             await _navigateToAttendanceSection();
            
//             // Hide website elements not needed in the app
//             await _hideWebsiteElements();
            
//             setState(() {
//               _isLoading = false;
//             });
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             // Intercept navigation to keep user within your domain
//             if (!request.url.startsWith('https://extratech.extratechweb.com')) {
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(
//         Uri.parse('https://extratech.extratechweb.com/student'),
//         headers: {'Cookie': _cookiesToString(_cookies)},
//       );
//   }
  
//   String _cookiesToString(Map<String, String> cookies) {
//     return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
//   }

//   Future<void> _navigateToAttendanceSection() async {
//     // Customize this JavaScript to match your website's structure
//     const script = '''
//       // Check if there are tab/section selectors and click the attendance one
//       // Example selectors - modify these based on your actual website's HTML structure
//       const attendanceTab = document.querySelector('.attendance-tab') || 
//                             document.querySelector('a[href*="attendance"]') ||
//                             document.querySelector('button:contains("Attendance")');
      
//       if (attendanceTab) {
//         attendanceTab.click();
//       } else {
//         // If no tab found, try navigating directly
//         window.location.href = 'https://extratech.extratechweb.com/student/attendance';
//       }
//     ''';
    
//     await _controller.runJavaScript(script);
//   }
  
//   Future<void> _hideWebsiteElements() async {
//     // Hide elements you don't want to show in your app
//     const script = '''
//       // Hide header
//       if(document.querySelector('header')) {
//         document.querySelector('header').style.display = 'none';
//       }
      
//       // Hide footer
//       if(document.querySelector('footer')) {
//         document.querySelector('footer').style.display = 'none';
//       }
      
//       // Hide navigation/menu
//       if(document.querySelector('nav')) {
//         document.querySelector('nav').style.display = 'none';
//       }
      
//       // Hide any other elements that should not be visible in the app
//       // Add more selectors as needed based on your website's structure
//       const elementsToHide = [
//         '.main-menu', 
//         '.site-header',
//         '.sidebar',
//         '#navbar',
//         '.main-navigation'
//       ];
      
//       elementsToHide.forEach(selector => {
//         const elements = document.querySelectorAll(selector);
//         elements.forEach(el => {
//           if(el) el.style.display = 'none';
//         });
//       });
//     ''';
    
//     await _controller.runJavaScript(script);
//   }

//   Future<bool> _onWillPop() async {
//     if (Get.previousRoute.isNotEmpty) {
//       Get.to(() => DashboardScreen());
//       return false;
//     }
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Attendance',
//           icon: Icons.calendar_today,
//           showBackButton: true,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Attendance',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Stack(
//           children: [
//             // Only show WebView once it's initialized
//             if (_cookies.isNotEmpty)
//               WebViewWidget(controller: _controller),
              
//             // Loading indicator
//             if (_isLoading)
//               const Center(
//                 child: CircularProgressIndicator(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


















// import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_navigation.dart';

// class AttendanceScreen extends StatelessWidget {
//   const AttendanceScreen({Key? key}) : super(key: key);

//    Future<bool> _onWillPop() async {
//     if (Get.previousRoute.isNotEmpty) {
//       // Get.back();
//       Get.to(()=>DashboardScreen());
//       return false;
//     }
//     // If no previous route, let the system handle the back button
//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Attendance',
//           icon: Icons.calendar_today,
//           showBackButton: true,  // Explicitly show back button
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Attendance',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Text(
//               //   'Attendance Overview',
//               //   style: GoogleFonts.poppins(
//               //     fontSize: 24,
//               //     fontWeight: FontWeight.bold,
//               //   ),
//               // ),
//               const SizedBox(height: 16),
//               // Add attendance-specific content here
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }












// // lib/screens/home/attendance_screen.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_navigation.dart';

// class AttendanceScreen extends StatelessWidget {
//   const AttendanceScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'Attendance',
//         icon: Icons.calendar_today,
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: 'Attendance',
//         onItemSelected: (String item) {
//           CustomNavigation.navigateToScreen(item, context);
//         },
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Attendance Overview',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Add attendance-specific content here
//           ],
//         ),
//       ),
//     );
//   }
// }

















// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';

// class AttendanceScreen extends StatelessWidget {
//   const AttendanceScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const CustomAppBar(
//         title: 'Attendance',
//         icon: Icons.calendar_today, // Changed icon to match attendance context
//       ),
//       endDrawer: DashboardDrawer(
//         selectedItem: 'Attendance',
//         onItemSelected: (String item) {
//           // Your existing navigation logic here
//         },
//       ),
//       body: Container(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'Attendance Overview',
//               style: GoogleFonts.poppins(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Add your attendance-specific content here
//           ],
//         ),
//       ),
//     );
//   }
// }