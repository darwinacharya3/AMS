import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ems/screens/AMS/home/dashboard_screen.dart';
import 'package:ems/widgets/AMS/custom_widgets/dashboard_drawer.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_app_bar.dart';
import 'package:ems/widgets/AMS/custom_widgets/custom_navigation.dart';

class AllTicketsScreen extends StatefulWidget {
  const AllTicketsScreen({super.key});

  @override
  State<AllTicketsScreen> createState() => _AllTicketsScreenState();
}

class _AllTicketsScreenState extends State<AllTicketsScreen> {
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
            // Allow navigation within extratech domain
            if (request.url.contains('extratech.extratechweb.com')) {
              return NavigationDecision.navigate;
            }
            // Prevent navigation to external links
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://extratech.extratechweb.com/student/ticket-list'));
  }

  Future<void> _hideNavbar() async {
    // JavaScript to hide the navbar - using the exact approach from MaterialsScreen
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
      })();
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: const CustomAppBar(
          title: 'All Tickets',
          // icon: Icons.list_alt,
          showBackButton: true,
        ),
        endDrawer: DashboardDrawer(
          selectedItem: 'All Tickets',
          onItemSelected: (String item) {
            CustomNavigation.navigateToScreen(item, context);
          },
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'All Tickets Overview',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
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
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/home/dashboard_screen.dart';
// import 'package:ems/widgets/dashboard_drawer.dart';
// import 'package:ems/widgets/custom_app_bar.dart';
// import 'package:ems/widgets/custom_navigation.dart';

// class AllTicketsScreen extends StatelessWidget {
//   const AllTicketsScreen({Key? key}) : super(key: key);

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
//           title: 'All Tickets',
//           icon: Icons.list_alt,
//           showBackButton: true,  // Explicitly show back button
//         ),
//         endDrawer: DashboardDrawer(
//           selectedItem: 'All Tickets',
//           onItemSelected: (String item) {
//             CustomNavigation.navigateToScreen(item, context);
//           },
//         ),
//         body: Container(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'All Tickets Overview',
//                 style: GoogleFonts.poppins(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Add attendance-specific content here
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
