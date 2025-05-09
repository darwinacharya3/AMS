import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ems/screens/AMS/home/dashboard_screen.dart';
import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';

class CareerScreen extends StatefulWidget {
  const CareerScreen({super.key});

  @override
  State<CareerScreen> createState() => _CareerScreenState();
}

class _CareerScreenState extends State<CareerScreen> {
  late WebViewController controller;
  bool isLoading = true;

  Future<bool> _onWillPop() async {
    if (Get.previousRoute.isNotEmpty) {
      // Get.back();
      Get.to(() => DashboardScreen());
      return false;
    }
    // If no previous route, let the system handle the back button
    return true;
  }

  @override
  void initState() {
    super.initState();
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
            // Hide navbar once the page is loaded
            _hideNavbar();
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            // You can implement custom navigation logic here if needed
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://extratech.extratechweb.com/student/career-index'));
  }

  Future<void> _hideNavbar() async {
    // JavaScript to hide the navbar and profile div
    await controller.runJavaScript('''
      (function() {
        // Try multiple selector approaches
        var navbars = document.querySelectorAll('nav');
        for (var i = 0; i < navbars.length; i++) {
          navbars[i].style.display = 'none';
        }
        
        // Try by class name
        var navbarByClass = document.querySelector('.light-blue.navbar');
        if (navbarByClass) {
          navbarByClass.style.display = 'none';
        }
        
        // Try by exact class
        var navbarByExactClass = document.querySelector('.light-blue.navbar.default-layout-navbar.col-lg-12.col-12.p-0.fixed-top.d-flex.flex-row');
        if (navbarByExactClass) {
          navbarByExactClass.style.display = 'none';
        }
        
        // Try removing it from DOM completely
        var navbarToRemove = document.querySelector('nav.light-blue');
        if (navbarToRemove) {
          navbarToRemove.parentNode.removeChild(navbarToRemove);
        }
        
        // Adjust the body padding and margins
        document.body.style.paddingTop = '0';
        document.body.style.marginTop = '0';
        
        // Find the main content container and adjust it
        var contentWrapper = document.querySelector('.container-fluid.page-body-wrapper');
        if (contentWrapper) {
          contentWrapper.style.paddingTop = '0';
          contentWrapper.style.marginTop = '0';
        }
        
        // Force a fixed position element to be hidden
        var css = 'nav.fixed-top { display: none !important; }';
        var style = document.createElement('style');
        style.type = 'text/css';
        style.appendChild(document.createTextNode(css));
        document.head.appendChild(style);
        
        // Hide the profile div
        var profileDiv = document.querySelector('.profile-top.profile-top-flex-2');
        if (profileDiv) {
          profileDiv.style.display = 'none';
        }
        
        // Add CSS rule to ensure the profile div stays hidden
        var profileCss = '.profile-top.profile-top-flex-2 { display: none !important; }';
        var profileStyle = document.createElement('style');
        profileStyle.type = 'text/css';
        profileStyle.appendChild(document.createTextNode(profileCss));
        document.head.appendChild(profileStyle);
        
        // Add spacing at the top of the content
        var mainContent = document.querySelector('.main-panel');
        if (mainContent) {
          mainContent.style.paddingTop = '20px';
          mainContent.style.marginTop = '20px';
        }
        
        // Alternative approach to add spacing - add padding to the first content element
        var firstContent = document.querySelector('.content-wrapper');
        if (firstContent) {
          firstContent.style.paddingTop = '20px';
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
          title: 'Career',
          // icon: Icons.work,
          showBackButton: true, // Explicitly show back button
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'Career',
          onItemSelected: (String item) {
            CustomNavigation.navigateToScreen(item, context);
          },
        ),
        body: Column(
          children: [
            // Add a small spacer at the top of the WebView container
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                color: Colors.white,
                child: Stack(
                  children: [
                    if (!isLoading) WebViewWidget(controller: controller),
                    if (isLoading)
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
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
// // import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:webview_flutter/webview_flutter.dart';
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_widgets/custom_navigation.dart';

// class CareerScreen extends StatefulWidget {
//   const CareerScreen({super.key});

//   @override
//   State<CareerScreen> createState() => _CareerScreenState();
// }

// class _CareerScreenState extends State<CareerScreen> {
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
//       ..loadRequest(Uri.parse('https://extratech.extratechweb.com/student/career-index'));
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
//       })();
//     ''');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Career',
//           icon: Icons.work,
//           showBackButton: true, // Explicitly show back button
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Career',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Container(
//           color: Colors.white,
//           child: Stack(
//             children: [
//               if (!isLoading) WebViewWidget(controller: controller),
//               if (isLoading)
//                 const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//             ],
//           ),
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
// import 'package:ems/widgets/custom_widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_widgets/custom_navigation.dart';

// class CareerScreen extends StatefulWidget {
//   const CareerScreen({super.key});

//   @override
//   State<CareerScreen> createState() => _CareerScreenState();
// }

// class _CareerScreenState extends State<CareerScreen> {
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
//       ..loadRequest(Uri.parse('https://extratech.extratechweb.com/student/career-index'));
//   }

//   Future<void> _hideNavbar() async {
//     // JavaScript to hide the navbar - using multiple approaches to ensure it works
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
//       })();
//     ''');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: Scaffold(
//         appBar: const CustomAppBar(
//           title: 'Career',
//           icon: Icons.work,
//           showBackButton: true, // Explicitly show back button
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'Career',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Container(
//           color: Colors.white,
//           child: Stack(
//             children: [
//               if (!isLoading) WebViewWidget(controller: controller),
//               if (isLoading)
//                 const Center(
//                   child: CircularProgressIndicator(),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
