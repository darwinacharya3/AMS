import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ems/services/secure_storage_service.dart';
import 'package:ems/screens/AMS/home/dashboard_screen.dart';
import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late WebViewController controller;
  bool isLoading = true;

  Future<bool> _onWillPop() async {
    if (Get.previousRoute.isNotEmpty) {
      Get.to(() => DashboardScreen());
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      // Get authentication data for API endpoint
      final uuid = await SecureStorageService.getUuid();
      final userId = await SecureStorageService.getUserId();
      final token = await SecureStorageService.getToken();
      
      // Use UUID if available, otherwise fall back to userId
      final identifier = uuid ?? userId;
      
      // Create WebViewController
      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (String url) {
              // Hide navbar and other elements once the page is loaded
              _cleanupWebView();
              setState(() {
                isLoading = false;
              });
            },
          ),
        );

      // Choose the API endpoint URL with proper identifier
      final url = 'https://extratech.extratechweb.com/student/attendance/api/$identifier';
      
      // Load the URL with auth headers if token is available
      if (token != null) {
        await controller.loadRequest(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        );
      } else {
        await controller.loadRequest(Uri.parse(url));
      }
    } catch (e) {
      debugPrint('Error initializing WebView: $e');
    }
  }

  Future<void> _cleanupWebView() async {
    await controller.runJavaScript('''
      (function() {
        try {
          // Add comprehensive styling to hide unwanted elements and format JSON
          const style = document.createElement('style');
          style.textContent = `
            /* Hide all navigation elements */
            nav, .navbar, .top-navbar, .sidebar, header, footer { 
              display: none !important; 
            }
            
            /* Hide profile and other unnecessary elements */
            .profile-top, .profile-top-flex-2 { 
              display: none !important; 
            }
            
            /* Adjust main content container */
            .main-panel, .content-wrapper { 
              width: 100% !important; 
              margin-left: 0 !important;
              padding-top: 10px !important; 
            }
            
            /* Make container take full width */
            .container-fluid { 
              padding-top: 10px !important;
              padding: 10px !important;
              width: 100% !important;
            }
            
            /* Style JSON if present */
            pre {
              background-color: white;
              padding: 16px;
              border: 1px solid #ddd;
              border-radius: 4px;
              overflow: auto;
              white-space: pre-wrap;
              font-family: monospace;
              font-size: 14px;
              line-height: 1.5;
            }
            
            /* Additional styling for the page */
            body {
              padding-top: 0 !important;
              margin-top: 0 !important;
              background-color: #f5f5f5;
              font-family: Arial, sans-serif;
            }
          `;
          document.head.appendChild(style);
          
          // Format JSON if it's in a pre tag
          const pre = document.querySelector("pre");
          if (pre) {
            try {
              const text = pre.textContent;
              const json = JSON.parse(text);
              pre.textContent = JSON.stringify(json, null, 2);
            } catch(e) {
              console.log("Not valid JSON or already formatted");
            }
          }
          
          // Remove all fixed-top elements
          document.querySelectorAll('.fixed-top').forEach(el => {
            el.style.display = 'none';
          });
          
          // Remove navigation bars
          document.querySelectorAll('nav').forEach(el => {
            el.style.display = 'none';
          });
          
          // Remove sidebar
          const sidebar = document.querySelector('.sidebar');
          if (sidebar) sidebar.style.display = 'none';
          
          // Adjust main panel
          const mainPanel = document.querySelector('.main-panel');
          if (mainPanel) {
            mainPanel.style.width = '100%';
            mainPanel.style.marginLeft = '0';
            mainPanel.style.paddingTop = '10px';
          }
        } catch (err) {
          console.error("Error cleaning up WebView:", err);
        }
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'Attendance',
          showBackButton: true,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'Attendance',
          onItemSelected: (String item) {
            CustomNavigation.navigateToScreen(item, context);
          },
        ),
        body: Stack(
          children: [
            // WebView content
            Positioned.fill(
              child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : WebViewWidget(controller: controller),
            ),
            
            // Loading overlay
            if (isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading attendance data...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}








// import 'package:flutter/material.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:get/get.dart';
// import 'package:ems/services/secure_storage_service.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';
// import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';

// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({Key? key}) : super(key: key);

//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
//   // Make controller nullable to avoid late initialization error
//   WebViewController? controller;
//   bool isLoading = true;
//   String? userId;
//   String? errorMessage;
//   bool isLoggedIn = false;
//   bool hasInjectedCredentials = false;
//   int redirectCount = 0;
//   static const int maxRedirects = 3;

//   Future<bool> _onWillPop() async {
//     if (Get.previousRoute.isNotEmpty) {
//       Get.to(() => DashboardScreen());
//       return false;
//     }
//     return true;
//   }

//   @override
//   void initState() {
//     super.initState();
//     // Initialize asynchronously but don't block the widget build
//     _initializeWebView();
//   }

//   Future<void> _initializeWebView() async {
//     try {
//       // Get user ID from secure storage
//       userId = await SecureStorageService.getUserId();
//       debugPrint('Retrieved user ID from storage: $userId');
      
//       if (userId == null) {
//         setState(() {
//           errorMessage = 'User ID not found. Please log in again.';
//           isLoading = false;
//         });
//         return;
//       }
      
//       // Get token for authentication
//       final token = await SecureStorageService.getToken();
//       if (token == null) {
//         setState(() {
//           errorMessage = 'Authorization token not found. Please log in again.';
//           isLoading = false;
//         });
//         return;
//       }

//       // Get email and password for auto-login if needed
//       final email = await SecureStorageService.getUserEmail();
//       final password = await SecureStorageService.getUserPassword();
      
//       // Create and configure WebView controller
//       final webViewController = WebViewController()
//         ..setJavaScriptMode(JavaScriptMode.unrestricted)
//         ..setNavigationDelegate(
//           NavigationDelegate(
//             onPageStarted: (String url) {
//               debugPrint('Page started loading: $url');
//               if (mounted) {
//                 setState(() {
//                   isLoading = true;
//                 });
//               }

//               // Check if user has reached attendance page
//               if (url.contains('/student/attendance') && !url.endsWith('/login')) {
//                 isLoggedIn = true;
//               }
//             },
//             onPageFinished: (String url) async {
//               debugPrint('Page finished loading: $url');
              
//               if (controller != null) {
//                 // Hide navbar elements
//                 await _hideNavbar();
                
//                 // Check if we're on the login page and need to log in
//                 if (url.contains('/login') || url == 'https://extratech.extratechweb.com/') {
//                   // Only inject credentials once to avoid infinite loop
//                   if (!hasInjectedCredentials && email != null && password != null) {
//                     debugPrint('Detected login page, attempting auto-login');
//                     await _injectCredentials(email, password);
//                     hasInjectedCredentials = true;
//                   } else if (redirectCount < maxRedirects) {
//                     // If already tried injecting credentials, try direct navigation
//                     redirectCount++;
//                     debugPrint('Login still showing, trying direct navigation (attempt $redirectCount)');
                    
//                     // First try to inject token
//                     await controller!.runJavaScript(
//                       "localStorage.setItem('auth_token', '$token');"
//                     );
                    
//                     // Then navigate directly to attendance
//                     if (redirectCount >= 2) {
//                       final attendanceUrl = 'https://extratech.extratechweb.com/student/attendance';
//                       await controller!.loadRequest(Uri.parse(attendanceUrl));
//                     }
//                   }
//                 } else if (isLoggedIn) {
//                   // We're on attendance page, inject token for persistence
//                   await controller!.runJavaScript(
//                     "localStorage.setItem('auth_token', '$token');"
//                   );
//                 }
//               }
              
//               if (mounted) {
//                 setState(() {
//                   isLoading = false;
//                 });
//               }
//             },
//             onWebResourceError: (WebResourceError error) {
//               debugPrint('WebView error: ${error.description}');
              
//               if (!isLoggedIn && redirectCount >= maxRedirects && mounted) {
//                 setState(() {
//                   errorMessage = 'Error loading attendance: ${error.description}';
//                   isLoading = false;
//                 });
//               }
//             },
//           ),
//         );

//       // Set controller safely after configuration
//       if (mounted) {
//         setState(() {
//           controller = webViewController;
//         });
//       }

//       // Start with the direct attendance URL with userId
//       final attendanceUrl = 'https://extratech.extratechweb.com/student/attendance';
      
//       // Load the URL with auth headers
//       await webViewController.loadRequest(
//         Uri.parse(attendanceUrl),
//         headers: {
//           'Authorization': 'Bearer $token',
//           'Accept': 'application/json',
//         },
//       );
//     } catch (e) {
//       debugPrint('Error initializing WebView: $e');
//       if (mounted) {
//         setState(() {
//           errorMessage = 'Failed to load attendance page: $e';
//           isLoading = false;
//         });
//       }
//     }
//   }

//   // Inject login credentials
//   Future<void> _injectCredentials(String email, String password) async {
//     if (controller == null) return;
    
//     await controller!.runJavaScript('''
//       (function() {
//         try {
//           // Find login form elements
//           const emailInput = document.querySelector('input[type="email"], input[name="email"]');
//           const passwordInput = document.querySelector('input[type="password"]');
//           const loginForm = document.querySelector('form');
          
//           if (emailInput && passwordInput && loginForm) {
//             // Fill in the credentials
//             emailInput.value = "$email";
//             passwordInput.value = "$password";
            
//             // Submit the form
//             console.log("Submitting login form");
//             setTimeout(() => {
//               loginForm.submit();
//             }, 500);
//             return true;
//           } else {
//             console.log("Couldn't find login form elements");
//             return false;
//           }
//         } catch (e) {
//           console.error("Error in auto-login:", e);
//           return false;
//         }
//       })();
//     ''');
//   }

//   Future<void> _hideNavbar() async {
//     if (controller == null) return;
    
//     await controller!.runJavaScript('''
//       (function() {
//         try {
//           // Add CSS to hide navigation elements
//           const style = document.createElement('style');
//           style.textContent = `
//             nav, .navbar, .top-navbar { display: none !important; }
//             .profile-top, .profile-top-flex-2 { display: none !important; }
//             .sidebar { display: none !important; }
//             .main-panel { width: 100% !important; margin-left: 0 !important; padding-top: 10px !important; }
//             .navbar-breadcrumb { display: none !important; }
//             .container-fluid { padding-top: 10px !important; }
//           `;
//           document.head.appendChild(style);
          
//           // Attempt to directly modify elements for immediate effect
//           const navbars = document.querySelectorAll('nav, .navbar, .top-navbar');
//           navbars.forEach(nav => {
//             if (nav) nav.style.display = 'none';
//           });
          
//           const sidebar = document.querySelector('.sidebar');
//           if (sidebar) sidebar.style.display = 'none';
          
//           const mainPanel = document.querySelector('.main-panel');
//           if (mainPanel) {
//             mainPanel.style.width = '100%';
//             mainPanel.style.marginLeft = '0';
//             mainPanel.style.paddingTop = '10px';
//           }
          
//           console.log("Navigation elements hidden successfully");
//         } catch (err) {
//           console.error("Error hiding navigation:", err);
//         }
//       })();
//     ''');
//   }

//   // Try direct navigation to attendance report
//   void _goToAttendanceReport() async {
//     if (controller == null || userId == null) return;
    
//     final directUrl = 'https://extratech.extratechweb.com/student/attendances';
//     debugPrint('Trying alternate attendance URL: $directUrl');
    
//     controller!.loadRequest(Uri.parse(directUrl));
//   }
  
//   // Try the API view
//   void _tryApiView() async {
//     if (controller == null || userId == null) return;
    
//     final apiUrl = 'https://extratech.extratechweb.com/student/attendance/api/$userId';
//     debugPrint('Trying API view: $apiUrl');
    
//     controller!.loadRequest(Uri.parse(apiUrl));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Attendance',
//           showBackButton: true,
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Attendance',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Column(
//           children: [
//             // Navigation options
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//               color: Colors.grey[100],
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'User ID: ${userId ?? 'Not found'}',
//                       style: TextStyle(fontSize: 12, color: Colors.grey[800]),
//                     ),
//                   ),
//                   TextButton(
//                     onPressed: _goToAttendanceReport,
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: const Size(40, 20),
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: const Text('Report', style: TextStyle(fontSize: 12)),
//                   ),
//                   const SizedBox(width: 8),
//                   TextButton(
//                     onPressed: _tryApiView,
//                     style: TextButton.styleFrom(
//                       padding: EdgeInsets.zero,
//                       minimumSize: const Size(40, 20),
//                       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     ),
//                     child: const Text('API', style: TextStyle(fontSize: 12)),
//                   ),
//                 ],
//               ),
//             ),
            
//             // Main content
//             Expanded(
//               child: errorMessage != null
//                 ? _buildErrorView()
//                 : Stack(
//                     children: [
//                       // Only show WebView when controller is initialized
//                       if (controller != null)
//                         WebViewWidget(controller: controller!),
                        
//                       if (isLoading || controller == null)
//                         Container(
//                           color: Colors.white70,
//                           child: const Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 CircularProgressIndicator(),
//                                 SizedBox(height: 16),
//                                 Text('Loading attendance data...'),
//                               ],
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildErrorView() {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, color: Colors.red[400], size: 48),
//             const SizedBox(height: 16),
//             Text(
//               errorMessage!,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 16),
//             ),
//             const SizedBox(height: 24),
//             ElevatedButton(
//               onPressed: () {
//                 setState(() {
//                   errorMessage = null;
//                   isLoading = true;
//                   hasInjectedCredentials = false;
//                   redirectCount = 0;
//                   controller = null; // Reset controller to reinitialize
//                 });
//                 _initializeWebView();
//               },
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }













// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:intl/intl.dart';
// // import 'package:ems/services/secure_storage_service.dart';
// // import 'package:ems/screens/AMS/home/dashboard_screen.dart';
// // import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
// // import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
// // import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';
// // import 'package:get/get.dart';

// // class AttendanceScreen extends StatefulWidget {
// //   const AttendanceScreen({Key? key}) : super(key: key);

// //   @override
// //   State<AttendanceScreen> createState() => _AttendanceScreenState();
// // }

// // class _AttendanceScreenState extends State<AttendanceScreen> {
// //   bool _isLoading = true;
// //   String? _error;
// //   List<Map<String, dynamic>> _attendanceRecords = [];
// //   DateTime _selectedMonth = DateTime.now();
// //   String? _userId; // To store the user ID
  
// //   @override
// //   void initState() {
// //     super.initState();
// //     _debugPrintStoredUserInfo();
// //     _initializeAndFetchData();
// //   }

// //   // Helper method to print all stored user information
// //   Future<void> _debugPrintStoredUserInfo() async {
// //     final userId = await SecureStorageService.getUserId();
// //     final email = await SecureStorageService.getUserEmail();
// //     final token = await SecureStorageService.getToken();
    
// //     debugPrint('========== ATTENDANCE SCREEN DEBUG ==========');
// //     debugPrint('Stored user ID: $userId');
// //     debugPrint('Stored email: $email');
// //     debugPrint('Token available: ${token != null}');
// //     if (token != null) {
// //       debugPrint('Token first 20 chars: ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
// //     }
// //     debugPrint('========== END ATTENDANCE SCREEN DEBUG ==========');
// //   }

// //   // Get user ID and fetch attendance data
// //   Future<void> _initializeAndFetchData() async {
// //     try {
// //       // Get user ID from secure storage or use hardcoded one for testing
// //       final userId = await SecureStorageService.getUserId() ?? '1828'; // Use 1828 as fallback for testing
      
// //       setState(() {
// //         _userId = userId;
// //         debugPrint('Using user ID: $_userId');
// //       });
      
// //       // Now fetch attendance data
// //       await _fetchAttendanceData();
// //     } catch (e) {
// //       setState(() {
// //         _error = 'Failed to initialize: ${e.toString()}';
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   Future<bool> _onWillPop() async {
// //     if (Get.previousRoute.isNotEmpty) {
// //       Get.to(() => DashboardScreen());
// //       return false;
// //     }
// //     return true;
// //   }

// //   Future<void> _fetchAttendanceData() async {
// //     setState(() {
// //       _isLoading = true;
// //       _error = null;
// //     });

// //     try {
// //       // Get token from secure storage
// //       final token = await SecureStorageService.getToken();
      
// //       if (token == null) {
// //         throw Exception('Authentication token not found');
// //       }
      
// //       if (_userId == null) {
// //         throw Exception('User ID is not available');
// //       }
      
// //       // Use the correct API endpoint format
// //       final url = 'https://extratech.extratechweb.com/student/attendance/api/$_userId';
// //       debugPrint('Fetching attendance from: $url');
      
// //       // Make API request
// //       final response = await http.get(
// //         Uri.parse(url),
// //         headers: {
// //           'Authorization': 'Bearer $token',
// //           'Accept': 'application/json',
// //         },
// //       );
      
// //       debugPrint('Attendance API Status: ${response.statusCode}');
      
// //       if (response.statusCode == 200) {
// //         final data = json.decode(response.body);
// //         debugPrint('Attendance API response received successfully');
        
// //         // Parse attendance records - adjust according to your API response structure
// //         List<Map<String, dynamic>> records = [];
        
// //         if (data['data'] != null && data['data'] is List) {
// //           records = List<Map<String, dynamic>>.from(data['data'].map((item) => item));
// //         } else if (data['attendance'] != null && data['attendance'] is List) {
// //           records = List<Map<String, dynamic>>.from(data['attendance'].map((item) => item));
// //         } else if (data is List) {
// //           records = List<Map<String, dynamic>>.from(data);
// //         }
        
// //         setState(() {
// //           _attendanceRecords = records;
// //           _isLoading = false;
// //         });
// //       } else if (response.statusCode == 401) {
// //         // Token expired or invalid
// //         setState(() {
// //           _error = 'Your session has expired. Please login again.';
// //           _isLoading = false;
// //         });
// //       } else {
// //         // Other errors
// //         setState(() {
// //           _error = 'Failed to load attendance data (Status ${response.statusCode}). Please try again.';
// //           _isLoading = false;
// //         });
// //       }
// //     } catch (e) {
// //       setState(() {
// //         _error = 'Error: ${e.toString()}';
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   // Helper to format date strings
// //   String _formatDate(String dateString) {
// //     try {
// //       final date = DateTime.parse(dateString);
// //       return DateFormat('EEE, MMM d, yyyy').format(date);
// //     } catch (e) {
// //       return dateString;
// //     }
// //   }

// //   // Change selected month and refresh data
// //   void _changeMonth(DateTime newMonth) {
// //     setState(() {
// //       _selectedMonth = newMonth;
// //     });
// //     _fetchAttendanceData();
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: _onWillPop,
// //       child: Scaffold(
// //         appBar: const CustomAppBar(
// //           title: 'Attendance',
// //           showBackButton: true,
// //         ),
// //         endDrawer: DashboardDrawer(
// //           selectedItem: 'Attendance',
// //           onItemSelected: (String item) {
// //             CustomNavigation.navigateToScreen(item, context);
// //           },
// //         ),
// //         body: _buildContent(),
// //       ),
// //     );
// //   }

// //   Widget _buildContent() {
// //     if (_isLoading) {
// //       return const Center(
// //         child: CircularProgressIndicator(),
// //       );
// //     }

// //     if (_error != null) {
// //       return Center(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               const Icon(
// //                 Icons.error_outline,
// //                 color: Colors.red,
// //                 size: 48,
// //               ),
// //               const SizedBox(height: 16),
// //               const Text(
// //                 'Something went wrong',
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               const SizedBox(height: 8),
// //               Text(
// //                 _error!,
// //                 textAlign: TextAlign.center,
// //                 style: const TextStyle(
// //                   color: Colors.red,
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               ElevatedButton.icon(
// //                 onPressed: _fetchAttendanceData,
// //                 icon: const Icon(Icons.refresh),
// //                 label: const Text('Retry'),
// //                 style: ElevatedButton.styleFrom(
// //                   backgroundColor: const Color(0xFF205EB5),
// //                   foregroundColor: Colors.white,
// //                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       );
// //     }

// //     if (_attendanceRecords.isEmpty) {
// //       return Center(
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             Icon(
// //               Icons.calendar_today_outlined,
// //               size: 72,
// //               color: Colors.grey[400],
// //             ),
// //             const SizedBox(height: 16),
// //             Text(
// //               'No attendance records found',
// //               style: TextStyle(
// //                 fontSize: 18,
// //                 color: Colors.grey[700],
// //                 fontWeight: FontWeight.w500,
// //               ),
// //             ),
// //             const SizedBox(height: 8),
// //             Text(
// //               'There are no attendance records for the selected period',
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 color: Colors.grey[600],
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }

// //     return Column(
// //       children: [
// //         // Month selector
// //         _buildMonthSelector(),
        
// //         // Attendance summary
// //         _buildAttendanceSummary(),
        
// //         // Attendance records list
// //         Expanded(
// //           child: ListView.builder(
// //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //             itemCount: _attendanceRecords.length,
// //             itemBuilder: (context, index) {
// //               final record = _attendanceRecords[index];
// //               return _buildAttendanceCard(record);
// //             },
// //           ),
// //         ),
// //       ],
// //     );
// //   }
  
// //   Widget _buildMonthSelector() {
// //     return Container(
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 4,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //         children: [
// //           IconButton(
// //             icon: const Icon(Icons.chevron_left),
// //             onPressed: () {
// //               _changeMonth(DateTime(_selectedMonth.year, _selectedMonth.month - 1));
// //             },
// //           ),
// //           Column(
// //             children: [
// //               Text(
// //                 DateFormat('MMMM yyyy').format(_selectedMonth),
// //                 style: const TextStyle(
// //                   fontSize: 18,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //               if (_userId != null)
// //                 Text(
// //                   'User ID: $_userId',
// //                   style: TextStyle(
// //                     fontSize: 12,
// //                     color: Colors.grey[600],
// //                   ),
// //                 ),
// //             ],
// //           ),
// //           IconButton(
// //             icon: const Icon(Icons.chevron_right),
// //             onPressed: () {
// //               _changeMonth(DateTime(_selectedMonth.year, _selectedMonth.month + 1));
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
  
// //   Widget _buildAttendanceSummary() {
// //     // Calculate attendance statistics
// //     int totalDays = _attendanceRecords.length;
// //     int present = _attendanceRecords.where((record) => 
// //         record['status']?.toString().toLowerCase() == 'present' || 
// //         record['attendance_status']?.toString().toLowerCase() == 'present').length;
// //     int absent = _attendanceRecords.where((record) => 
// //         record['status']?.toString().toLowerCase() == 'absent' || 
// //         record['attendance_status']?.toString().toLowerCase() == 'absent').length;
// //     int late = _attendanceRecords.where((record) => 
// //         record['status']?.toString().toLowerCase() == 'late' || 
// //         record['attendance_status']?.toString().toLowerCase() == 'late').length;
    
// //     double presentPercentage = totalDays > 0 ? (present / totalDays) * 100 : 0;
    
// //     return Container(
// //       margin: const EdgeInsets.all(16),
// //       padding: const EdgeInsets.all(16),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 8,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           const Text(
// //             'Attendance Summary',
// //             style: TextStyle(
// //               fontSize: 18,
// //               fontWeight: FontWeight.bold,
// //             ),
// //           ),
// //           const SizedBox(height: 16),
          
// //           // Progress bar
// //           Stack(
// //             children: [
// //               Container(
// //                 height: 24,
// //                 width: double.infinity,
// //                 decoration: BoxDecoration(
// //                   color: Colors.grey[200],
// //                   borderRadius: BorderRadius.circular(12),
// //                 ),
// //               ),
// //               FractionallySizedBox(
// //                 widthFactor: presentPercentage / 100,
// //                 child: Container(
// //                   height: 24,
// //                   decoration: BoxDecoration(
// //                     color: presentPercentage >= 75 ? Colors.green : 
// //                            presentPercentage >= 50 ? Colors.orange : Colors.red,
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                 ),
// //               ),
// //               Container(
// //                 height: 24,
// //                 width: double.infinity,
// //                 alignment: Alignment.center,
// //                 child: Text(
// //                   '${presentPercentage.toStringAsFixed(1)}%',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.bold,
// //                     shadows: [
// //                       Shadow(
// //                         offset: Offset(0, 0),
// //                         blurRadius: 3.0,
// //                         color: Color.fromARGB(255, 0, 0, 0),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
          
// //           const SizedBox(height: 16),
          
// //           // Statistics
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceAround,
// //             children: [
// //               _buildStatItem('Present', present, Colors.green),
// //               _buildStatItem('Absent', absent, Colors.red),
// //               _buildStatItem('Late', late, Colors.orange),
// //               _buildStatItem('Total', totalDays, Colors.blue),
// //             ],
// //           ),
// //         ],
// //       ),
// //     );
// //   }
  
// //   Widget _buildStatItem(String label, int value, Color color) {
// //     return Column(
// //       children: [
// //         Container(
// //           width: 40,
// //           height: 40,
// //           decoration: BoxDecoration(
// //             color: color.withOpacity(0.2),
// //             shape: BoxShape.circle,
// //           ),
// //           child: Center(
// //             child: Text(
// //               value.toString(),
// //               style: TextStyle(
// //                 color: color,
// //                 fontWeight: FontWeight.bold,
// //                 fontSize: 16,
// //               ),
// //             ),
// //           ),
// //         ),
// //         const SizedBox(height: 8),
// //         Text(
// //           label,
// //           style: TextStyle(
// //             color: Colors.grey[700],
// //             fontSize: 12,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
  
// //   Widget _buildAttendanceCard(Map<String, dynamic> record) {
// //     // Extract data (adjust these keys based on your actual API response)
// //     String date = record['date'] ?? record['attendance_date'] ?? 'Unknown date';
// //     String status = record['status'] ?? record['attendance_status'] ?? 'Unknown';
// //     String checkInTime = record['check_in_time'] ?? record['time_in'] ?? 'N/A';
// //     String checkOutTime = record['check_out_time'] ?? record['time_out'] ?? 'N/A';
    
// //     Color statusColor;
// //     IconData statusIcon;
    
// //     switch (status.toLowerCase()) {
// //       case 'present':
// //         statusColor = Colors.green;
// //         statusIcon = Icons.check_circle;
// //         break;
// //       case 'absent':
// //         statusColor = Colors.red;
// //         statusIcon = Icons.cancel;
// //         break;
// //       case 'late':
// //         statusColor = Colors.orange;
// //         statusIcon = Icons.access_time;
// //         break;
// //       default:
// //         statusColor = Colors.grey;
// //         statusIcon = Icons.help_outline;
// //     }
    
// //     return Card(
// //       margin: const EdgeInsets.only(bottom: 12),
// //       elevation: 2,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.circular(12),
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Row(
// //           children: [
// //             Container(
// //               width: 50,
// //               height: 50,
// //               decoration: BoxDecoration(
// //                 color: statusColor.withOpacity(0.2),
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 statusIcon,
// //                 color: statusColor,
// //                 size: 28,
// //               ),
// //             ),
// //             const SizedBox(width: 16),
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     _formatDate(date),
// //                     style: const TextStyle(
// //                       fontWeight: FontWeight.bold,
// //                       fontSize: 16,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     'Status: $status',
// //                     style: TextStyle(
// //                       color: statusColor,
// //                       fontWeight: FontWeight.w500,
// //                     ),
// //                   ),
// //                   if (checkInTime != 'N/A' || checkOutTime != 'N/A')
// //                     const SizedBox(height: 4),
// //                   if (checkInTime != 'N/A')
// //                     Row(
// //                       children: [
// //                         const Icon(Icons.login, size: 14, color: Colors.grey),
// //                         const SizedBox(width: 4),
// //                         Text(
// //                           'In: $checkInTime',
// //                           style: TextStyle(
// //                             color: Colors.grey[700],
// //                             fontSize: 13,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   if (checkOutTime != 'N/A')
// //                     Row(
// //                       children: [
// //                         const Icon(Icons.logout, size: 14, color: Colors.grey),
// //                         const SizedBox(width: 4),
// //                         Text(
// //                           'Out: $checkOutTime',
// //                           style: TextStyle(
// //                             color: Colors.grey[700],
// //                             fontSize: 13,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }














// import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:ems/screens/AMS/home/dashboard_screen.dart';
// import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';

// class AttendanceScreen extends StatefulWidget {
//   const AttendanceScreen({super.key});

//   @override
//   State<AttendanceScreen> createState() => _AttendanceScreenState();
// }

// class _AttendanceScreenState extends State<AttendanceScreen> {
//   late WebViewController controller;
//   bool isLoading = true;

//   Future<bool> _onWillPop() async {
//     if (Get.previousRoute.isNotEmpty) {
//       // Get.back();
//       Get.to(() => DashboardScreen());
//       return false;
//     }
//     // If no previous route, let the system handle the back button
//     return true;
//   }

//   @override
//   void initState() {
//     super.initState();
//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onPageStarted: (String url) {
//             setState(() {
//               isLoading = true;
//             });
//           },
//           onPageFinished: (String url) {
//             // Hide navbar once the page is loaded
//             _hideNavbar();
//             setState(() {
//               isLoading = false;
//             });
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             // You can implement custom navigation logic here if needed
//             return NavigationDecision.navigate;
//           },
//         ),
//       )
//       ..loadRequest(Uri.parse('https://extratech.extratechweb.com/student/attendance'));
//   }

//   Future<void> _hideNavbar() async {
//     // JavaScript to hide the navbar and profile div
//     await controller.runJavaScript('''
//       (function() {
//         // Try multiple selector approaches
//         var navbars = document.querySelectorAll('nav');
//         for (var i = 0; i < navbars.length; i++) {
//           navbars[i].style.display = 'none';
//         }
        
//         // Try by class name
//         var navbarByClass = document.querySelector('.light-blue.navbar');
//         if (navbarByClass) {
//           navbarByClass.style.display = 'none';
//         }
        
//         // Try by exact class
//         var navbarByExactClass = document.querySelector('.light-blue.navbar.default-layout-navbar.col-lg-12.col-12.p-0.fixed-top.d-flex.flex-row');
//         if (navbarByExactClass) {
//           navbarByExactClass.style.display = 'none';
//         }
        
//         // Try removing it from DOM completely
//         var navbarToRemove = document.querySelector('nav.light-blue');
//         if (navbarToRemove) {
//           navbarToRemove.parentNode.removeChild(navbarToRemove);
//         }
        
//         // Adjust the body padding and margins
//         document.body.style.paddingTop = '0';
//         document.body.style.marginTop = '0';
        
//         // Find the main content container and adjust it
//         var contentWrapper = document.querySelector('.container-fluid.page-body-wrapper');
//         if (contentWrapper) {
//           contentWrapper.style.paddingTop = '0';
//           contentWrapper.style.marginTop = '0';
//         }
        
//         // Force a fixed position element to be hidden
//         var css = 'nav.fixed-top { display: none !important; }';
//         var style = document.createElement('style');
//         style.type = 'text/css';
//         style.appendChild(document.createTextNode(css));
//         document.head.appendChild(style);
        
//         // Hide the profile div
//         var profileDiv = document.querySelector('.profile-top.profile-top-flex-2');
//         if (profileDiv) {
//           profileDiv.style.display = 'none';
//         }
        
//         // Add CSS rule to ensure the profile div stays hidden
//         var profileCss = '.profile-top.profile-top-flex-2 { display: none !important; }';
//         var profileStyle = document.createElement('style');
//         profileStyle.type = 'text/css';
//         profileStyle.appendChild(document.createTextNode(profileCss));
//         document.head.appendChild(profileStyle);
        
//         // Add spacing at the top of the content
//         var mainContent = document.querySelector('.main-panel');
//         if (mainContent) {
//           mainContent.style.paddingTop = '20px';
//           mainContent.style.marginTop = '20px';
          
//         }
        
//         // Alternative approach to add spacing - add padding to the first content element
//         var firstContent = document.querySelector('.content-wrapper');
//         if (firstContent) {
//           firstContent.style.paddingTop = '20px';

//         }
//       })();
//     ''');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Attendance',
//           // icon: Icons.calendar_today,
//           showBackButton: true, // Explicitly show back button
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Attendance',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Column(
//           children: [
//             // Add a small spacer at the top of the WebView container
//             const SizedBox(height: 8),
//             Expanded(
//               child: Container(
//                 color: Colors.white,
//                 child: Stack(
//                   children: [
//                     if (!isLoading) WebViewWidget(controller: controller),
//                     if (isLoading)
//                       const Center(
//                         child: CircularProgressIndicator(),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }








// // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // import 'package:get/get.dart';
// // import 'package:webview_flutter/webview_flutter.dart';
// // import 'package:ems/screens/home/dashboard_screen.dart';
// // import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
// // import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
// // import 'package:ems/widgets/custom_widgets/custom_navigation.dart';

// // class AttendanceScreen extends StatefulWidget {
// //   const AttendanceScreen({super.key});

// //   @override
// //   State<AttendanceScreen> createState() => _AttendanceScreenState();
// // }

// // class _AttendanceScreenState extends State<AttendanceScreen> {
// //   late WebViewController controller;
// //   bool isLoading = true;

// //   Future<bool> _onWillPop() async {
// //     if (Get.previousRoute.isNotEmpty) {
// //       // Get.back();
// //       Get.to(() => DashboardScreen());
// //       return false;
// //     }
// //     // If no previous route, let the system handle the back button
// //     return true;
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     controller = WebViewController()
// //       ..setJavaScriptMode(JavaScriptMode.unrestricted)
// //       ..setNavigationDelegate(
// //         NavigationDelegate(
// //           onPageStarted: (String url) {
// //             setState(() {
// //               isLoading = true;
// //             });
// //           },
// //           onPageFinished: (String url) {
// //             // Hide navbar once the page is loaded
// //             _hideNavbar();
// //             setState(() {
// //               isLoading = false;
// //             });
// //           },
// //           onNavigationRequest: (NavigationRequest request) {
// //             // You can implement custom navigation logic here if needed
// //             return NavigationDecision.navigate;
// //           },
// //         ),
// //       )
// //       ..loadRequest(Uri.parse('https://extratech.extratechweb.com/student/attendance'));
// //   }

// //   Future<void> _hideNavbar() async {
// //     // JavaScript to hide the navbar - using multiple approaches to ensure it works
// //     await controller.runJavaScript('''
// //       (function() {
// //         // Try multiple selector approaches
// //         var navbars = document.querySelectorAll('nav');
// //         for (var i = 0; i < navbars.length; i++) {
// //           navbars[i].style.display = 'none';
// //         }
        
// //         // Try by class name
// //         var navbarByClass = document.querySelector('.light-blue.navbar');
// //         if (navbarByClass) {
// //           navbarByClass.style.display = 'none';
// //         }
        
// //         // Try by exact class
// //         var navbarByExactClass = document.querySelector('.light-blue.navbar.default-layout-navbar.col-lg-12.col-12.p-0.fixed-top.d-flex.flex-row');
// //         if (navbarByExactClass) {
// //           navbarByExactClass.style.display = 'none';
// //         }
        
// //         // Try removing it from DOM completely
// //         var navbarToRemove = document.querySelector('nav.light-blue');
// //         if (navbarToRemove) {
// //           navbarToRemove.parentNode.removeChild(navbarToRemove);
// //         }
        
// //         // Adjust the body padding and margins
// //         document.body.style.paddingTop = '0';
// //         document.body.style.marginTop = '0';
        
// //         // Find the main content container and adjust it
// //         var contentWrapper = document.querySelector('.container-fluid.page-body-wrapper');
// //         if (contentWrapper) {
// //           contentWrapper.style.paddingTop = '0';
// //           contentWrapper.style.marginTop = '0';
// //         }
        
// //         // Force a fixed position element to be hidden
// //         var css = 'nav.fixed-top { display: none !important; }';
// //         var style = document.createElement('style');
// //         style.type = 'text/css';
// //         style.appendChild(document.createTextNode(css));
// //         document.head.appendChild(style);
// //       })();
// //     ''');
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return WillPopScope(
// //       onWillPop: _onWillPop,
// //       child: Scaffold(
// //         appBar: const CustomAppBar(
// //           title: 'Attendance',
// //           icon: Icons.check_circle,
// //           showBackButton: true, // Explicitly show back button
// //         ),
// //         endDrawer: DashboardDrawer(
// //           selectedItem: 'Attendance',
// //           onItemSelected: (String item) {
// //             CustomNavigation.navigateToScreen(item, context);
// //           },
// //         ),
// //         body: Container(
// //           color: Colors.white,
// //           child: Stack(
// //             children: [
// //               if (!isLoading) WebViewWidget(controller: controller),
// //               if (isLoading)
// //                 const Center(
// //                   child: CircularProgressIndicator(),
// //                 ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
