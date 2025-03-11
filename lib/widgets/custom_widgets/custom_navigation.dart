import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:ems/services/secure_storage_service.dart';
import 'package:ems/screens/home/attendance_screen.dart';
import 'package:ems/screens/home/career_screen.dart';
import 'package:ems/screens/home/quiz_screen.dart';
import 'package:ems/screens/membership_card/membership_card_screen.dart';
import 'package:ems/screens/material/material_screen.dart';
import 'package:ems/screens/zoom_link/zoom_link_screen.dart';
import 'package:ems/screens/tickets/all_tickets_screen.dart';
import 'package:ems/screens/tickets/completed_tickets_screen.dart';
import 'package:ems/screens/tickets/create_ticket_screen.dart';
import 'package:ems/screens/enrollment/enrollment_screen.dart';
import 'package:ems/screens/home/dashboard_screen.dart';

class CustomNavigation {
  static void navigateToScreen(String item, BuildContext context) {
    // Close drawer first
    Navigator.of(context).pop();
    
    // Add small delay to ensure drawer is closed before navigation
    Future.delayed(const Duration(milliseconds: 100), () {
      switch (item) {
        case 'General':
          Get.to(() => const DashboardScreen(), transition: Transition.rightToLeft);
          break;
        case 'Attendance':
          Get.to(() => const AttendanceScreen(), transition: Transition.rightToLeft);
          break;
        case 'Quiz':
          Get.to(() => const QuizScreen(), transition: Transition.rightToLeft);
          break;
        case 'Career':
          Get.to(() => const CareerScreen(), transition: Transition.rightToLeft);
          break;
         case 'Membership Card':
          Get.to(() => const MembershipCardScreen(), transition: Transition.rightToLeft);
          break;
        case 'Materials':
          Get.to(() => const MaterialsScreen(), transition: Transition.rightToLeft);
          break;
        case 'Zoom Links':
          Get.to(() => const ZoomLinksScreen(), transition: Transition.rightToLeft);
          break;
        case 'Create Ticket':
          Get.to(() => const CreateTicketScreen(), transition: Transition.rightToLeft);
          break;
        case 'All Tickets':
          Get.to(() => const AllTicketsScreen(), transition: Transition.rightToLeft);
          break;
        case 'Completed Tickets':
          Get.to(() => const CompletedTicketsScreen(), transition: Transition.rightToLeft);
          break;
        case 'Logout':
          _handleLogout(context);
           break;
         
      }
    });
  }

  static void _handleLogout(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Logging out..."),
            ],
          ),
        );
      },
    );

    try {
      // Create a headless WebView to perform the logout
      await _performWebLogout();
      
      // Clear local storage
      await SecureStorageService.clearCredentials();
      
      // Close dialog and navigate to enrollment screen 
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close dialog
      }
      
      // Navigate to enrollment screen
      Get.offAll(() => const EnrollmentScreen(), transition: Transition.fade);
    } catch (e) {
      // If anything goes wrong, still clear local storage and redirect
      await SecureStorageService.clearCredentials();
      
      if (context.mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close dialog
      }
      
      Get.offAll(() => const EnrollmentScreen(), transition: Transition.fade);
    }
  }
  
  static Future<void> _performWebLogout() async {
    Completer<void> completer = Completer<void>();
    
    // Set a timeout
    Timer(const Duration(seconds: 3), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    
    try {
      final cookieManager = WebViewCookieManager();
      
      // We'll use a simpler approach - just clear all cookies
      await cookieManager.clearCookies();
      
      // Also make a direct HTTP request to the logout URL
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('https://extratech.extratechweb.com/logout'));
      final response = await request.close();
      await response.drain(); // Drain and discard response
      client.close();
      
      if (!completer.isCompleted) {
        completer.complete();
      }
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    
    return completer.future;
  }
}













// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:ems/screens/home/attendance_screen.dart';
// import 'package:ems/screens/home/career_screen.dart';
// import 'package:ems/screens/home/quiz_screen.dart';
// import 'package:ems/screens/material/material_screen.dart';
// import 'package:ems/screens/zoom_link/zoom_link_screen.dart';
// import 'package:ems/screens/tickets/all_tickets_screen.dart';
// import 'package:ems/screens/tickets/completed_tickets_screen.dart';
// import 'package:ems/screens/tickets/create_ticket_screen.dart';
// import 'package:ems/screens/enrollment/enrollment_screen.dart';
// import 'package:ems/screens/home/dashboard_screen.dart';

// class CustomNavigation {
//   static void navigateToScreen(String item, BuildContext context) {
//     // Close drawer first
//     Navigator.of(context).pop();
    
//     // Add small delay to ensure drawer is closed before navigation
//     Future.delayed(const Duration(milliseconds: 100), () {
//       switch (item) {
//         case 'General':
//           Get.to(() => const DashboardScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Attendance':
//           Get.to(() => const AttendanceScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Quiz':
//           Get.to(() => const QuizScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Career':
//           Get.to(() => const CareerScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Materials':
//           Get.to(() => const MaterialsScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Zoom Links':
//           Get.to(() => const ZoomLinksScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Create Ticket':
//           Get.to(() => const CreateTicketScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'All Tickets':
//           Get.to(() => const AllTicketsScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Completed Tickets':
//           Get.to(() => const CompletedTicketsScreen(), transition: Transition.rightToLeft);
//           break;
//         case 'Logout':
//           Get.offAll(() => const EnrollmentScreen(), transition: Transition.fade);
//           break;
//       }
//     });
//   }
// }
